{ lib, ... }:

{

  modules = {
    profiles = {
      platform = "wsl";
      user.name = "maojiaxing";
    };
    
    xdg.ssh.enable = true;
  };

  #   hardware = {
  #     cpu = "intel";
  #   };
  # };
}
