{ lib, ... }:

{
  system = "x86_64-linux";

  user.name = "maojiaxing";

  modules = {
    profiles = {
      platform = "wsl";

      user.name = "maojiaxing";
    };

    hardware = {
      cpu = "intel";
    };
  };
}
