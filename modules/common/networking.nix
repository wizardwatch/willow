{
  pkgs,
  lib,
  ...
}: {
  # Allow ZeroTier
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "zerotierone"
    ];

  # Networking packages
  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    inetutils # ping, traceroute, etc.
    bind # dig, nslookup
  ];

  # General networking configuration
  networking = {
    # Hostname should be set per-host
    # hostName = "hostname";

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
  # ZeroTier VPN
  services.zerotierone = {
    enable = true;
    joinNetworks = []; # Add network IDs here to auto-join
  };
}
