{ config, pkgs, lib, ... }:

{
  # Import the centralized user management
  imports = [
    ../../users
  ];
  
  # Default shell settings (moved to users/default.nix)
  # The common user definitions are now in the users directory
}
