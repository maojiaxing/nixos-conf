{ lib, stdenv, unzip, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "victor-mono";
  version = "1.5.6";

  src = fetchurl {
    url = "https://rubjo.github.io/victor-mono/VictorMonoAll.zip";
    hash = "sha256-v2m9cZ+wDMtQPnV03wfczCV/Hz+EF1JrZCES9deqPwI=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    find . -name '*.ttf'   -exec install -Dt $out/share/fonts/truetype {} \;
    find . -name '*.otf'   -exec install -Dt $out/share/fonts/opentype {} \;
    find . -name '*.woff'  -exec install -Dt $out/share/fonts/woff   {} \;
    find . -name '*.woff2' -exec install -Dt $out/share/fonts/woff2  {} \;
  '';

  meta = with lib; {
    description = "Free programming font with cursive italics and symbol ligatures";
    homepage = "https://rubjo.github.io/victor-mono/";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
