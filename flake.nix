{
  description = "maojiaxing's nix configuration for NixOS";

  nixConfig = {
    extra-substituters = [
      "https://anyrun.cachix.org"
    ];

    extra-trusted-public-keys = [
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
    ];
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";

    nixpkgs-unstable = {
      url = "nixpkgs/nixos-unstable";
    };

    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = inputs @ { self, nixpkgs, nixos-wsl, home-manager, sops-nix, ... }:
    let
      args = {
        inherit self;
        inherit (nixpkgs) lib;
        pkgs = import nixpkgs {};
      };

      lib = import ./lib args;
    in
      with builtins;
      with lib;
      mkFlake input {
        systems = [ "x86_64-linux" "aarch64-linux" ];
        inherit lib;

        hosts = mapHosts ./hosts;
        modules.default = import ./default.nix;


      };
}
