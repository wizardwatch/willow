{pkgs, ...}: {
  # System-wide directories and backup configuration
  systemd.tmpfiles.rules = [
    "d /var/backup 0755 root root -"
    "d /var/backup/postgresql 0755 postgres postgres -"
  ];

  # Enable log rotation
  services.logrotate.enable = true;

  # Manual debugging service to check connectivity
  systemd.services.ivy-debug = {
    description = "Check ivy.local connectivity and services";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.writeShellScript "ivy-debug" ''
        echo "=== Ivy Debug Report ==="
        echo "1. Checking Avahi service:"
        systemctl is-active avahi-daemon || echo "Avahi not running"

        echo "2. Checking if ivy.local resolves:"
        ${pkgs.avahi}/bin/avahi-resolve -n ivy.local || echo "ivy.local does not resolve"

        echo "3. Checking listening ports:"
        ${pkgs.nettools}/bin/netstat -tlnp | grep -E ':(80|8080|8888)' || echo "No services listening on web ports"

        echo "4. Checking Traefik service:"
        systemctl is-active traefik || echo "Traefik not running"

        echo "5. Testing local connections:"
        ${pkgs.curl}/bin/curl -I http://localhost:80 2>&1 | head -5 || echo "Cannot connect to port 80"
        ${pkgs.curl}/bin/curl -I http://localhost:8080 2>&1 | head -5 || echo "Cannot connect to port 8080"


        echo "Debug report complete. Check journalctl -u ivy-debug for full output."
      ''}";
    };
  };

  # Enable Avahi for mDNS/DNS-SD broadcasting (ivy.local)
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enable IPv4 mDNS NSS support
    nssmdns6 = true; # Enable IPv6 mDNS NSS support
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };
  sops.secrets = {
    secrets = {
      authentik = {
        sopsFile = ./secrets/authentik.yaml;
        mode = "600";
        path = "/var/lib/matrix/authentik.env";
        owner = "matrix";
        group = "matrix";
      };
    };
  };
}
