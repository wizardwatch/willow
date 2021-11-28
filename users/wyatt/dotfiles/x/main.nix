{ config, pkgs, ... }:{
  home.packages = with pkgs; [
    dmenu
    flameshot
    maim
    xclip
  ];
  imports = [
          ./qtile/main.nix
          #./xmonad/main.nix
        ]; 
}
