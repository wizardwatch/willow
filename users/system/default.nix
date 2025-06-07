# System users configuration
{ config, lib, pkgs, ... }:

{
  # System users
  users.users = {
    # Docker folder user
    dockerFolder = {
      isNormalUser = false;
      isSystemUser = true;
      group = "dockerAccess";
      description = "User for Docker storage";
    };
    
    # Add other system users here as needed
  };

  # System groups
  users.groups = {
    # Docker access group
    dockerAccess = {};
    
    # Other system groups
  };
}