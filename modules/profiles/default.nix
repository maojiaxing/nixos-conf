{ lib, options, config, ...}:

with lib;
{
  options.modules.profiles = {
    hardware = mkOpt' types.attrs {} "A set of hardware definition for the custom host.";
    platform = mkOpt' (types.enum [ "linux" "darwin" "wsl" ]) "linux" "The platform or operating system type for the host.";
    roles = mkOpt' (types.listOf types.str) [ "base" ] "A list of roles to apply to the host.";
  };    
}
