{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    maple-mono
    maple-mono.NF
    maple-mono.CN
  ];

  fonts.fontDir.enable = true;
}