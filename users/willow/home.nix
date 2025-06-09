# Willow's home configuration
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Import Zsh and Starship configuration
    ./modules/other/starshipZsh.nix
    # Import Wayland modules (Hyprland, Anyrun, Waybar)
    ./modules/wayland
    # Import terminal applications
    ./modules/terminal
    # Import editor applications
    ./modules/editor
    # Import network applications
    ./modules/network
    # Import ironbar module
    inputs.ironbar.homeManagerModules.default
    # Import the helix theme configuration from programs directory
    #../../programs/helix_theme.nix
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
      EDITOR = "helix";
    };
  };

  # GUI applications
  programs = {
    # Application launcher config moved to ./modules/wayland/anyrun.nix
  };

  # Services managed by home-manager
  services = {
    # Example:
    # syncthing.enable = true;
  };

  # XDG configuration
  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = ["helix.desktop"];
      };
    };
  };
}
