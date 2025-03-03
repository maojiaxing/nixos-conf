{ inputs, lib, ... }:
let
  makeMachine = lib.makeMachine;
in
makeMachine {
  hostname = "work-machine";
  
  enableGUI = true;

  profiles = [
    ../../profiles/wsl.nix  
  ];

  extraModules = [
    ({ pkgs, ... }: {
      services.nginx.enable = false;
    })
  ];
}
