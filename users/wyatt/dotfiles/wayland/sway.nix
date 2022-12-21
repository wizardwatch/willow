{ pkgs, ... }:
let
  menu = "wofi -f -S run -i";
  modifier = "Mod4";
in
{
  home.packages = with pkgs; [
    wofi
  ];
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
  };
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = {
      window = {
        border = 4;
        commands = [
          #{ command = '' move to workspace "discord" ''; criteria = { title = ".*Discord.*"; }; }
          #{ command = '' fullscreen disable '';          criteria = { title = ".*Discord.*"; }; }
          #{ command = '' move to workspace "dired" '';   criteria = { title = ".*dired.*";   }; }
        ];
      };
      output = {
        HDMI-A-1 = {
          position = "2420 1440";
        };
        DP-1 = {
          position = "4480 0";
        };
        DP-2 = {
          position = "1920 0";
          #transform = "270";
        };
        DP-3 = {
          position = "0 0";
        };
        /*
        DP-4 = {
          position = "580 0";
          #transform = "270";
        };
        */
      };
      input = {
        "1386:934:Wacom_One_Pen_Display_13_Pen" = {
          map_to_output = "HDMI-A-1";
          tool_mode = "* absolute";
        };
      };
      fonts = {
        names = [ "JetBrains Mono" ];
        size = 16.0;
      };
      bars = [{
        "command" = "waybar";
      }];
      menu = "wofi --show run -i";
      terminal = "foot";
      startup = [
        #{ command = ''  emacs --daemon'';}
        #{ command = ''  emacsclient -c -e '(dired "~/.config")'   '' ;}
        #{ command = ''  emacsclient -c -e '(dired "/etc/nixos/")' '' ;}
        #{ command = ''  bitwarden '';}
        #{ command = ''  systemctl --user import-environment ''; always = true; }
        #{ command = ''  foot  -T top sh -c "htop" '';}
        #{ command = ''  foot  -T top sh -c "radeontop" '';}
        #{ command = ''  firefox --kiosk --new-instance -P discord discord.com/app'';}
        {
          command = ''  swayidle -w \
                        timeout 300 'swaylock -f -c 000000' \
                        timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
                        before-sleep 'swaylock -f -c 000000' '';
        }
      ];
      /*
      up    = "w";
      down  = "s";
      left  = "a";
      right = "d"; */
      modifier = "Mod4";
      keybindings = pkgs.lib.mkOptionDefault {
        "${modifier}+x" = '' kill '';
        "${modifier}+n" = '' exec ${menu} '';
        "${modifier}+Shift+f" = '' exec firefox -p default '';
        "${modifier}+c" = '' exec grim -g "$(slurp)" - | wl-copy '';
        "${modifier}+Shift+c" = ''
          exec mkdir -p /home/wyatt/Pictures/$(date +"%Y-%m-%d");
          exec grim -g "$(slurp)" - | tee /home/wyatt/Pictures/$(date +"%Y-%m-%d")/$(date +'%H-%M-%S.png')
        '';
      };
      assigns = {
        #"top"  = [{title = "top";}];
        #"pass" = [{title = "Bitwarden";}];
        #"discord" = [{title = "Discord.*";}];
      };
      workspaceOutputAssign = [
        #{ workspace = "top";     output = "DP-3";}
        #{ workspace = "pass";    output = "HDMI-A-1";}
        #{ workspace = "discord"; output = "HDMI-A-1";}
        #{ workspace = "dired";   output = "DP-3";}
      ];
    };
  };
}
