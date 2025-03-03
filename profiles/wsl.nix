{ config, inputs, pkgs, ... }: 

{
  imports = [ 
    inputs.nixos-wsl.nixosModules.default 
  ];

  system.stateVersion = "24.11";
   
  wsl = {
    enable = true;
    defaultUser = "nixos";
    startMenuLaunchers = true;
  };
    
  #fileSystems."/mnt/c" = {
  #  fsType = "drvfs";
  #  options = [ "noatime" "metadata" ];
  #};

  programs.sway.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.systemPackages = with pkgs; [ 
    vim 
    git 
    curl 
    zsh 
    warp-terminal 
    wayland
    wayland-protocols
    wl-clipboard
    glfw-wayland
    vulkan-loader
  ];

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

  hardware.opengl = {
    enable = true;
  };

  services.dbus = {
    enable = true;
    packages = [ pkgs.dconf pkgs.gnome.gnome-keyring ];
  };

  systemd.user.services."wireplumber" = {
    enable = true;
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.wireplumber}/bin/wireplumber";
    };
    wantedBy = [ "default.target" ];
};

  # 确保 systemd 用户实例正确激活
  systemd.user.services.dbus = {
    enable = true;
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "org.freedesktop.DBus";
      ExecStart = "${pkgs.dbus}/bin/dbus-daemon --session --nofork --nopidfile";
    };
  };
}
