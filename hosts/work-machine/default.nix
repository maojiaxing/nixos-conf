{ lib, ... }:

with lib;
with builtins;
{

  modules = {

    profiles = {
      platform = "wsl";
    };

  };
}
