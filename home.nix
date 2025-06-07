{ pkgs, lib, inputs, ... }:
{
  home = {
    stateVersion = "23.11";
    username = "willow";
    homeDirectory = lib.mkForce "/home/willow/";
  };
  imports = [
    ./programs/helix_theme.nix
  ];
  programs = {

    waybar = {
      enable = true;
      systemd.enable = true;
      #package = inputs.hyprland.packages.${system}.waybar-hyprland;
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
        anyrun = {
      enable = true;
      config = {
        plugins = [
          # An array of all the plugins you want, which either can be paths to the .so files, or their packages
          inputs.anyrun.packages.${pkgs.system}.applications
          #"${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/kidex"
        ];
        width = { fraction = 0.3; };
        #position = "top";
        #verticalOffset = { absolute = 0; };
        hideIcons = false;
        ignoreExclusiveZones = false;
        layer = "overlay";
        hidePluginInfo = false;
        closeOnClick = false;
        showResultsImmediately = false;
        maxEntries = null;
      };
    };
    wezterm = {
      enable = true;
      extraConfig = ''
        return {
          window_background_opacity = .65
        }
      '';
    };
    ironbar = {
      enable = false;
      config = {
        position = "top";
        anchor_to_edges = true;
        start = [
            { type = "workspaces"; }
        ];
        center = [
          {type = "focused";}
        ];
        end = [
          { type = "music"; }
          { type = "tray"; }
          { type = "clock"; }
        ];
      };
      style = ''
          * {
              /* `otf-font-awesome` is required to be installed for icons */
              font-family: Noto Sans Nerd Font, sans-serif;
              /* font-family: 'Jetbrains Mono', monospace;*/
              font-size: 16px;

              /*color: white;*/
              /*background-color: #2d2d2d;*/
              /*background-color: red;*/
              border: none;

             /*background-color: rgba(255, 255, 255, .1);*/

 all: unset;
          }

          #bar {
              border-top: 1px solid #424242;
              background-color: rgba(0, 0, 255, .25);
              color: white;
          }

          .container {
              background-color: rgba(0,0,0,0);
          }

          /* test  34543*/

          #right > * + * {
              margin-left: 20px;
          }

          #workspaces .item {
              color: white;
              background-color: #2d2d2d;
              border-radius: 0;
          }

          #workspaces .item.focused {
              box-shadow: inset 0 -3px;
              background-color: #1c1c1c;
          }
          button:hover {
            background-color: rgba(0, 0, 255, .5);
            box-shadow: 10px 0px rgba(0,0,255, 0.5), -10px 0px rgba(0,0,255, 0.5);
            color: #efefef;
          }

          #workspaces *:not(.focused):hover {
              box-shadow: inset 0 -3px;
          }

          #launcher .item {
              border-radius: 0;
              background-color: #2d2d2d;
              margin-right: 4px;
          }

          #launcher .item:not(.focused):hover {
              background-color: #1c1c1c;
          }

          #launcher .open {
              border-bottom: 2px solid #6699cc;
          }

          #launcher .focused {
              color: white;
              background-color: black;
              border-bottom: 4px solid #6699cc;
          }

          #launcher .urgent {
              color: white;
              background-color: #8f0a0a;
          }

          #clock {
              color: white;
              background-color: #2d2d2d;
              font-weight: bold;
          }

          #script {
              color: white;
          }

          #sysinfo {
              color: white;
          }

          #tray .item {
              background-color: #2d2d2d;
          }

          #mpd {
              background-color: #2d2d2d;
              color: white;
          }

          .popup {
              background-color: #2d2d2d;
              border: 1px solid #424242;
          }

          #popup-clock {
              padding: 1em;
          }

          #calendar-clock {
              color: white;
              font-size: 2.5em;
              padding-bottom: 0.1em;
          }

          #calendar {
              background-color: #2d2d2d;
              color: white;
          }

          #calendar .header {
              padding-top: 1em;
              border-top: 1px solid #424242;
              font-size: 1.5em;
          }

          #calendar:selected {
              background-color: #6699cc;
          }

          #popup-mpd {
              color: white;
              padding: 1em;
          }

          #popup-mpd #album-art {
              /*border: 1px solid #424242;*/
              margin-right: 1em;
          }

          #popup-mpd #title .icon, #popup-mpd #title .label {
              font-size: 1.7em;
          }

          #popup-mpd #controls * {
              border-radius: 0;
              background-color: #2d2d2d;
              color: white;
          }

          #popup-mpd #controls *:disabled {
              color: #424242;
          }

          #focused {
              color: white;
          }
button {
  all: unset;
  margin: 0 0em;
  padding: 0 2em;
  transition: all .5s ease-out;
  opacity: 1;
  color: white;
}
'';


#.background {
#    background-color: rgba(0,0,0,0)
#}
       #package = inputs.ironbar;
      #features = ["feature" "another_feature"];
    };
    ssh = {
      enable = true;
      matchBlocks = {
        "redoak" = {
          hostname = "172.28.0.156";
          user = "willow";
        };
      };
    };
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
  };
}
