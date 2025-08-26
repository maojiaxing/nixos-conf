{ lib, config, options, pkgs, inputs, ...}:

with lib;
let 

  layout = config.modules.hardware.storage.layout;

  findTypes = typeName: layoutNode:
    if ! isAttrs layoutNode then false
    else if elem layoutNode.type typeName then true
    else any (findTypes typeName) (attrValues layoutNode);

  collectFilesystems = layoutNode:
    if ! isAttrs layoutNode then [ ]
    else (
      (if layoutNode.type == "btrfs" then [ "btrfs" ] else [ ]) ++
      (if elem layoutNode.type [ "zfs" "zfs_fs" ] then [ "zfs" ] else [ ]) ++
      (if layoutNode.type == "filesystem" && layoutNode ? "format" then [ layoutNode.format ] else [ ]) ++
      (concatMap collectFilesystems (attrValues layoutNode))
    );

in {
  imports = [ inputs.disko.nixosModules.disko ];

}
