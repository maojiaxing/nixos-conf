{ lib, config, pkgs, ...}:

with lib;
let
  roleConfig = {
    name = "base";
    inherits = [];
  };

  roles = mkRoles roleConfig config.modules.profiles.roles;
in
mkMerge [
  (mkIf (roles.has "base") {
    system.stateVersion = mkDefault "24.11";

    boot = {
      # 默认使用最新内核
      kernelPackages = mkDefault pkgs.linuxKernel.packages.linux_6_12;

      # 基础引导加载器设置
      loader = {
        efi.canTouchEfiVariables = mkDefault true;
        systemd-boot.configurationLimit = mkDefault 10;
      };
    };

    hardware.enableRedistributableFirmware = true;

    nix = {
      settings = {
        auto-optimise-store = true;
        experimental-features = [ "nix-command" "flakes" ];

        substituters = [
          "https://mirror.sjtu.edu.cn/nix-channels/store"
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    environment.systemPackages = with pkgs; [
      curl wget git vim
    ];

    systemd = {
      services.clear-log = {
        description = "Clear >1 month-old logs every week";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.systemd}/bin/journalctl --vacuum-time=21d";
        };
      };

      timers.clear-log = {
        wantedBy = [ "timers.target" ];
        partOf = [ "clear-log.service" ];
        timerConfig.OnCalendar = "weekly UTC";
      };
    };
  })

]
