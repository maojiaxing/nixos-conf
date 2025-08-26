{ lib, config, options, pkgs, inputs, ...}:

with lib;
let 

  layout = config.modules.hardware.storage.layout;

  findTypes = typeName: layoutNode:
    if ! isAttrs layoutNode then false
    else if elem layoutNode.type typeName then true
    else any (findTypes typeName) (attrValues layoutNode);

  collectFilesystems = layoutNode:
    if ! isAttrs layoutNode then [ ]
    else (
      (if layoutNode.type == "btrfs" then [ "btrfs" ] else [ ]) ++
      (if elem layoutNode.type [ "zfs" "zfs_fs" ] then [ "zfs" ] else [ ]) ++
      (if layoutNode.type == "filesystem" && layoutNode ? "format" then [ layoutNode.format ] else [ ]) ++
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
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };

          root = {
            size = "100%";
            content = {
              type = "btrfs";
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" "nodatacow" ];
                };
              };
            };
          };
        };
      };
    };
  };

  finalLayout =
    if modules.profile.hardware.storage.layout != null
    then modules.profile.hardware.storage.layout
    else defaultLayout modules.profile.hardware.storage.disk;

  usesLVM = findTypes [ "lvm_pv" "lvm_vg" ] layout;
in {
  imports = [ inputs.disko.nixosModules.disko ];

  options.modules.profile.hardware.storage = {
    enable = mkEnableOption "declarative disk management with Disko";
    disk   = mkOpt (types.nullOr types.str) "The primary disk device for the default layout.";
    layout = mkOpt (types.nullOr types.str) "A complete, custom disko.devices conf. If this is set, the 'disk' option is ignored.";
  };

  config = mkIf config.modules.hardware.storage.enable {
    assertions = [
      {
        assertion config.module.profile.hardware.storage.disk != null || config.module.profile.hardware.storage.layout != null;
        message = ''
          modules.profile.hardware.storage is enabled, but neither 'disk' nor 'layout' is specified.
          Please specify 'disk' to use the default layout, or a full 'layout' for a custom setup.
        '';
      }

      {
        assertion !(config.module.profile.hardware.storage.disk != null || config.module.profile.hardware.storage.layout != null);
        message = ''
          Both 'disk' and 'layout' are specified in mySystem.storage.
          Please specify only one: 'disk' for the default layout, or 'layout' for a custom setup.
        '';
      }
    ];

    disko.devices = finalLayout;

    boot.supportedFilesystems = lib.unique (collectFilesystems finalLayout);

    boot.initrd.lvm.enable = lib.mkIf (usesLVM finalLayout) true;
  };
}
