{ self, lib, config, options, pkgs, ...}:

with lib;
{
  imports = mapModulesRec' ./modules import;

  options = with types; {
    modules = {};

    user = mkOption {
      description = "User-specific attributes, such as name and home directory.";
      type = attrs;
      default = { name = ""; };
    };
  };

  config = {
    # assertions = [
    #   {
    #     assertion = config.user ? name;
    #     message = "config.user.name is not set!";
    #   }
    # ];

    user = {
      description = mkDefault "The primary user account";
      extraGroups = [ "wheel" ];
      isNormalUser = true;
      home = "/home/${config.user.name}";
      group = "users";
      uid = 1000;
    };

    users.users.${config.user.name} = mkAliasDefinitions options.user;
  };
}
