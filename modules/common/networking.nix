{
  pkgs,
  lib,
  ...
}: {
  # Networking packages
  environment.systemPackages = with pkgs; [
    inetutils # ping, traceroute, etc.
    bind # dig, nslookup
  ];

  # General networking configuration
  networking = {
    # Enable NetworkManager
    networkmanager = {
      enable = false;
    };
    useNetworkd = true;

    # Example firewall configuration - adjust per host as needed
    firewall = {
      enable = true;
    };
  };
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = ["~."];
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    dnsovertls = "true";
  };
}
