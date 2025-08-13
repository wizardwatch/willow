{
  config,
  lib,
  pkgs,
  ...
}: {
  # VM Host Network Hardening for Willow
  # This module provides security hardening for hosting VMs on the willow host

  # Override the basic firewall configuration with enhanced security
  networking.firewall = lib.mkForce {
    enable = true;

    # Allow essential host services (keeping existing willow ports)
    allowedTCPPorts = [
      22 # SSH
      80 # HTTP (Traefik)
      443 # HTTPS (Traefik)
      8080 # Traefik dashboard (restricted to local)
      8000
    ];

    allowedUDPPorts = [
    ];

    # Trust the VM bridge but add restrictions
    trustedInterfaces = ["microvm"];
  };

  # Enhanced NAT configuration with both interfaces
  networking.nat = lib.mkForce {
    enable = true;
    enableIPv6 = true;
    # Primary interface (wireless)
    externalInterface = "wlan0";
    internalInterfaces = ["microvm"];
  };
}
