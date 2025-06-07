{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Import hardware configuration
    ./hardware.nix
    
    # Include all the existing NixOS configuration
    # This will be gradually migrated to modules
    ../../main.nix
    
    # Import the current home-manager configuration
    ({ pkgs, ... }: {
      home-manager.users.willow = import ../../home.nix;
    })
  ];
  
  # System settings
  time.timeZone = "America/New_York";
  networking.hostName = "willow";
  
  # Set a reasonable state version
  system.stateVersion = "23.05";
}