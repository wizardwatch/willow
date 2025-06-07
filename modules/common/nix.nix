{ config, lib, pkgs, ... }:

{
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      restrict-eval = false
      # Only use access-tokens if the secret exists
      ${lib.optionalString (config.sops.secrets ? nixAccessTokens) ''
        access-tokens = github.com !include ${config.sops.secrets.nixAccessTokens.path}
      ''}
    '';
    
    # Garbage collection settings
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    
    # Optimization settings
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
    };
    
    # Add nixPath for nix-shell backward compatibility
    nixPath = [
      "nixpkgs=${pkgs.path}"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
    
    # Registry for flakes
    registry.nixpkgs.flake = pkgs.path;
  };
  
  # Allow unfree packages by default
  nixpkgs.config.allowUnfree = true;
  
  # Set system.stateVersion in the host configs, not here
}