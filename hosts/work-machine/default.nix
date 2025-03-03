{ inputs, lib, ... }:
let
  makeMachine = lib.makeMachine;
in
makeMachine {
  hostname = "work-machine";
  enableGUI = true;

  profiles = [
    ../../profiles/development.nix  
  ];

  extraModules = [
    ({ pkgs, ... }: {
      services.nginx.enable = true;
    })
  ];
}
