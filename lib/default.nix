{ self, lib, pkgs, ...}:

let
  inherit (builtins) mapAttrs intersectAttrs functionArgs getEnv fromJSON;
  inherit (lib) attrValues foldr foldl;

  # mapModules gets special treatment because it's needed early!
  inherit (attrs) attrsToList mergeAttrs';
  inherit (modules) mapModules;
  attrs   = import ./attrs.nix   { inherit lib; };
  modules = import ./modules.nix { inherit lib attrs; };

  libConcat = a: b: a // {
    ${b.name} = b.value (intersectAttrs (functionArgs b.value) a);
  };

  libModules = mapModules ./. import;
  libs = foldl libConcat { inherit lib pkgs; self = libs; } (attrsToList libModules);
in
  libs // (mergeAttrs' (attrValues libs))
