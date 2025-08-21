{
  pkgs,
  lib,
  ...
}: {
  # Hypridle service configuration
  services.hypridle = {
    enable = false;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 120; # 2 minutes
          on-timeout = "loginctl lock-session";
        }
      ];
    };
  };
}
