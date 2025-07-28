{
  config,
  pkgs,
  lib,
  ...
}: {
  # Import SSH keys from the willow user
  imports = [
    ../../users/willow/keys/ssh.nix
    ../../vms/main.nix
  ];

  networking.bridges.br0.interfaces = [];
  nix.settings = {
    trusted-users = ["root" "willow" "nixremote"];

    # Configure binary caches
    substituters = [
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
  # Ensure the deploy-rs service can connect and deploy
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password"; # Allow root login with key only
    settings.PasswordAuthentication = true;
  };

  # Server-specific configuration for Ivy

  # Configure basic networking
  networking = {
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      # SSH is already enabled by the ssh.nix module
      allowedTCPPorts = [80 8080 8888]; # HTTP, Traefik dashboard, test service
      allowedUDPPorts = [5353]; # mDNS for Avahi
    };
  };

  # Only install essential packages
  environment.systemPackages = with pkgs; [
    # System tools
    vim
    wget
    curl
    htop
    tmux
    git
    # Networking tools
    inetutils
    dig
    # System maintenance
    lsof
    ncdu
    rsync
    python3Full
  ];

  # Server-specific boot options
  boot = {
    # Using GRUB for better server compatibility
    loader = {
      systemd-boot.enable = lib.mkForce false;
      grub = {
        enable = true;
        device = lib.mkDefault "nodev"; # Will be overridden in hardware.nix
        efiSupport = true;
        useOSProber = false;
      };
    };
    # Kernel parameters for server use
    kernelParams = [
      "quiet"
      "mitigations=auto"
    ];
  };

  # Server-focused performance settings
  services = {
    # Network Time Protocol for accurate time
    timesyncd.enable = true;

    # Simple system monitoring
    journald.extraConfig = ''
      SystemMaxUse=100M
      MaxFileSec=7day
    '';
  };

  # Security hardening
  security = {
    sudo.wheelNeedsPassword = true;
    # Additional hardening
    audit.enable = true;
    auditd.enable = true;
  };

  # Make sure we have the willow user for administration
  users.users.willow = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = config._module.args.sshKeys.all;
    initialPassword = "mount";
    # Allow passwordless sudo for deploy-rs
    # IMPORTANT: This is required for deploy-rs to work, but creates a security risk
    # Consider limiting sudo access or using a dedicated deployment user in production
  };
  users.users.root = {
    openssh.authorizedKeys.keys = config._module.args.sshKeys.all;
  };
  # Create necessary persistent directories for deployment
  system.activationScripts.deployDirs = lib.mkIf (lib.hasAttr "activationScripts" config.system) {
    text = ''
      mkdir -p /nix/persist/etc/ssh 2>/dev/null || true
      mkdir -p /nix/persist/etc/nixos 2>/dev/null || true
      chmod 700 /nix/persist/etc/ssh 2>/dev/null || true
    '';
  };
}
