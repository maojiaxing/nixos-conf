{ self, lib, attrs, modules }:

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

  # mapHosts :: dir -> attrs
  #
  # 遍历指定目录下的主机模块，导入配置。
  mapHosts = dir:
    mapModules dir (path: {
      inherit path;
      config = import path;
    });

  # mkPkgs :: system -> nixpkgs -> overlays -> pkgs
  #
  # 根据系统、nixpkgs 和 overlays 构建 pkgs。
  mkPkgs = system: nixpkgs: overlays: import nixpkgs {
    inherit system overlays;

    config.allUnfree = true;
  };

  # mkHostConfig :: inputs -> overlays -> hostname -> {path, config} -> nixosSystem
  #
  # 构建单个主机的 nixosSystem 配置。
  mkHostConfig = inputs: overlays: hostname: {path, config}:
    let
      system = config.system or "x86_64-linux";
      pkgs = mkPkgs system inputs.nixpkgs overlays;

      selfArgs = inputs.self // {
        dir = toString input.self;
        rev = inputs.self.rev or "dirty";
        inherit (inputs) inputs;
        packages = inputs.self.packages.${system} or {};
        apps = inputs.self.apps.${system} or {};
        devShells = inputs.self.devShells.${system} or {};
      };

      host = config { inherit lib; self = selfArgs;};
      storage = inputs.flake.storage.${hostName} or {};
    in
      lib.nixosSystem {
        inherit system;

        specialArgs = {
          self = selfArgs;
        };

        modules = [
          inputs.disko.nixosModules.disko

          (if isFunction storage
           then (attrs: { disko.devices = storage attrs; })
           else { disko.devices = storage; })
          {
            nixpkgs.pkgs = pkgs;
            networking.hostName = mkDefault hostName;
          }

          ../default.nix
        ]
        ++ (host.imports or [])
        ++ [ { modules = host.modules or {}; } ]
        ++ [ (host.config or {}) (host.hardware or {}) ];
      };

  # mkSystemPackages :: system -> nixpkgs -> overlays -> packageAttrs -> pkgs
  #
  # 构建系统包集合，按平台过滤。
  mkSystemPackages = system: nixpkgs: overlays: packageAttrs:
    let
      pkgs = mkPkgs system nixpkgs overlays;
      withPkgs = mapFilterAttrs
        (_: v: pkgs.callPackage v {
          self = self.packages.${system} or {};
        })
        (_: v: !(v ? meta.platforms) || (elem system v.meta.platforms))
        packageAttrs;
    in
      withPkgs;

  # mkSystemOutput :: inputs -> flake -> overlays -> systems -> attrs
  #
  # 构建跨系统输出，包含 apps、checks、devShells、packages。
  mkSystemOutput = inputs: flake: overlays: systems:
    map (system:
      filterAttrs (_: v: v.${system} != {}) {
        apps.${system} = flake.apps or {};
        checks.${system} = mkSystemPackages system inputs.nixpkgs overlays (flake.checks or {});
        devShells.${system} = mkSystemPackages system inputs.nixpkgs overlays (flake.devShells or {});
        packages.${system} = mkSystemPackages system inputs.nixpkgs overlays (flake.packages or {});
      }
    ) systems;

  # mkFlake :: inputs -> flake -> attrs
  #
  # 构建 flake 输出，包含主机配置和跨系统输出。
  mkFlake = inputs: flake:
    let
      overlays = attrValues (flake.overlays or {});
      systems = flake.systems or [ "x86_64-linux" ];

      # 构建host配置
      nixosConfigurations = mapAttrs
        (mkHostConfig inputs overlays)
        (flake.hosts or {});

      # 构建跨系统输出
      systemOutputs = mkSystemOutputs inputs flake overlays systems;

       # 过滤并保留其他 flake 属性
      passthroughAttrs = filterAttrs (n: _: !elem n [
        "apps" "bundlers" "checks" "devices" "devShells" "hosts" "modules"
        "packages" "storage" "systems"
      ]) flake;

    in
      passthroughAttrs
      // { inherit nixosConfigurations; nixosModules = flake.modules or {}; }
      // (mergeAttrs' systemOutputs);
}
