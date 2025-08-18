{ lib, ... }:

let
  inherit (lib) mkOption types isAttr;
in
rec {
  mkOpt = type: default: mkOpt' type default "";

  mkOpt' = type: default: description:
  let
    isEnum = isAttr type && type ? "_type" && type._type == "enum";
    in
      mkOption {
        type = if isEnum then types.enum type.values else type;
        inherit default description;
      };

  mkBoolOpt = default: mkOption {
    inherit default;
    type = types.bool;
    example = true;
  };
}
