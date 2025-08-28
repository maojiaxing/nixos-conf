{ lib, ... }:

{

  modules = {
    profiles = {
      platform = "wsl";
    };
    
    desktop.apps = [ "kitty" ];
  };

  #   hardware = {
  #     cpu = "intel";
  #   };
  # };
}
