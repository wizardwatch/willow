{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    # Use the netboot-minimal installer as a base
    "${modulesPath}/installer/netboot/netboot-minimal.nix"
    
    # Include common modules for Nix, etc.
    ../../modules/common/nix.nix
  ];
  
  # Basic configuration for the installation media
  networking = {
    # Enable networking
    networkmanager.enable = true;
    
    # Enable SSH for remote installation
    firewall.allowedTCPPorts = [ 22 ];
  };
  
  # Enable SSH server for remote deployment
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
  
  # Include some useful tools for installation
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    parted
    gptfdisk
    cryptsetup
    btrfs-progs
    e2fsprogs
    dosfstools
    # Deploy-rs for running deployments
    deploy-rs
  ];
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Create persistent Nix store
  boot.supportedFilesystems = [ "btrfs" ];
  
  # ISO-specific settings
  isoImage = {
    # Make the installer medium more featureful
    edition = "minimal";
    
    # Add a volume name
    volumeID = "NIXOS_DEPLOY";
    
    # Include a copy of the Nix store on the medium
    storeContents = [
      # Include deploy-rs
      pkgs.deploy-rs
    ];
  };
  
  # Set a lower compression level for faster building
  isoImage.squashfsCompression = "gzip -Xcompression-level 3";
  
  # Add a helpful message at boot
  system.build.installationDevice = pkgs.writeText "INSTALL_INSTRUCTIONS.txt" ''
    =================================================================
    NixOS Deployment ISO
    =================================================================
    
    This is a minimal NixOS installation image with deploy-rs included.
    
    1. Connect to a network (use `nmcli` or `nmtui`)
    2. Run `ip a` to find your IP address
    3. From your deployment machine, deploy your system using:
       deploy .#your-machine --target-host root@<IP_ADDRESS>
    
    The root password is "nixos"
    
    =================================================================
  '';
}