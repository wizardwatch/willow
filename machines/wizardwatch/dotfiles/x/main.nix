{ config, pkgs, ... }:{
  home.packages = with pkgs; [
    dmenu
    flameshot
  ];
  imports = [
          ./qtile/main.nix
          #./xmonad/main.nix
        ]; 
}
