{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, ... }@inputs: {
    
    nixosConfigurations.work-machine = nixpkgs.lib.nixosSystem {
      
      system = "x86_64-linux";
      
      specialArgs = { inherit inputs; };

      modules = [ 
        nixos-wsl.nixosModules.default
        ./configuration.nix
      ];
    };
  };
}
