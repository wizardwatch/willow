{ pkgs, config, ... }:
{
  services.kanshi = {
    enable = true;
    systemdTarget = "";
    profiles = {
      normal = {
        outputs = [
          #{
          #  criteria = "DP-2";
          #  status = "disable";
          #}
          {
            criteria = "HDMI-A-1";
            position = "900,1440";
          }
        ];
      };
    };
  };
}
