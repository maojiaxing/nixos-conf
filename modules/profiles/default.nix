{ lib, options, config, ...}:

{
  options.modules.profiles = {
    hardware = lib.mkOption {
      description = "A list of hardware definition for the custom host.";
      type = lib.types.listOf lib.types.str;
      default = [];
      example = lib.literalExpression '' [ intel ] '';
    };

    platform = lib.mkOption {
      description = "The platform or operating system type for the host.";
      type = lib.types.enum [ "linux" "darwin" "wsl" ];
      default = "linux";
      example = "darwin";
    };

    roles = lib.mkOption {
      description = "A list of roles to apply to the host.";
      type = lib.types.listOf lib.types.str;
      default = [ "base" ];
      example = lib.literalExpression ''[ "base" ]'';
    };

    user = lib.mkOption {
      description = "User-specific attributes, such as name and home directory.";
      type = lib.types.attrs;
      default = { name = "maojiaxing"; };
      example = lib.literalExpression ''{ name = "nix-user"; home = "/home/nix-user"; }'';
    };
  };
  
}
