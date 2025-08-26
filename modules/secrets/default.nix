{ lib, config, optins, pkgs, inputs, configRoot, ... }: 

with lib;
let
  hostKey = "/etc/nixos/secrets/host.key";
in {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  options.modules.secrets = with types; {
    dirs = mkOpt (listOf (either str path)) [ 
      "${configRoot}/config/secrets"
      "/etc/nixos/secrets" 
    ]
  }; 

  config = {
    assertions = [
      {
        assertion = config.age.secrets = {} || (pathExists hostKey)
      }
    ];

    programs.ssh.extraConfig = ''
      Host *
        IdentityFile ${hostKey}
    '';

    age = {
      identityPaths = [ hostKey ];
      secrets = foldl (a: b: a // b) {}
        (map (dir: mapAttrs'
          (n: v: nameValuePair (removeSuffix ".age" n) {
            file = "${dir}/${n}";
            owner = mkDefault config.user.name;
          })
          (import "${dir}/secrets.nix"))
          (filter (dir: pathExists "${dir}/secrets.nix")
            config.modules.agenix.dirs));
    };

    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "agenix" ''
        ARGS=( "$@" )
        ${optionalString config.modules.xdg.ssh.enable ''
          if [[ "''${ARGS[*]}" != *"--identity"* && "''${ARGS[*]}" != *"-i"* ]]; then
            for hostkey in "${hostKey}"; do
              if [[ -f "$hostkey" ]]; then
                ARGS=( --identity "$hostkey" "''${ARGS[@]}" )
              fi
            done
          fi
        ''}

        exec ${inputs.agenix.packages.${system}.default}/bin/agenix "''${ARGS[@]}"
      '')
    ];
  };
}
