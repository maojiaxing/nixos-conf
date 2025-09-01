{ lib, config, options, unstable-pkgs, ...}:

with lib;
let
  cfg = config.modules.services.vscode-server;
in {
  options.modules.services.vscode-server = {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.acceptServerLicenseTerms;
        message = "You must accept the VSCode Server license terms by setting acceptServerLicenseTerms = true";
      }
    ];
 
    user.packages = with unstable-pkgs;[
      vscode-fhs
    ];

  };
}
