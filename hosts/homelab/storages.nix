{ pkgs, ... }:

{
  modules.profiles.hardware.storage = { 
    disk.nixos = {
      device = "/dev/nvme1n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            type = "EF00";
            size = "512MiB";
            fsType = "vfat";
            mountPoint = "/boot";
          };

          root = {
            size = "100%";
            content = {
              type = "btrfs";
              subvolumes = {
                "@root" = { mountpoint = "/"; mountOptions = [ "compress=zstd" "noatime" ]; };
                "@home" = { mountpoint = "/home"; mountOptions = [ "compress=zstd" "noatime" ]; };
                "@nix" = { mountpoint = "/nix"; mountOptions = [ "compress=zstd" "noatime" "nodatacow" ]; };
                "@log" = { mountpoint = "/var/log"; mountOptions = [ "compress=zstd" "noatime" ]; };
              };
            };
          };
        };
      };
    };

    disk.storage = {
      device = "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          zfs = {
            size = "931.5G";
            content = {
              type = "zfs";
              pool = "storage"; # 对应你的 ZFS pool 标签
            };
          };

          reserved = {
            size = "8M";
            type = "EF02"; # BIOS boot partition, a safe generic type
          };
        };
      };
    };
  };
}
