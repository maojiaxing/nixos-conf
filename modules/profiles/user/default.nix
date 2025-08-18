{ lib, config, ...}:

with lib;
let cfg = config.modules.profiles.user;
  username = cfg.name;
  key = "";
in mkIf (username == "maojiaxing") mkMerge [
  {
    user.name = username;
  }
]
