{ lib, stdenv, unzip, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "lxgw-wenkai";
  version = "1.522";

  src = fetchurl {
    url = "https://github.com/lxgw/LxgwWenKai/releases/download/v${version}/lxgw-wenkai-v${version}.zip";
    hash = "sha256-O1liBUI9g4zNCWW/osfotuvLnZKE4YCeI0rR1fRBre8=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    find . -name '*.ttf' -exec install -Dt $out/share/fonts/truetype {} \;
    find . -name '*.otf' -exec install -Dt $out/share/fonts/opentype {} \;
  '';

  meta = with lib; {
    description = "An open-source Chinese font derived from Klee One (霞鹜文楷)";
    homepage = "https://github.com/lxgw/LxgwWenKai";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
