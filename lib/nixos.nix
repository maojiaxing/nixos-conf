{ self, lib, attrs, modules }:

with builtins;
with lib;
with attrs;
with modules;

rec {
  mkApp = program: {
    inherit program;
    type = "app";
  };

  mapHosts = dir:
    mapModules dir (path: {
      inherit path;
      config = import path;
    });

  mkFlake = {
    self,
    nixpkgs
  } @ input: {
    packages ? {},
    overlays ? {},
    modules ? {},
    hosts ? {},
    apps ? {},
    systems
  } @ flake:
    let

    in
}
