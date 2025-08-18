{ lib, ... }:

{
  system = "x86_64-linux";

  modules = {
    profiles = {
      platform = "linux";
      user.name = "maojiaxing";
    };
  };

  #   hardware = {
  #     cpu = "intel";
  #   };
  # };
}
