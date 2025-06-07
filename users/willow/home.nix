# Willow's home configuration
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    # Import the helix theme configuration from programs directory
    ../../programs/helix_theme.nix
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
    # Terminal
    wezterm = {
      enable = true;
      extraConfig = ''
        return {
          window_background_opacity = .65
        }
      '';
    };

    # Editor
    helix = {
      enable = true;
      settings = {
        theme = "catppuccin_mocha";
        editor = {
          auto-save = true;
          true-color = true;
          color-modes = true;
          cursorline = true;
          completion-replace = true;
          soft-wrap.enable = true;
          idle-timeout = 1;
          gutters = ["diff" "diagnostics" "line-numbers" "spacer"];
          statusline = {
            left = ["mode" "spinner"];
            center = ["file-name"];
            right = ["diagnostics" "selections" "position" "file-line-ending" "file-type" "version-control"];
            separator = "|";
            mode = {
              normal = "NORMAL";
              insert = "INSERT";
              select = "SELECT";
            };
          };
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          indent-guides = {
            render = true;
            rainbow = "dim";
            character = "┆";
          };
          whitespace = {
            characters = {
              space = "·";
              nbsp = "⍽";
              tab = "→";
              newline = "⏎";
              tabpad = "·";
            };
          };
          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };
        };
      };
    };

    # SSH
    ssh = {
      enable = true;
      matchBlocks = {
        "redoak" = {
          hostname = "172.28.0.156";
          user = "willow";
        };
      };
    };

    # Status bar
    waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        mainBar = {
          position = "top";
          height = 30;
          layer = "top";
          modules-left = [
            "hyprland/workspaces"
            "tray"
          ];
          modules-right = [
            "network"
            "custom/wireguard"
            "custom/teavpn"
            "pulseaudio"
            "battery"
            "custom/date"
            "clock"
          ];
          "hyprland/workspaces" = {
            on-click = "activate";
          };
        };
      };
    };

    # Application launcher
    anyrun = {
      enable = true;
      config = {
        plugins = [
          # Use anyrun applications plugin
          inputs.anyrun.packages.${pkgs.system}.applications
        ];
        width = { fraction = 0.3; };
        hideIcons = false;
        ignoreExclusiveZones = false;
        layer = "overlay";
        hidePluginInfo = false;
        closeOnClick = false;
        showResultsImmediately = false;
        maxEntries = null;
      };
    };
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
        "text/plain" = [ "helix.desktop" ];
      };
    };
  };
}