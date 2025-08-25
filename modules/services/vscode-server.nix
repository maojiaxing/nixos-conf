{ lib, config, options, pkgs, ...}:

with lib;
let
  cfg = config.modules.services.vscode-server;
in {
  options.modules.services.vscode-server = {
    enable = mkBoolOpt false;
    port = mkOpt types.int 3000;
    host = mkOpt types.str "localhost";
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

    home.packages = [ pkgs.vscode-server ];

    systemd.user.services.vscode-server = {
      Unit = {
        Description = "VSCode Server";
        After = [ "network.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.vscode-server}/bin/code-server \
            --port ${toString cfg.port} \
            --host ${cfg.host} \
            --auth ${cfg.auth} \
            ${lib.optionalString cfg.withoutConnectionToken "--without-connection-token"} \
            --config ${config.home.configDir}/vscode-server/config.yaml \
            --user-data-dir ${config.home.dataDir}/vscode-server \
            --extensions-dir ${config.home.dataDir}/vscode-server/extensions
        '';
        Restart = "always";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    home.file = {
      "${config.home.configDir}/vscode-server/config.yaml" = {
        text = lib.generators.toYAML {} ({
          bind-addr = "${cfg.host}:${toString cfg.port}";
          auth = cfg.auth;
          cert = false;
        } // cfg.extraSettings);
      };

      "${config.home.configDir}/vscode-server/settings.json" = {
        text = builtins.toJSON {
          "workbench.colorTheme" = "Default Dark Modern";
          "telemetry.telemetryLevel" = "off";
          "update.mode" = "none";
        };
      };
    };

    systemd.user.tmpfiles.rules = [
      "d ${config.home.configDir}/vscode-server 700 - - - -"
      "d ${config.home.dataDir}/vscode-server 700 - - - -"
      "d ${config.home.dataDir}/vscode-server/extensions 700 - - - -"
    ];
  };
}