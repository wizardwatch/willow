# Base profile for Willow user
# This profile contains essential configurations that work on all systems
{
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Import Zsh and Starship configuration
    ../modules/other/starshipZsh.nix
    # Import essential modules
    ../modules/terminal
    ../modules/editor
    ../modules/network
  ];

  # Home Manager configuration
  home = {
    username = "willow";
    homeDirectory = "/home/willow";
    stateVersion = "23.11";

    # Add additional files to the home directory
    file = {
      # Example: ".config/some-app/config".text = "...";
    };

    # Environment variables
    sessionVariables = {
      EDITOR = "hx";
    };
  };

  # XDG configuration
  xdg = {
    enable = true;
  };
}