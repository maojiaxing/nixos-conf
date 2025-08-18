{ lib, config, ...}:

with lib;
let cfg = config.modules.profiles.user;
  username = cfg.name;
  key = "";
in
mkMerge [
  (mkIf (username == "maojiaxing") {
    user.name = username;
    user.home = "/home/${username}";
  })
]
