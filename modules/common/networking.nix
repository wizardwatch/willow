{
  pkgs,
  lib,
  ...
}: {
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

  # systemd-resolved for DNS resolution when using systemd-networkd
  # This makes /etc/resolv.conf point to the stub 127.0.0.53 and forwards
  # to DNS learned via DHCP or the fallback list below.
  services.resolved = {
    enable = true;
    # Provide reliable public resolvers as fallbacks in case DHCP does not
    # supply working DNS servers.
    fallbackDns = [
      "1.1.1.1" # Cloudflare
      "9.9.9.9" # Quad9
      "8.8.8.8" # Google
    ];
    dnssec = "allow-downgrade";
  };
}
