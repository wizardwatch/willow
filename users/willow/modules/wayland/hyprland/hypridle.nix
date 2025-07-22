{
  pkgs,
  lib,
  ...
}: {
  # Hypridle service configuration
  services.hypridle = {
    enable = true;
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
        {
          timeout = 300; # 5 minutes
          on-timeout = "bash -c 'if ! playerctl -a status 2>/dev/null | grep -q \"Playing\"; then systemctl suspend; fi'";
        }
      ];
    };
  };
}
