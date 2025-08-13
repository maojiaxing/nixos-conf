{ lib, config, ...}:

with lib;
let cfg = config.modules.profiles;
  username = cfg.username;
  key = ""
in {
  user.username = username;
  user.key = key;
}
