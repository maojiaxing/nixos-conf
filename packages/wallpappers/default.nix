{ lib, stdenvNoCC, fetchurl, ...}: 

let 
  wallpappers = { path, exclude ? [ "default.nix" ] }:
    let
      dirContents = readDir path;
      fileNames = attrNames dirContents;
    in map
      (fileName: import (path + "/${fileName}"))
      (filter
        (fileName:
          hasSuffix ".nix" fileName && !(elem fileName exclude)
        )
        fileNames
      );
in stdenvNoCC.mkDerivation {
  name = "wallpapers";

  srcs = map fetchurl wallpapers { paht = ./.};

  installPhase = ''
    install -d $out

    ${lib.strings.concatStringsSep "\n" (
      map (w: ''
        # 对每个壁纸，获取其下载后的路径，并使用其 'name' 属性作为目标文件名
        # 注意对文件名进行转义，以防包含特殊字符
        ln -s "${fetchurl w}" "$out/${w.name}"
      '') wallpapers
    )}
  '';
  
  meta = {
    description = "Packaged wallpapers";
  };
}