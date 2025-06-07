{ config, lib, pkgs, ... }:

{
  # Desktop configuration for NixOS systems
  # This module imports all desktop-related modules

  imports = [
    # Wayland desktop environment
    ./desktop/wayland.nix
    
    # Desktop applications
    ./desktop/applications.nix
    
    # Security tools
    ./desktop/security.nix
    
    # Core desktop services
    ./services/pipewire.nix
    ./services/printing.nix
  ];
  
  # Additional desktop-specific settings
  
  # Enable fonts
  fonts.fontDir.enable = true;
  
  # Enable natural scrolling by default
  services.xserver.libinput = {
    enable = true;
    mouse.naturalScrolling = true;
    touchpad.naturalScrolling = true;
  };
  
  # Enable common desktop services
  services = {
    # Desktop portal for integration between desktop environments
    xdg-desktop-portal = {
      enable = true;
    };
    
    # Display manager
    displayManager.gdm.enable = lib.mkDefault false;
    
    # Hardware support
    acpid.enable = true;
    thermald.enable = true;
    
    # Bluetooth
    blueman.enable = true;
  };
  
  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };
  
  # Multimedia keys
  sound.mediaKeys.enable = true;
  
  # Enable pipewire by default
  hardware.pulseaudio.enable = false;
}