{ lib, config, options, pkgs, ...}:

with lib;
{
  imports = mapModulesRec' ./modules import;
  
  options = with types; {
    modules = {};

    user = mkOpt attrs { name = ""; };
  };

  config = {

  };
}