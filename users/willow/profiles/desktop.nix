# Desktop profile for Willow user
# This profile contains desktop-specific configurations
{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    # First import the base profile
    ./base.nix

    # Import the desktop module that handles conditional imports
    ../modules/desktop.nix
    ../modules/ai/codex.nix
  ];

  # Add desktop-specific home configuration
  home = {
    # Desktop-specific packages
    packages = with pkgs; [
      # GUI utilities
      xdg-utils
      xdg-user-dirs

      # Media tools
      ffmpeg
      imagemagick

      # Screenshot utilities
      grim
      slurp
    ];
  };

  # GUI applications
  programs = {
    # Include desktop-specific programs
    firefox.enable = lib.mkDefault true;
  };

  # Desktop services
  services = {
    # Example service configurations
    # syncthing.enable = true;
  };
}
