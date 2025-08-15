{ lib, config, inputs, pkgs, ...}:

with lib;
let
  platform = config.modules.profiles.platform or "linux";
  isWSL = platform == "wsl";
in
{
  # 导入 nixos-wsl 模块
  (mkIf platform == "wsl") ({
    imports = [
      inputs.nixos-wsl.nixosModules.default
    ];
  })

  config = mkIf isWSL {
    wsl = {
      enable = true;
      defaultUser = config.user.name;
      useWindowsDriver = true;
      startMenuLaunchers = true;

       wslConf = {
        automount.root = "/mnt";
        interop.appendWindowsPath = false;
        network.generateHosts = false;
      };
    };

    # 启用图形支持
    hardware.graphics.enable = true;

    # 禁用不需要的服务
    systemd.services.systemd-resolved.enable = false;
    networking.dhcpcd.enable = false;

    # WSL 特定的包
    environment.systemPackages = with pkgs; [
      wslu
    ];
  };
}
