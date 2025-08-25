{ lib, config, options, unstable-pkgs, ...}:

with lib;
let 
  cfg = config.modules.shell.claude;
in {
  options.modules.shell.claude = with types; {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {

    home.config.preserveDirs = {
      claude = [ "claude-code" ];
    };

    environment = {
      systemPackages = with unstable-pkgs; [
        claude-code
      ];

      variables = {
        CLAUDE_CONFIG_HOME = "$XDG_CONFIG_HOME/claude-code";
      };
    };
  };
}
