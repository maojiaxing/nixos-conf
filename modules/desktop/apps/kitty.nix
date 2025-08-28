{ lib, config, options, pkgs, ...}:

with lib;
{
  config = mkIf (elem "kitty" config.modules.desktop.apps) {
    user.packages = with pkgs; [
      kitty
    ];

    home-manager.users.${config.user.name}.programs.kitty = {
      enable = true;
      settings = {
        font_size = 13.0;
        scrollback_lines = 10000;
        background_opacity = 0.9; 
      };
    };
  };
}
