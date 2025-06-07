{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    # Use the netboot-minimal installer as a base
    "${modulesPath}/installer/netboot/netboot-minimal.nix"
    
    # Import minimal modules needed for installation
    ../../modules/common/nix.nix
    ../../modules/common/networking.nix
    ../../modules/services/ssh.nix
  ];
  
  # Override SSH settings for the installer
  services.openssh = {
    enable = true;
    settings = {
      # Allow root login with password during installation only
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };
  
  # Set a temporary password for the root user
  users.users.root.initialPassword = "nixos";
  
  # Include some useful tools for installation and deployment
  environment.systemPackages = with pkgs; [
    # Git for cloning configurations
    git
    
    # Network utilities
    curl
    wget
    inetutils
    
    # Editors
    vim
    nano
    
    # Disk utilities
    parted
    gptfdisk
    cryptsetup
    btrfs-progs
    e2fsprogs
    dosfstools
    
    # Nix deployment tools
    deploy-rs
    sops
    age
    ssh-to-age
    
    # System monitoring
    htop
    lsof
    
    # Networking utilities
    networkmanager
    networkmanagerapplet
  ];
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Support more filesystems
  boot.supportedFilesystems = [ "btrfs" "zfs" "xfs" "ntfs" "fat" ];
  
  # ISO-specific settings
  isoImage = {
    # Make the installer medium more featureful
    edition = "minimal";
    
    # Add a volume name
    volumeID = "NIXOS_DEPLOY";
    
    # Include a copy of the Nix store on the medium
    storeContents = [
      # Include deploy-rs and its dependencies
      pkgs.deploy-rs
      pkgs.sops
      pkgs.age
    ];
    
    # Set a lower compression level for faster building
    squashfsCompression = "gzip -Xcompression-level 3";
  };
  
  # Add a helpful message at boot
  system.build.installationDevice = pkgs.writeText "INSTALL_INSTRUCTIONS.txt" ''
    =================================================================
    NixOS Deployment ISO
    =================================================================
    
    This is a deployment-focused NixOS installation image with deploy-rs
    and other useful tools included.
    
    Getting Started:
    
    1. Connect to a network:
       $ nmtui
       
    2. Find your IP address:
       $ ip a
       
    3. From your deployment machine, deploy your system using:
       $ deploy .#your-host --target-host root@<IP_ADDRESS>
    
    The root password is "nixos"
    
    Disk Setup Examples:
    
    - Create GPT partition table:
      $ parted /dev/sda -- mklabel gpt
    
    - Create partitions:
      $ parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
      $ parted /dev/sda -- set 1 boot on
      $ parted /dev/sda -- mkpart primary 512MiB 100%
    
    - Format partitions:
      $ mkfs.fat -F 32 -n boot /dev/sda1
      $ mkfs.btrfs -L nixos /dev/sda2
    
    =================================================================
  '';
  
  # Set a reasonable state version
  system.stateVersion = "23.11";
}