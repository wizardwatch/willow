{
  pkgs,
  inputs ? {},
  lib,
  host ? {isDesktop = false;},
  ...
}: let
  # Only use this module if we're on a desktop system
  isDesktop = host.isDesktop or false;
in {
  # Only import these modules on desktop systems
  imports =
    if isDesktop
    then [
      ./hyprland.nix
      ./anyrun.nix
      ./waybar.nix
      ./clipse
      ./cava.nix
    ]
    else [];

  # Enable clipse clipboard manager only on desktop systems
  config = lib.mkIf isDesktop {
    wayland.clipse.enable = true;
  };

  # Empty options declaration to avoid warnings
  options = {};
}
