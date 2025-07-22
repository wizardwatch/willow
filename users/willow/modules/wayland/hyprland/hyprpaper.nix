{
  pkgs,
  lib,
  ...
}: {
  # Hyprpaper configuration
  xdg.configFile = {
    "hypr/hyprpaper.conf".text = ''
      preload = ~/.config/hypr/celeste.png
      wallpaper = ,~/.config/hypr/celeste.png
      splash = false
      ipc = on
    '';
  };

  # Ensure wallpaper directory exists
  home.file.".config/hypr/.keep".text = "";
}
