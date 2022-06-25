{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    dmenu
    flameshot
    maim
    xclip
    i3lock
  ];
  imports = [
    ./qtile/main.nix
    #./xmonad/main.nix
  ];
}
