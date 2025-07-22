{pkgs, ...}: {
  # Function to get Clipse keybindings for Hyprland
  getClipseKeybindings = let
    clipse-wezterm = pkgs.writeShellScriptBin "clipse-wezterm" ''
      ${pkgs.kitty}/bin/kitty --class clipse-floating ${pkgs.clipse}/bin/clipse interactive
    '';
  in {
    # Packages for Clipse
    packages = [
      pkgs.clipse
      pkgs.wl-clipboard
      pkgs.kitty
      clipse-wezterm
    ];

    # Keybindings for Hyprland
    keybinds = [
      # Clipboard history bindings
      "bind = SUPER, V, exec, ${clipse-wezterm}/bin/clipse-wezterm"
    ];

    # Window rules for Clipse
    windowRules = ''
      # Window rules for Clipse
      windowrulev2 = float, class:^(clipse-floating)$
      windowrulev2 = size 80% 80%, class:^(clipse-floating)$
      windowrulev2 = center, class:^(clipse-floating)$
    '';

    # Autostart commands for Clipse
    autostart = ''
      # Start clipse daemon
      # exec-once = ${pkgs.clipse}/bin/clipse -listen
    '';
  };
}
