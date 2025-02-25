# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }: {

  wsl = {
    enable = true;
    defaultUser = "nixos";
    startMenuLaunchers = true;
    
    wslConf = {
      automount.root = "/mnt";
      interop.enable = true;
    };
  };
    

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05";
  

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    zsh
  ];

  hardware.graphics.enable = true;

  environment.sessionVariables = {
    WSLENV = "DISPLAY/u";
    DISPLAY = ":0";
    LIBGL_ALWAYS_SOFTWARE = "1";  # 修复 OpenGL 加速问题
  };

  services.dbus = {
    enable = true;
    implementation = "broker";  # 使用现代 message broker (默认)
  };

  # 确保 systemd 用户实例正确激活
  systemd.user.services.dbus = {
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "org.freedesktop.DBus";
    };
  };

}
