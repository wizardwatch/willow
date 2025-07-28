{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./traefik.nix
    ./matrix-route.nix
  ];

  # Basic system configuration
  boot.kernelParams = ["console=ttyS0"];

  # Enable SSH for management
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Create admin user for VM management
  users.users.admin = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      # Add your SSH key here
    ];
  };

  # Enable sudo without password for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Firewall configuration
  # Firewall configuration
  /*
    networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443 8080]; # SSH, HTTP, HTTPS, Traefik dashboard
  };
  */

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    curl
    htop
    traefik
  ];

  # Create traefik directories
  systemd.tmpfiles.rules = [
    "d /etc/traefik 0755 root root -"
    "d /etc/traefik/dynamic 0755 root root -"
    "d /var/log/traefik 0755 traefik traefik -"
  ];

  # Create traefik user
  users.users.traefik = {
    isSystemUser = true;
    group = "traefik";
    home = "/var/lib/traefik";
    createHome = true;
  };
  users.groups.traefik = {};

  system.stateVersion = "23.11";
}
