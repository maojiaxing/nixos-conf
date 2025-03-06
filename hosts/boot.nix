{ inputs, home-manager, ... }: 

{

    
  home-manager.nixosModules.home-manager {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.myuser = import ./home/profiles/default.nix;
      extraSpecialArgs = { inherit inputs; };
    };
  };
}
