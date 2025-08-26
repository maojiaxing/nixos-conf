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
            }
          };
        };
      };
    };
  };
in {
  imports = [ inputs.disko.nixosModules.disko ];

  options.modules.profile.hardware.storage = {
    enable = mkEnableOption "declarative disk management with Disko";

    disk = mkOpt types.str "The primary disk device for the default layout.";
 
  };
}
