final: _prev:
{
  theme-switch = final.writeShellApplication {
    name = "theme-switch";

    runtimeInputs = with final; [
      jq
      fzf
      libnotify
      coreutils
    ];

    text = builtins.readFile ./theme-switch.sh;
  };
}
