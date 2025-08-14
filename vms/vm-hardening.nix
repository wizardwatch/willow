{
  config,
  lib,
  pkgs,
  ...
}: {
  # VM Host Network Hardening for Willow
  # This module provides security hardening for hosting VMs on the willow host

  # Override the basic firewall configuration with enhanced security
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 # SSH
      80 # HTTP (Traefik)
      443 # HTTPS (Traefik)
      8080 # Traefik dashboard (restricted to local)
      8000
    ];
    trustedInterfaces = ["microvm"];
  };

  # Enhanced NAT configuration with both interfaces
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    # Primary interface (wireless)
    externalInterface = "wlan0";
    internalInterfaces = ["microvm"];
  };
}
