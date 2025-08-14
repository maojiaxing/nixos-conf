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

  hasRole = roleDefinitions: requestedRoles: role:  
    elem role (resolveInheritance roleDefinitions requestedRoles);
in {
  inherit resolveInheritance hasRole;
}
  