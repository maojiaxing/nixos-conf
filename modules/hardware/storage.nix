{ lib, config, options, pkgs, inputs, ...}:

with lib;
let 
  cfg = config.modules.hardware.storage;

  findTypes = typeName: layoutNode:
    if !isAttrs layoutNode then false
    else if (layoutNode ? "type") && (elem layoutNode.type typeName) then true
    else any (findTypes typeName) (attrValues layoutNode);

  collectFilesystems = layoutNode:
      if ! lib.isAttrs layoutNode then [ ]
      else  (
        (if (layoutNode ? "type") && (layoutNode.type == "btrfs") then [ "btrfs" ] else [ ]) ++
        (if (layoutNode ? "type") && (elem layoutNode.type [ "zfs" "zfs_fs" ]) then [ "zfs" ] else [ ]) ++
        (if (layoutNode ? "type") && (layoutNode.type == "filesystem") && (layoutNode ? "format") then [ layoutNode.format ] else [ ]) ++
        (concatMap collectFilesystems (attrValues layoutNode))
      );

  defaultLayout = diskDevice: {
    disk.nixos = {
      device = diskDevice;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            type = "EF00";
            size = "512M";
            content = { type = "filesystem"; format = "vfat"; mountpoint = "/boot"; };
          };

          root = {
            size = "100%";
            content = {
              type = "btrfs";
              subvolumes = {
                "@root" = { mountpoint = "/"; mountOptions = [ "compress=zstd" "noatime" ]; };
                "@home" = { mountpoint = "/home"; mountOptions = [ "compress=zstd" "noatime" ]; };
                "@nix"  = { mountpoint = "/nix"; mountOptions = [ "compress=zstd" "noatime" "nodatacow" ]; };
              };
            };
          };
        };
      };
    };
  };

  finalLayout =
    if cfg.layout != null
    then cfg.layout
    else defaultLayout cfg.disk;

  # usesLVM = findTypes [ "lvm_pv" "lvm_vg" ] finalLayout;

  foundFilesystems = unique (collectFilesystems finalLayout);
in {
  imports = [ inputs.disko.nixosModules.disko ];

  options.modules.hardware.storage = {
    disk   = mkOpt' (types.nullOr types.str) null "The primary disk device for the default layout.";
    layout = mkOpt' (types.nullOr types.str) null "A complete, custom disko.devices conf. If this is set, the 'disk' option is ignored.";
  };

  config = mkIf (cfg.disk != null || cfg.layout != null) {
    assertions = [
      {
        assertion = cfg.disk != null || cfg.layout != null;
        message = ''
          Both 'disk' and 'layout' are not specified in mySystem.storage.
          Please specify 'disk' to use the default layout, or a full 'layout' for a custom setup.
        '';
      }

      {
        assertion = !(cfg.disk != null || cfg.layout != null);
        message = ''
          Both 'disk' and 'layout' are specified in mySystem.storage.
          Please specify only one: 'disk' for the default layout, or 'layout' for a custom setup.
        '';
      }
    ];

    disko.devices = finalLayout;

    boot.supportedFilesystems = foundFilesystems;
  };
}
