{ lib, config, ...}:

with lib;
let cfg = config.modules.profiles.user;
  username = cfg.name;
  key = "";
in {
  user.username = username;
}
