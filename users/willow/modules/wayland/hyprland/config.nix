{
  pkgs,
  lib,
  hyprland,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    # Use Hyprland from flake if available, otherwise use from nixpkgs
    package =
      if hyprland != null && hyprland ? packages
      then hyprland.packages.${pkgs.system}.hyprland
      else pkgs.hyprland;

    # Hyprland settings
    settings = {
      # Modifier key (Super/Windows key)
      "$mod" = "SUPER";

      # Autostart applications
      exec-once = [
        "ironbar" # Additional bar
        "hyprpaper" # Wallpaper
        "mako" # Notifications
      ];

      # Input configuration
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0; # -1.0 to 1.0, 0 means no modification
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
        };
      };

      # General configuration
      general = {
        gaps_in = 1;
        gaps_out = 1;
        border_size = 6;
        "col.active_border" = "rgba(5B7BB8FF) rgba(b54c8dFF) 45deg";
        "col.inactive_border" = "rgba(595959CC)";
        layout = "dwindle";

        # New Hyprland 0.30+ settings
        resize_on_border = true;
        extend_border_grab_area = 15;
        hover_icon_on_border = true;
      };

      # Decoration settings
      decoration = {
        rounding = 0;

        # Window transparency (0.0 - 1.0)
        #active_opacity = 0.97;
        #inactive_opacity = 0.90;
      };

      # Animation settings
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 1, 1.1";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
          "border, 1, 10, default" # New animation for border color
          "borderangle, 1, 8, default" # New animation for border gradient angle
        ];
      };

      # Dwindle layout settings
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Master layout settings
      master = {
        new_on_top = true;
      };

      # Gestures
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_cancel_ratio = 0.5;
        workspace_swipe_min_speed_to_force = 30;
      };

      # Monitor setup - 1440p on left, 1080p on right
      monitor = [
        "DP-1,2560x1440@120,0x0,1" # 1440p monitor on the left
        "DP-2,1920x1080@60,2560x0,1" # 1080p monitor on the right
        ",preferred,auto,1" # Fallback for any other monitors
      ];
    };

    # Additional Hyprland configuration
    extraConfig = ''
      # Fallback workspace binds using keyboard movement for more than 9 workspaces
      bind = $mod, right, workspace, e+1
      bind = $mod, left, workspace, e-1

      # Set environment variables
      env = XCURSOR_SIZE,24
      env = QT_QPA_PLATFORMTHEME,qt5ct

      # Disable direct scanout to fix some glitches
      env = WLR_DRM_NO_ATOMIC,1
    '';
  };
}
