{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts-emoji
    lxgw-wenkai
    maple-mono-variable
  ];

  fonts.fontDir.enable = true;
}