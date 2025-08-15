{ self, lib, pkgs, ...}:

let
  inherit (builtins) mapAttrs intersectAttrs functionArgs getEnv fromJSON;
  inherit (lib) attrValues foldr foldl;

  # mapModules gets special treatment because it's needed early!
  inherit (attrs) attrsToList mergeAttrs';
  inherit (modules) mapModules;
  attrs   = import ./attrs.nix   { inherit lib; };
  modules = import ./modules.nix { inherit lib attrs; };

  sortLibsByDeps = modules:
    modules;

  libConcat = a: b: a // {
    ${b.name} = b.value (intersectAttrs (functionArgs b.value) a);
  };

  libModules = sortLibsByDeps (mapModules ./. import);
  libs = foldl libConcat { inherit lib pkgs; self = libs; } (attrsToList libModules);
in
  (if builtins.isAttrs libs then libs else {}) // (mergeAttrs' (attrValues libs))
