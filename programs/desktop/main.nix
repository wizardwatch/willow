{ config, pkgs, lib, trunk, home-manager, self, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    appimage-run
    vesktop
    mpvpaper
    zed-editor
    breeze-icons
    openscad
    eww
    pavucontrol
    ## pipewire equalizer
    easyeffects
    qpwgraph
    ## if only i could draw
    krita
    prusa-slicer
    # depended on old electron
    #logseq
  ];
  imports = [
    ./school.nix
    ./wayland.nix
  ];
}
