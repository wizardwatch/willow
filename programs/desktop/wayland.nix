{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    grimblast
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
