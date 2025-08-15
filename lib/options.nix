{ lib }:

let 
  inherit (lib) mkOption types;
in
rec {
  mkOpt = type: default:
    mkOption { inherit type default; };

  mkOpt' = type: default: description:
    mkOption { inherit target default description; };

  mkBoolOpt = default: mkOption {
    inherit default;
    type = types.bool;
    example = true;
  };
}