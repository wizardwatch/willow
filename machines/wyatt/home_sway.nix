{pkgs, ...}:
let
  menu = "wofi -f -S run -i";
  modifier = "Mod4";
in { 
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
      };
      output = {
          HDMI-A-1 = {
            position =  "900 1440";
          };
          DP-4 = {
            position = "0 0";
          };
      };
      input = {
        "1386:934:Wacom_One_Pen_Display_13_Pen" = {
                   map_to_output = "HDMI-A-1";
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
      terminal = "alacritty";
      startup = [
        
        # { command = "exec oguri";}
        { command = "systemctl --user import-environment"; always = true; }
        { command = ''  swayidle -w \
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
        "${modifier}+x" = "kill";
        "${modifier}+n" = "exec ${menu}";
        "${modifier}+c" = '' exec grim -g "$(slurp)" - | wl-copy '';
        "${modifier}+Shift+c" = ''exec mkdir -p /home/wyatt/Pictures/$(date +"%Y-%m-%d"); exec grim -g "$(slurp)" - | tee /home/wyatt/Pictures/$(date +"%Y-%m-%d")/$(date +'%H%M%S-%Y-%m-%d.png') '';
      };             
    }; 
  };
}
