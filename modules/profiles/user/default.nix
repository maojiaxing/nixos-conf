{ lib, config, ...}:

with lib;
let cfg = config.modules.profiles;
  username = cfg.name;
  key = "";
in {
  user.username = username;
}
