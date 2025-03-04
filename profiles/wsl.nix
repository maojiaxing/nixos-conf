{ config, inputs, pkgs, ... }: 

{
  imports = [ 
    inputs.nixos-wsl.nixosModules.default 
  ];

  system.stateVersion = "24.11";
   
  wsl = {
    enable = true;
    defaultUser = "maojiaxing";
    useWindowsDriver = true;
    startMenuLaunchers = true;
  };

  environment.systemPackages = with pkgs; [ 
    vim 
    git 
    curl 
    zsh 
    (pkgs.warp-terminal.override { waylandSupport = true; })
  ];

  hardware.graphics.enable = true;

  
}
