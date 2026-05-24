{ lib, pkgs }:

let
  inherit (builtins) typeOf;
  inherit (lib) hasInfix isPath isString;
in
rec {
  resolveWallpaper = w:
    if isPath w then w
    else if isString w then
      (if hasInfix "/" w
       then /. + w
       else "${pkgs.wallpappers}/${w}")
    else throw "modules.themes: wallpaper must be path or string, got ${typeOf w}";

  buildThemeAttrs = force: theme: {
    stylix = theme.extraStylix // {
      base16Scheme = force theme.scheme;
      image        = force (resolveWallpaper theme.wallpaper);
      polarity     = force theme.polarity;
    };
  };
}
