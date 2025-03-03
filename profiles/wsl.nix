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
