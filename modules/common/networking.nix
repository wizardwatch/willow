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
}
