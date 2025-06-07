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



  # Enable common desktop services
  services = {

    # Hardware support
    acpid.enable = true;
    thermald.enable = true;

    # Bluetooth
    blueman.enable = true;
  };

}
