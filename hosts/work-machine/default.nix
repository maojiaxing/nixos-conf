{ lib, inputs, ... }:

{
  system = "x86_64-linux";

  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

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
