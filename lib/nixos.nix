{ lib, attrs, modules, pkgs, ... }:

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

  mkWrapper = package: postBuild:
    let 
      name  = if lib.isList package then elemAt package 0 else package;
      paths = if lib.isList package then package else [ package ];
    in pkgs.symlinkJoin {
      inherit paths postBuild;
      name = "${name}-wrapped";
      buildInputs = [ pkgs.makeWrapper ];
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

      system = hostConfig.system or "x86_64-linux";

      pkgs = mkPkgs {
        inherit system overlays;
        pkgsPath = inputs.nixpkgs;
      };
      
      unstable-pkgs = mkPkgs {
        inherit system overlays;
        pkgsPath = inputs.nixpkgs-unstable;
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
          configRoot = inputs.self;
          unstable-pkgs = unstable-pkgs;
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
     
      #tracedOverlays = builtins.trace "Loaded overlays: ${toString (builtins.attrNames flake.overlays)}" overlayValues;

      nixosConfigurations = mapAttrs
        (hostName: hostDef: mkHost {
          inherit hostName hostDef inputs lib;
          overlays = overlayValues;
        })
        hosts;

      perSystemOutputs = buildPerSystemOutputs {
        inherit systems self lib;
        flake = flake;
        inputs = inputs;
        overlays = overlayValues;
      };

      elems = [ "apps" "bundlers" "checks" "devices" "devShells" "hosts" "modules" "packages" "storage" "systems" ];
      passthroughAttrs = filterAttrs (n: _: !elem n elems) flake;

    in
      passthroughAttrs // {
        inherit nixosConfigurations;
        nixosModules = flake.modules or {};
      } // perSystemOutputs;
}
