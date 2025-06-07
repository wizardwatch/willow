{ config, pkgs, ... }:

{
  # Security-focused tools and configurations for desktop systems
  
  environment.systemPackages = with pkgs; [
    # Password management
    keepassxc
    bitwarden
    
    # Encryption
    gnupg
    age
    rage
    
    # Network security
    nmap
    wireshark
    netcat-gnu
    tcpdump
    
    # Password cracking and analysis
    hashcat
    john
    
    # System monitoring and forensics
    lsof
    htop
    btop
    
    # VPNs
    openvpn
    wireguard-tools
    openconnect
    
    # Security scanners
    clamav
    rkhunter
    
    # Secure deletion
    secure-delete
    
    # Firewall tools
    ufw
    iptables
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
      extraGroups = [ "wireshark" ];
    };
  };
  
  # AppArmor for increased security
  security.apparmor = {
    enable = true;
    packages = with pkgs; [ apparmor-profiles ];
  };
  
  # System hardening
  security.lockKernelModules = false; # Enable for production, might cause issues with some hardware
  
  # Secure boot (enable only if supported by hardware)
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.bootspec.enable = true;
}