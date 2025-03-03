{ inputs, lib, ...}: 

{
  makeMachine = import ./make-machine.nix { inherit inputs lib; };
}
