{ lib, attrs }:

let
  inherit (builtins) attrValues readDir pathExists concatLists;
  inherit (lib) id mapAttrsToList filterAttrs hasPrefix hasSuffix nameValuePair removeSuffix;
in rec {
  mapModules = dir: func:
    attrs.mapFilterAttrs'
      (n: v:
        let path = "${toString dir}/${n}"; in
        if v == "directory" && pathExists "${path}/default.nix"
        then nameValuePair n (func path)
        else if v == "regular" &&
                n != "default.nix" &&
                n != "flake.nix" &&
                hasSuffix ".nix" n
        then nameValuePair (removeSuffix ".nix" n) (fn path)
        else nameValuePair "" null)
      (n: v: v != null && !(hasPrefix "_" n))
      (readDir dir);

  mapModules' = dir: func:
    attrValues (mapModules dir func);

  # dir -> func :: attrs (attrs (attrs ...))
  #
  # Creates a file tree where each leaf is the result of func.
  mapModulesRec = dir: func:
    attrs.mapFilterAttrs'
      (n: v:
        let path = "${toString dir}/${n}"; in
        if v == "directory"
        then nameValuePair n (mapModulesRec path func)
        else if v == "regular" &&
                n != "default.nix" &&
                n != "flake.nix" &&
                hasSuffix ".nix" n
        then nameValuePair (removeSuffix ".nix" n) (func path)
        else nameValuePair "" null)
      (n: v: v != null && !(hasPrefix "_" n))
      (readDir dir);

  # dir -> func :: listOf paths
  #
  # Returns a list of all files under DIR, mapped by func.
  mapModulesRec' = dir: func:
    let
      dirs =
        mapAttrsToList
          (k: _: "${dir}/${k}")
          (filterAttrs
            (n: v: v == "directory"
                   && !(hasPrefix "_" n)
                   && !(pathExists "${dir}/${n}/.noload"))
            (readDir dir));
      files = attrValues (mapModules dir id);
      paths = files ++ concatLists (map (d: mapModulesRec' d id) dirs);
    in map func paths;


}
