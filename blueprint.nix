{ self, lib, config, options, pkgs, ...}:

with lib;
{
  imports = mapModulesRec' ./modules import;

  options = with types; {
    modules = {};

    user = {
      name = mkOpt' str "maojiaxing" "The name of the primary user.";
      programs = mkOpt' attrs {} "A list of programs to be installed for the user.";
      packages = mkOpt' (listOf package) [] "A list of packages to be installed for the user.";
    };
  };

  config = {
    assertions = [
      {
        assertion = config.user ? name;
        message = "config.user.name is not set!";
      }
    ];

    users.users.${config.user.name} = {
      description = mkDefault "The primary user account";
      extraGroups = [ "wheel" ];
      isNormalUser = true;
      home = "/home/${config.user.name}";
      group = "users";
      uid = 1000;
    };
  };
}
