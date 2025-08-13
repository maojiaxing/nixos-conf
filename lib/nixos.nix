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

  mkFlake = {
    self,

  } @ input: {
    packages ? {},
    overlays ? {},
    modules ? {},
    hosts ? {}
  } @ flake: 
    let 

    in 
}