{
  pkgs,
  lib,
  ...
}: let
  # Import the clipse keybindings
  clipseKeybindings = import ../clipse/keybindings.nix {inherit pkgs;};
  clipseConfig = clipseKeybindings.getClipseKeybindings;
in {
  wayland.windowManager.hyprland.settings = {
    # Key bindings
    bind =
      [
        # Applications
        "$mod, Return, exec, wezterm"
        "$mod, N, exec, anyrun"

        # Window management
        "$mod SHIFT, K, killactive,"
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
        "$mod SHIFT, C, exec, bash -c 'temp_file=\"/tmp/screenshot-$(date +%Y%m%d-%H%M%S).png\"; if grimblast save area \"$temp_file\"; then imv \"$temp_file\" & imv_pid=$!; wait $imv_pid; filename=$(zenity --file-selection --save --filename=\"screenshot-$(date +%Y%m%d-%H%M%S).png\" --file-filter=\"PNG files | *.png\" --file-filter=\"All files | *\" 2>/dev/null); if [ -n \"$filename\" ]; then mv \"$temp_file\" \"$filename\" && notify-send \"Screenshot saved\" \"Saved to $filename\"; else rm \"$temp_file\"; fi; fi'"

        # Lock screen
        "$mod, L, exec, loginctl lock-session"
      ]
      ++ (clipseConfig.keybinds);

    # Mouse bindings for window management
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];
  };

  # Add clipse configuration to extraConfig
  wayland.windowManager.hyprland.extraConfig = ''
    ${clipseConfig.windowRules}
    ${clipseConfig.autostart}
  '';
}
