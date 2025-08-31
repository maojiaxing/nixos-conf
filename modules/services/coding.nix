{ lib, config, options, pkgs, ...}:

with lib;
let
  cfg = config.modules.services.vscode-server;
in {
  options.modules.services.vscode-server = {
    enable = mkBoolOpt false;
    port = mkOpt types.int 3000;
    auth = mkOpt types.str "password";
    withoutConnectionToken = mkBoolOpt false;
    acceptServerLicenseTerms = mkBoolOpt false;
    extraSettings = mkOpt types.attrs {};
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.acceptServerLicenseTerms;
        message = "You must accept the VSCode Server license terms by setting acceptServerLicenseTerms = true";
      }
    ];
 
  };
}
