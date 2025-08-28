{ lib, config, options, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop = {
    type = mkOpt (types.nullOr types.str) null;
    apps = mkOpt (types.listOf types.str) [ ];
  };

  config = mkMerge [
    {
      assertions = 
        let 
          isEnabled = _: v: v.enable or false;
          hasEnableOption = cfg: (anyAttrs isEnabled cfg) || !(anyAttrs (_: v: isAttrs v && anyAttrs isEnabled v) cfg);
        in [
          {
            assertion = (countAttrs isEnabled cfg) < 2;
            message = "Can't have more then on desktop env enabled at a time";
          }

        ];
    }
  ];
}
