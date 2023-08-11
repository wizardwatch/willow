{
  settings = {
    "$mod" = "SUPER";
    exec-once = [
      "mpvpaper -o 'keep-open=yes' '*' ~/bigBackground.png"
      "nm-applet"      
    ];
    bind = [
      "$mod, Return, exec, wezterm"
      "$mod + SHIFT, c, killactive "
      "$mod, n, exec, anyrun"
      "$mod + SHIFT, p, exec, hyprland-relative-workspace b"
      "$mod + SHIFT, n, exec, hyprland-relative-workspace f"
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"
    ];
    decoration = {
        rounding = 5;
        multisample_edges = true;
        blur = true;
        blur_size = 6;
        blur_passes = 3;
        blur_new_optimizations = true;
        blur_ignore_opacity = true;
        drop_shadow = true;
        shadow_ignore_window = true;
        shadow_offset = "0 5";
        shadow_range = 50;
        shadow_render_power = 3;
        "col.shadow" = "rgba(00000099)";
        blurls = ["gtk-layer-shell" "waybar" "lockscreen" "ironbar"];
    };
  };
}