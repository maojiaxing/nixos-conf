{ lib, config, options, pkgs, ...}:

with lib;
{
  config = mkIf (elem "kiity" config.modules.desktop.apps) {
    programs.kitty = {
      enable = true;
      fontSize = 12.0;
      font = "Fira Code Retina";
      window = {
        opacity = 0.9;
        padding = 10;
      };
      shell = pkgs.zsh;
    };
  };
}
