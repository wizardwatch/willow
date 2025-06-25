# Desktop-specific modules for Willow
# This file conditionally imports desktop modules only on desktop systems
{
  lib,
  inputs,
  config,
  host ? { isDesktop = false; },
  ...
}: let
  # Check if we're on a desktop system
  isDesktop = host.isDesktop or false;
  
  # Helper function to conditionally import modules
  importIf = condition: module: if condition then [ module ] else [];
  
  # Check for availability of GUI-related inputs
  hasHyprland = inputs ? hyprland;
  hasAnyrun = inputs ? anyrun;
  hasAgs = inputs ? ags;
  hasIronbar = inputs ? ironbar;
in {
  # Only import these modules if we're on a desktop system
  imports = if isDesktop then (
    # Wayland base
    [ ./wayland ] ++
    
    # Optional desktop modules based on available inputs
    (if hasIronbar then [ inputs.ironbar.homeManagerModules.default ] else [])
  ) else [];
  
  # Add desktop-specific options with safe defaults if needed
  options = {};
  
  # Configure desktop-specific settings only when on a desktop system
  config = lib.mkIf isDesktop {
    # Anything that should be applied only on desktop systems
    home.packages = [
      # Desktop tools go here
    ];
    
    # We can set additional desktop-specific configuration here
  };
}