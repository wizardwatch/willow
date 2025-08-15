{
  config,
  lib,
  pkgs,
  ...
}: {
  # Foundry VTT VM configuration

  # Static addressing on the microvm network
  networking.useDHCP = false;
  systemd.network.enable = true;
  systemd.network.networks."10-microvm-eth" = {
    matchConfig = {
      # Match the MicroVM NIC by MAC set in vms/main.nix
      MACAddress = "02:00:00:00:00:03";
    };
    networkConfig = {
      DHCP = "no";
      Address = ["10.0.0.12/24"];
      Gateway = "10.0.0.1";
      DNS = ["1.1.1.1" "9.9.9.9"];
    };
  };

  # SSH for management (same policy as other VMs)
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Admin user
  users.users.willow = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    initialPassword = "gex";
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../../users/willow/keys/willow_ssh.pub)
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  # Firewall: allow SSH and Foundry's internal port (proxied via Traefik on host)
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [22 30000];
  };

  # Foundry VTT service
  services.foundryvtt = {
    enable = true;
    hostName = "dnd.holymike.com";
    minifyStaticFiles = true;
    proxyPort = 443; # Behind Traefik TLS
    proxySSL = false; # Traefik handles TLS
    upnp = false;
    # Package is provided by VM wiring in vms/main.nix
  };

  environment.systemPackages = with pkgs; [vim curl htop];

  system.stateVersion = "23.11";
}
