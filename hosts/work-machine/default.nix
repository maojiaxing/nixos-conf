{ lib, inputs, ... }:

{
  system = "x86_64-linux";

  modules = {
    profiles = {
      platform = "wsl";
      user.name = "maojiaxing";
    };
  };

  #   hardware = {
  #     cpu = "intel";
  #   };
  # };
}
