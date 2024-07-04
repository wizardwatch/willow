{ config, pkgs, lib, trunk, home-manager, self, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    alacritty
    mpv
    gimp
    xdg-desktop-portal-hyprland
    grim
    slurp
    wl-clipboard
    seatd
    wlr-randr
    swaylock
    ## desktop notifications
    libnotify
  ];
  security = {
    polkit.enable = true; #for river maybe
    pam.services.swaylock = { };
  };
  programs = {
    seahorse.enable = true;
    dconf.enable = true;
    steam.enable = true;
    hyprland.enable = true;
  };
  xdg = {
    portal = {
      enable = true;
    };
  };
}
