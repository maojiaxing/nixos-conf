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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs":
    }

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, ... }@inputs: 
    let 
      hosts = builtins.attrNames (builtins.readDir ./hosts);

      load = host: import(./host + "${host}/default.nix") {
        inherit inputs nixos-wsl;
        lib = nixpkgs.lib;
      };
    in  
    {
      nixosConfigurations= builtins.listToAttrs (map (host: {
        name = host;
        value = loadHost host;
      }) hosts);
    };
}
