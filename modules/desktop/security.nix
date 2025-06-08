{pkgs, ...}: {
  # Security-focused tools and configurations for desktop systems

  environment.systemPackages = with pkgs; [
    # Encryption
    gnupg
    age

    # Network security
    nmap

    # System monitoring and forensics
    lsof
    htop
    btop

    # VPNs
    openvpn
    wireguard-tools
    openconnect
  ];

  # Enable Wireshark
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowPing = false;
  };

  # Add wireshark capabilities to users who need it
  users.users = {
    willow = {
      extraGroups = ["wireshark"];
    };
  };
}
