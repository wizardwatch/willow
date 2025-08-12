{
  pkgs,
  inputs ? {},
  lib,
  host ? {isDesktop = false;},
  ...
}: let
  # Only use this module if we're on a desktop system
  isDesktop = host.isDesktop or false;
in
  lib.mkIf isDesktop {
    programs.waybar = {
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
      style = ''
        * {
          font-family: "JetBrains Mono", "Font Awesome 6 Free";
          font-size: 14px;
        }

        window#waybar {
          background-color: transparent;
          color: #ffffff;
          transition-property: background-color;
          transition-duration: 0.5s;
        }

        window#waybar.hidden {
          opacity: 0.2;
        }

        #workspaces {
          background-color: rgba(60, 56, 54, 0.8);
          border-radius: 5px;
          margin: 5px;
          padding: 0 5px;
        }

        #workspaces button {
          padding: 0 8px;
          background-color: transparent;
          color: #a89984;
          border: none;
          border-radius: 3px;
        }

        #workspaces button:hover {
          background-color: rgba(168, 153, 132, 0.2);
        }

        #workspaces button.active {
          background-color: #458588;
          color: #ebdbb2;
        }

        #workspaces button.urgent {
          background-color: #cc241d;
          color: #ebdbb2;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #network,
        #pulseaudio,
        #custom-media,
        #tray,
        #mode,
        #idle_inhibitor,
        #custom-date,
        #custom-wireguard,
        #custom-teavpn {
          padding: 0 10px;
          margin: 2px 3px;
          background-color: rgba(60, 56, 54, 0.8);
          color: #ebdbb2;
          border-radius: 5px;
        }





        #battery.charging {
          color: #98971a;
        }

        #battery.warning:not(.charging) {
          background-color: #fabd2f;
          color: #1d2021;
        }

        #battery.critical:not(.charging) {
          background-color: #cc241d;
          color: #ebdbb2;
          animation: blink 0.5s linear infinite alternate;
        }

        @keyframes blink {
          to {
            background-color: #1d2021;
            color: #cc241d;
          }
        }

        #network.disconnected {
          background-color: #cc241d;
          color: #ebdbb2;
        }

        #pulseaudio.muted {
          background-color: #cc241d;
          color: #ebdbb2;
        }

        #tray {
          background-color: rgba(60, 56, 54, 0.8);
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #cc241d;
        }
      '';
    };
  }
