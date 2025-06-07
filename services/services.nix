{ pkgs, ... }:
{
  services = {
    pipewire = {
      wireplumber.enable = true;
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = false;
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        brlaser
      ];
    };
    flatpak.enable = true;
    gnome.gnome-keyring.enable = true;
    fstrim.enable = true;
  };

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wants = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
