{ lib, config, options, pkgs, inputs, ...}:

with lib;
{
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
  };
}
