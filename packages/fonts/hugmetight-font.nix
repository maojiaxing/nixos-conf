{ lib, stdenv, unzip, fetchurl, ... }:

stdenv.mkDerivation rec{
  pname = "hugmetight-font";
  version = "2025-03-01";

  src = fetchurl {
    url = "https://mistifonts.com/fonts/hug-me-tight.zip";
    sha256 = "sha256-GLcAKu9AeYZ8j285ykiwx31Qoja6tZCXQR88CTu27UY=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts
    cp *.ttf $out/share/fonts

    runHook postInstall
  '';

  meta = with lib; {
    description = "The Hug Me Tight font";
    homepage = "https://mistifonts.com/hug-me-tight";
    platforms = platforms.all;
  };
}