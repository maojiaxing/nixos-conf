{ lib }:

let
  inherit (lib) mkOption types;
in
rec {
  mkOpt = type: default:
   mkOpt' {
    inherit type default;
    description = "";
   };

  mkOpt' = type: default: description:
  let
    isEnum = lib.isAttr type && type ? "_type" && type._type == "enum";
    in
      mkOption {
        type = if isEnum then lib.types.enum type.values else type;
        inherit default description;
      };

  mkBoolOpt = default: mkOption {
    inherit default;
    type = types.bool;
    example = true;
  };
}
