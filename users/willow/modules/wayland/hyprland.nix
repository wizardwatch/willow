{
  pkgs,
  lib,
  hyprland,
  ...
}: let
  # Import the clipse keybindings
  clipseKeybindings = import ./clipse/keybindings.nix {inherit pkgs;};
  clipseConfig = clipseKeybindings.getClipseKeybindings;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    # Use Hyprland from flake if available
    package = hyprland.packages.${pkgs.system}.hyprland;

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
        rounding = 8;

        # Window transparency (0.0 - 1.0)
        active_opacity = 0.93;
        inactive_opacity = 0.85;
      };

      # Animation settings
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
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

      # Layer rules
      layerrule = [
        "blur, waybar"
        "blur, ironbar"
        "blur, launcher"
        "blur, notifications"
      ];

      # Key bindings
      bind =
        [
          # Applications
          "$mod, Return, exec, wezterm"
          "$mod, N, exec, anyrun"

          # Window management
          "$mod SHIFT, C, killactive,"
          "$mod, F, fullscreen,"
          "$mod, Space, togglefloating,"
          "$mod, P, pseudo," # pseudotiled state
          "$mod, J, togglesplit," # toggle split direction

          # Workspaces
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"

          # Move windows to workspaces
          "$mod SHIFT, 1, movetoworkspacesilent, 1"
          "$mod SHIFT, 2, movetoworkspacesilent, 2"
          "$mod SHIFT, 3, movetoworkspacesilent, 3"
          "$mod SHIFT, 4, movetoworkspacesilent, 4"
          "$mod SHIFT, 5, movetoworkspacesilent, 5"
          "$mod SHIFT, 6, movetoworkspacesilent, 6"
          "$mod SHIFT, 7, movetoworkspacesilent, 7"
          "$mod SHIFT, 8, movetoworkspacesilent, 8"
          "$mod SHIFT, 9, movetoworkspacesilent, 9"

          # Media and volume controls
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

          # Brightness controls
          ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
          # Toggle window opacity with Super+O
          "$mod, O, exec, hyprctl dispatch toggleopaque"

          # Screenshot
          "$mod, C, exec, grimblast copy area"
        ]
        ++ (clipseConfig.keybinds);

      # Mouse bindings for window management
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Monitor setup (default, will be overridden by host-specific config)
      monitor = ",preferred,auto,1";
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
      ${clipseConfig.windowRules}
      ${clipseConfig.autostart}
    '';
  };

  # Ensure Hyprland prerequisites are installed
  home.packages = with pkgs;
    [
      hyprpaper # Wallpaper utility for Hyprland
      grimblast # Screenshot utility for Hyprland
      brightnessctl # Brightness control
      libnotify # Notifications
      wl-clipboard # Clipboard utilities
    ]
    ++ clipseConfig.packages;

  # Hyprpaper configuration
  xdg.configFile = {
    "hypr/hyprpaper.conf".text = ''
      preload = ~/.config/hypr/celeste.png
      wallpaper = ,~/.config/hypr/celeste.png
      splash = false
      ipc = on
    '';
  };
}
