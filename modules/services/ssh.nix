{ lib, config, options, pkgs, ...}:

with lib;
let cfg = config.modules.services.ssh;
in {
    options.modules.services.ssh = {
        enable = mkBoolOpt false;
    };

    config = mkIf cfg.enable {
        systemd.user.tmpfiles.rules = [ "d %h/.config/ssh 700 - - - -" ];

        services.openssh {
            enable = true;

            settings = {
                KbdInteractiveAuthentication = false;

                PasswordAuthentication = false;
            };

            extraConfig = ''GSSAPIAuthentication no'';

            hostKeys = [
                {
                    comment = "${config.networking.hostName}.local";
                    path = "/etc/ssh/ssh_host_ed25519_key";
                    rounds = 100;
                    type = "ed25519";
                }
            ];
        };
    };
}