{ config, input, pkgs, ... }: 

{
  boot.loader.grub.enable = false;

  wsl = {
    enable = true;
    defaultUser = "nixos";
    startMenuLaunchers = true;
  }
    
  wslConf = {
    automount.root = "/mnt";
    interop.enable = true;
  };
    
  #fileSystems."/mnt/c" = {
  #  fsType = "drvfs";
  #  options = [ "noatime" "metadata" ];
  #};

  environment.systemPackages = with pkgs; [ nvim git curl zsh ];

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
