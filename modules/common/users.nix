{ config, pkgs, lib, ... }:

{
  # Define user groups
  users.groups = {
    willow = {};
    wyatt = {};
    dockerAccess = {};
  };

  # Main user accounts
  users.users = {
    # Primary user
    willow = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
      # Use password file in production
      initialPassword = "nixos";
      shell = pkgs.zsh;
      group = "willow";
    };
    
    # Secondary user
    wyatt = {
      isNormalUser = true;
      extraGroups = [ "wheel" "mpd" "audio" "dialout" ];
      shell = pkgs.zsh;
      initialPassword = "nixos";
      group = "wyatt";
      # For production use SOPS:
      # passwordFile = config.sops.secrets.wyattPassword.path;
    };
    
    # System user for Docker
    dockerFolder = {
      isNormalUser = false;
      isSystemUser = true;
      group = "dockerAccess";
    };
  };
  
  # Define and use secrets in production
  # sops.secrets.wyattPassword = {
  #   neededForUsers = true;
  # };
  
  # Default shell settings
  programs.zsh.enable = true;
}