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
  # Import all modules unconditionally to avoid evaluation issues
  imports = [
    ./hyprland
    ./anyrun.nix
    ./waybar.nix
    ./clipse
    ./cava.nix
  ];

  # Enable modules only on desktop systems
  config = lib.mkIf isDesktop {
    wayland.clipse.enable = true;
  };

  # Empty options declaration to avoid warnings
  options = {};
}
