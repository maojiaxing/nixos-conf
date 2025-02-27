{
  description = "maojiaxing's nix configuration for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = github:numtide/flake-utils";
    
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, ... }@inputs: 
    let 
      hosts = builtins.attrNames (builtins.readDir ./hosts);

      load = host: import(./host + "${host}/default.nix") {
        inherit inputs;
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
