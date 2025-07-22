{
  pkgs,
  lib,
  inputs ? {},
  host ? {isDesktop = false;},
  ...
}: let
  # Only use this module if we're on a desktop system
  isDesktop = host.isDesktop or false;

  # Use hyprland input if available, otherwise use null
  hyprland = inputs.hyprland or null;
in {
  imports = [
    ./config.nix
    ./keybindings.nix
    ./rules.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./packages.nix
  ];
}
