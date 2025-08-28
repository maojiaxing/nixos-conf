{ lib, config, options, pkgs, ...}:

with lib;
{
  config = mkIf (elem "kitty" config.modules.desktop.apps) {
    # user.packages = with pkgs; [
    #   kitty
    # ];

    user.programs.kitty = {
      enable = true;
      settings = {
        # windows
        hide_window_decorations = "yes";
        window_padding_width = "10 20 10 20";
        background_blur = 64;
        remember_window_size = "yes";

        # font
        font_size = 18.0;
        font_family= "Maple Mono NF CN ExtraLight";
        bold_font = "family='Maple Mono' style=ExtraBold variable_name=MapleMono";

        scrollback_lines = 10000;
        
        cursor_trail = 1;
        
      };
    };
  };
}
