{
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    # Layer rules
    layerrule = [
      "blur, waybar"
      "blur, ironbar"
      "blur, launcher"
      "blur, notifications"
    ];

    # Window rules
    windowrulev2 = [
      "float, class:^(zenity)$"
      "center, class:^(zenity)$"
      "size 800 600, class:^(zenity)$"
      "float, class:^(imv)$"
      "center, class:^(imv)$"
      "size 800 600, class:^(imv)$"
    ];
  };
}
