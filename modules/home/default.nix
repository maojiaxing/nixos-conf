{lib, config, options, pkgs, inputs, ...}:

with lib;
let
  cfg = config.home;
in {
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  options.home = with lib.types; {
    file       = mkOpt' attrs {} "Files to place directly in $HOME";
    configFile = mkOpt' attrs {} "Files to place in $XDG_CONFIG_HOME";
    dataFile   = mkOpt' attrs {} "Files to place in $XDG_DATA_HOME";
    fakeFile   = mkOpt' attrs {} "Files to place in $XDG_FAKE_HOME";

    homeDir    = mkOpt str "/home/${config.user.name}";
    configDir  = mkOpt str "/home/${config.user.name}/.config";
    cacheDir   = mkOpt str "/home/${config.user.name}/.cache";
    binDir     = mkOpt str "/home/${config.user.name}/.local/bin";
    dataDir    = mkOpt str "/home/${config.user.name}/.local/share";
    stateDir   = mkOpt str "/home/${config.user.name}/.local/state";
    fakeDir    = mkOpt str "/home/${config.user.name}/.local/user";

    # preserveConfigPaths = mkOpt (attrsOf (listOf str)) { paths = [ "nixos" ];} "Per-directory cleanup exclude list";  
  };

  config = {
    environment = {
      localBinInPath = true;

      sessionVariables = mkOrder 10 {
        # These are the defaults, and xdg.enable does set them, but due to load
        # order, they're not set before environment.variables are set, which
        # could cause race conditions.
        XDG_BIN_HOME    = cfg.binDir;
        XDG_CACHE_HOME  = cfg.cacheDir;
        XDG_CONFIG_HOME = cfg.configDir;
        XDG_DATA_HOME   = cfg.dataDir;
        XDG_STATE_HOME  = cfg.stateDir;

        # This is not in the XDG standard. It's my jail for stubborn programs,
        # like Firefox, Steam, and LMMS.
        XDG_FAKE_HOME = cfg.fakeDir;
        XDG_DESKTOP_DIR = cfg.fakeDir;
      };
    };

    home.file =
      mapAttrs' (k: v: nameValuePair "${cfg.fakeDir}/${k}" v)
        cfg.fakeFile;

     home-manager = {
      useUserPackages = true;

      users.${config.user.name} = {
        home = {
          file = mkAliasDefinitions options.home.file;
          stateVersion = config.system.stateVersion;
        };

        xdg = {
          configFile = mkAliasDefinitions options.home.configFile;
          dataFile   = mkAliasDefinitions options.home.dataFile;

          # Force these, since it'll be considered an abstraction leak to use
          # home-manager's API anywhere outside this module.
          cacheHome  = mkForce cfg.cacheDir;
          configHome = mkForce cfg.configDir;
          dataHome   = mkForce cfg.dataDir;
          stateHome  = mkForce cfg.stateDir;
        };
      };
    };

    system.activationScripts.cleanupConfigDir = 
      let
        #excludeExpr = concatStringsSep " " (map (name: "! -name '${name}'") (cfg.preserveConfigPaths.paths or []));
        cfga = config.home;
      in ''
        # --- Automated cleanup script ---
        # The goal of this script is to delete all content in the ~/.config/ directory,
        # while preserving the 'nixos' directory.

        CONFIG_DIR="${cfg.configDir}"

        if [ -d "$CONFIG_DIR" ]; then
          echo "Cleaning up the $CONFIG_DIR directory..."

          ${pkgs.findutils}/bin/find "$CONFIG_DIR" -mindepth 1 -maxdepth 1 ! -name nixos -exec rm -rf '{}' +

          echo "Cleanup completed. All files in "$CONFIG_DIR" except for 'nixos' have been deleted."
        fi
      '';

  };
}
