{ lib, stdenv, unzip, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "maple-mono-nf-cn";
  version = "7.9";

  src = fetchurl {
    url = "https://github.com/subframe7536/maple-font/releases/download/v${version}/MapleMono-NF-CN.zip";
    hash = "sha256-r5E7YyKQU0iz9Q5Dl/7cNbOogNte/8znlpADBR3NPpQ=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    find . -name '*.ttf' -exec install -Dt $out/share/fonts/truetype {} \;
    find . -name '*.otf' -exec install -Dt $out/share/fonts/opentype {} \;
  '';

  meta = with lib; {
    description = "Maple Mono with Nerd Font icons and CJK support (NF-CN variant)";
    homepage = "https://github.com/subframe7536/maple-font";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
