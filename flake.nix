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

    #flake-utils = {
    #  url = "github:numtide/flake-utils";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, sops-nix, ... }@inputs:

    let
      # 初始化架构特定包集合
      #pkgs = nixpkgs.legacyPackages.${system};

      # 安全的路径拼接方式
      hostPath = host: ./hosts/${host};

      extendedLib = inputs.nixpkgs.lib // import ./lib/default.nix { inherit inputs; inherit (nixpkgs) lib; };

      getHosts = dir:
        let
          entries = builtins.readDir dir;
          isDirectory = name: type: type == "directory";
        in
        builtins.attrNames (nixpkgs.lib.filterAttrs isDirectory entries);

      # 动态加载主机配置
      loadHost = host:
        let
          configFile = hostPath host + "/default.nix";
        in
        if builtins.pathExists configFile then
          import configFile {
            inherit inputs;

            specialArgs = {
              inherit nixos-wsl home-manager sops-nix makeMachine;
              hostRoot = hostPath host;
            };

            lib = extendedLib;
          }
        else
          throw "Host configuration missing: ${toString configFile}";

    in {
      nixosConfigurations = nixpkgs.lib.genAttrs (getHosts ./hosts) loadHost;
    };
}
