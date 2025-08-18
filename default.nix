{ self, lib, config, options, pkgs, ...}:

with lib;
{
  imports = mapModulesRec' ./modules import;

  options = with types; {
    modules = {};

    user.name = mkOption {
      description = "The name of the primary user.";
      type = str;
      default = "maojiaxing";
      example = "nix-user";
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

    fileSystems."/".device = mkDefault "/dev/disk/by-label/nixos";
  };
}
