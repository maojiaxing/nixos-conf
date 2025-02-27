{ inputs, lib, ... }:
let
  makeMachine = inputs.self.lib.makeMachine;
in
makeMachine {
  hostname = "work-machine";
  enableGUI = true;

  profiles = [
    ../../profiles/development.nix  # 共享 Profile
  ];

  extraModules = [
    ({ pkgs, ... }: {  # 直接内联模块
      services.nginx.enable = true;
    })
  ];
}
