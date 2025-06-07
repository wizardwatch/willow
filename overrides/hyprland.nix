{
  settings = {
    "$mod" = "SUPER";
    exec-once = [
      "mpvpaper -o 'keep-open=yes' '*' ~/bigBackground.png"
      "nm-applet"      
    ];
    bind = 
      let
        workspaces = ["1" "2" "3" "4" "5" "6" "7" "8" "9" "10"];
        # Generate workspace switching keybinds
        workspaceBinds = builtins.concatMap (n: 
          let key = if n == "10" then "0" else n;
          in ["$mod, ${key}, workspace, ${n}"]
        ) workspaces;
        # Generate window moving keybinds
        moveBinds = builtins.concatMap (n: 
          let key = if n == "10" then "0" else n;
          in ["$mod + SHIFT, ${key}, movetoworkspace, ${n}"]
        ) workspaces;
        # Standard keybinds
        standardBinds = [
          "$mod, Return, exec, alacritty"
          "$mod + SHIFT, c, killactive "
          "$mod, n, exec, anyrun"
          "$mod + SHIFT, p, exec, hyprland-relative-workspace b"
          "$mod + SHIFT, n, exec, hyprland-relative-workspace f"
          # Screenshot with grimblast
          "$mod + SHIFT, s, exec, grimblast copy area"
        ];
      in standardBinds ++ workspaceBinds ++ moveBinds;
    decoration = {
        rounding = 5;
        blur = {
          enabled = true;
          size = 6;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
        };
        shadow = {
         offset = "0 5";
          range = 50;
          render_power = 3; 
        };   
        #"col.shadow" = "rgba(00000099)";
        blurls = ["gtk-layer-shell" "waybar" "lockscreen" "ironbar"];
    };
  };
}
