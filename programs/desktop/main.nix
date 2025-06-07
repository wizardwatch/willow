{ pkgs, ... }:
{
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    freecad-wayland
    pinokio
    signal-desktop
    pdfarranger
    prismlauncher
    appimage-run
    vesktop
    mpvpaper
    zed-editor
    openscad
    eww
    pavucontrol
    ## pipewire equalizer
    qpwgraph
    ## if only i could draw
    krita
    prusa-slicer
    # depended on old electron
    #logseq
    rust-analyzer
    nixd
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    })
  ];
  imports = [
    ./school.nix
    ./wayland.nix
  ];
}
