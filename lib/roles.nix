{ lib, ...}:

with lib;
let
  resolveInheritance = roleDefinitions: requestedRoles:
    let
      expandRole = role:
        let
          roleDef = roleDefinitions.${role} or { inherits = []; };
          parents = roleDef.inherits or [];
        in [ role ] ++ (flatten (map expandRole parents));
    in unique (flatten (map expandRole requestedRoles));
in {
  mkRoles = roleDefinitions: requestedRoles:
    let
      expandedRoles = resolveInheritance roleDefinitions requestedRoles;
    in {
      list = expandedRoles;
      has = role: elem role expandedRoles;
    };
}
