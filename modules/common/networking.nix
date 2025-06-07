{ config, pkgs, lib, ... }:

{
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
      enable = true;
    };
    
    # Enable DHCP by default
    useDHCP = lib.mkDefault true;
    
    # Example firewall configuration - adjust per host as needed
    firewall = {
      enable = true;
      # Common ports for gaming and services
      allowedTCPPorts = [ 22 80 443 ];
      allowedUDPPorts = [ ];
      
      # For more specific needs, uncomment and customize:
      # allowedTCPPorts = [ 27036 27037 49737 6969 ];
      # allowedUDPPorts = [ 27031 27036 6969 122 ];
    };
    
    # Enable wireless support via wpa_supplicant (only if not using NetworkManager)
    # wireless.enable = false;
    
    # Set default DNS servers
    # nameservers = [ "1.1.1.1" "8.8.8.8" ];
    
    # Extra hosts - for development or testing
    # extraHosts = ''
    #   127.0.0.1 local.dev
    # '';
  };
  
  # ZeroTier VPN
  services.zerotierone = {
    enable = true;
    joinNetworks = [];  # Add network IDs here to auto-join
  };
}