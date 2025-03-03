{ config, inputs, pkgs, ... }: 

{
  imports = [ 
    inputs.nixos-wsl.nixosModules.default 
  ];

  system.stateVersion = "24.05";
   
  wsl = {
    enable = true;
    defaultUser = "nixos";
    startMenuLaunchers = true;
  };
    
  #fileSystems."/mnt/c" = {
  #  fsType = "drvfs";
  #  options = [ "noatime" "metadata" ];
  #};

  environment.systemPackages = with pkgs; [ vim git curl zsh warp-terminal ];

  hardware.graphics.enable = true;

  environment.sessionVariables = {
    WSLENV = "DISPLAY/u";
    DISPLAY = ":0";
    LIBGL_ALWAYS_SOFTWARE = "1";
    XDG_RUNTIME_DIR = "/run/user/$(id -u)";
  };

  systemd.tmpfiles.rules = [
    "d /run/user/1000 0700 root root -"
  ];

  services.dbus = {
    enable = true;
    packages = [ pkgs.dconf ];
    implementation = "broker";  # 使用现代 message broker (默认)
  };

  # 确保 systemd 用户实例正确激活
  systemd.user.services.dbus = {
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.dbus}/bin/dbus-daemon --session --nofork --nopidfile";
      Restart = "on-failure";
    };
  };
}
