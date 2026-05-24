final: _prev:
let
  inherit (final) lib fetchurl stdenvNoCC;

  specsDir = ../../packages/wallpappers;

  specFiles =
    builtins.filter
      (n: lib.hasSuffix ".nix" n
          && !(lib.hasPrefix "_" n)
          && n != "default.nix")
      (builtins.attrNames (builtins.readDir specsDir));

  specs = map (f: import (specsDir + "/${f}")) specFiles;

  fetched = map (s: {
    inherit (s) name;
    src = fetchurl { inherit (s) url sha256; name = s.name; };
  }) specs;

  linkLines = lib.concatMapStringsSep "\n"
    (w: ''ln -s "${w.src}" "$out/${w.name}"'') fetched;
in
{
  wallpappers = stdenvNoCC.mkDerivation {
    pname   = "wallpappers";
    version = "0";

    dontUnpack    = true;
    dontConfigure = true;
    dontBuild     = true;

    installPhase = ''
      runHook preInstall
      install -d "$out"
      ${linkLines}
      runHook postInstall
    '';

    passthru.byName = lib.listToAttrs
      (map (w: { name = w.name; value = w.src; }) fetched);

    meta = with lib; {
      description = "Aggregated wallpaper collection";
      platforms   = platforms.all;
    };
  };
}
