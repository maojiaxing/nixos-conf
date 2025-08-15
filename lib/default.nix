{ self, lib, pkgs, ...}:

let
  inherit (builtins) mapAttrs intersectAttrs functionArgs getEnv fromJSON;
  inherit (lib) attrValues foldr foldl;

  # mapModules gets special treatment because it's needed early!
  attrs   = import ./attrs.nix   { inherit lib; };
  modules = import ./modules.nix { inherit lib attrs; };

  inherit (attrs) attrsToList mergeAttrs';
  inherit (modules) mapModules;

  sortLibsByDeps = modules:
    modules;

  libConcat = a: b: a // {
    ${b.name} = b.value (intersectAttrs (functionArgs b.value) a);
  };

  libModules = sortLibsByDeps (mapModules ./. import);
  # 先定义一个初始值，不递归引用 self，避免循环引用
  libsInit = { inherit lib pkgs; };
  libs = foldl libConcat libsInit (attrsToList libModules);
in
  let
    safeAttrValues = v: if builtins.isAttrs v then attrValues v else [];
    merged = mergeAttrs' (safeAttrValues libs);
  in
    (if builtins.isAttrs libs then libs else {}) // merged
