{ lib, attrs, modules, ... }:

with builtins;
with lib;
with attrs;
with modules;

rec {
  # mkApp :: program -> { program, type }
  #
  # 构建一个 app 对象，包含 program 和类型。
  mkApp = program: {
    inherit program;
    type = "app";
  };

  # mkPkgs :: system -> nixpkgs -> overlays -> pkgs
  #
  # 根据系统、nixpkgs 和 overlays 构建 pkgs。
  mkPkgs = { system, pkgsPath, overlays ? [] }:
    import pkgsPath {
      inherit overlays;
      system = system;
      config.allowUnfree = true;
    };

  mapHosts = dir:
    mapModules dir (path: {
      inherit path lib;
      config = import path;
    });

  mkHost = { hostName, hostDef, inputs, overlays }:
    let
      path = hostDef.path;

      allNixosModules = filterMapAttrs
        (_: i: i ? nixosModules)
        (_: i: i.nixosModules)
        inputs;

      hostConfig = hostDef.config {
        inherit lib;
        nixosModules = allNixosModules;
        self = inputs.self;
      };

      system = hostConfig.system;

      pkgs = mkPkgs {
        inherit system overlays;
        pkgsPath = inputs.nixpkgs;
      } // {
        unstable = mkPkgs {
          inherit system overlays;
          pkgsPath = inputs.nixpkgs-unstable;
        };
      };

      self' = inputs.self // {
        modules = allNixosModules;
        packages = self.packages.${system};
        devShell = self.devShell.${system};
        apps = self.apps.${system};
      };
    in
      lib.nixosSystem {
        inherit system;
        specialArgs = {
          self = self';
          lib = pkgs.lib.recursiveUpdate pkgs.lib self'.lib;
          inputs = inputs;
          configRoot = self;
        };

        modules =
          [
            inputs.disko.nixosModules.disko

            {
              nixpkgs.pkgs = pkgs;
              # 主机名直接使用定义的名称
              networking.hostName = mkDefault hostName;
            }

            ../blueprint.nix
          ]
          ++ (hostConfig.imports or [])
          ++ [{ modules = hostConfig.modules or {}; }]
          ++ [ (hostConfig.config or {}) (hostConfig.hardware or {}) ]
          ++ (lib.optional (inputs ? storage) (
            if isFunction inputs.storage
            then (attrs: { disko.devices = inputs.storage attrs; })
            else { disko.devices = inputs.storage; }
          ));
      };

   buildPerSystemOutputs = { systems, overlays, inputs, flake, self, lib, ...}:
    let
      outputsForSystem = system:
        let
          pkgs = mkPkgs {
            inherit system overlays lib;
            pkgsPath = inputs.nixpkgs;
          };
          packageBuilder = packageAttrs:
            mapFilterAttrs
              (_: v: pkgs.callPackage v { self = self.packages.${system} or {}; })
              (_: v: !(v ? meta.platforms) || (elem system v.meta.platforms))
              packageAttrs;
        in
          filterAttrs (_: v: v != {}) {
            apps = flake.apps or {};
            checks = packageBuilder (flake.checks or {});
            devShells = packageBuilder (flake.devShells or {});
            packages = packageBuilder (flake.packages or {});
          };
    in
      mergeAttrs' (map (system: mapAttrs (name: value: { ${name}.${system} = value; }) (outputsForSystem system)) systems);

  mkFlake = {
    self,
    nixpkgs ? self.inputs.nixpkgs,
    nixpkgs-unstable ? self.inputs.nixpkgs-unstable or nixpkgs,
    disko ? self.inputs.disko,
    ...
  } @ inputs: {
    hosts ? {},
    overlays ? {},
    packages ? {},
    systems ? [ "x86_64-linux" ],
    lib,
    ...
  } @ flake:
    let
      overlayValues = attrValues (flake.overlays or {});

      nixosConfigurations = mapAttrs
        (hostName: hostDef: mkHost {
          inherit hostName hostDef inputs;
          overlays = overlayValues;
        })
        hosts;

      perSystemOutputs = buildPerSystemOutputs {
        inherit systems self lib;
        flake = flake;
        inputs = inputs;
        overlays = overlayValues;
      };

      passthroughAttrs = filterAttrs (n: _: !elem n [
        "apps" "bundlers" "checks" "devices" "devShells" "hosts" "modules"
        "packages" "storage" "systems"
      ]) flake;

    in
      passthroughAttrs // {
        inherit nixosConfigurations;
        nixosModules = flake.modules or {};
      } // perSystemOutputs;
}
