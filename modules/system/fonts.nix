{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    maple-mono
  ];

  fonts.fontDir.enable = true;
}