{ lib, config, options, ... }: 

with lib;
let cfg = config.modules.system.gc;
in {
  options.modules.system.gc = {
    enable = mkBoolOpt true;
  };

  mkIf (config.modules.system.gc.enable == true) {
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  systemd = {
    services.clear-log = {
      description = "Clear >1 month-old logs every week";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/journalctl --vacuum-time=21d";
      };
    };

    timers.clear-log = {
      wantedBy = [ "timers.target" ];
      partOf = [ "clear-log.service" ];
      timerConfig.OnCalendar = "weekly UTC";
    };
  };
}
}



