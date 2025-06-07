{ inputs, system, ... }:

# This function creates a NixOS configuration with standardized structure
# It combines NixOS configuration and home-manager in a consistent way
{ 
  # Required parameters
  name,                   # Hostname
  username ? "willow",    # Primary user 
  
  # Optional NixOS configuration overrides
  nixosModules ? [],      # Additional NixOS modules to include
  extraSpecialArgs ? {},  # Additional specialArgs to pass to NixOS
  
  # Optional home-manager configuration overrides
  homeModules ? [],       # Additional home-manager modules to include
  homeSpecialArgs ? {},   # Additional specialArgs to pass to home-manager
}:

let
  # System settings
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  
  # Common modules for all machines
  baseNixosModules = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    {
      networking.hostName = name;
      
      # Home Manager configuration
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs system;
        } // homeSpecialArgs;
        
        users.${username} = { ... }: {
          imports = homeModules;
          # Set a reasonable default
          home.stateVersion = "23.11";
        };
      };
    }
  ];
  
  # Combine base modules with machine-specific modules
  allModules = baseNixosModules ++ nixosModules;
  
  # Machine-specific special arguments
  allSpecialArgs = {
    inherit inputs system;
    host = { inherit name; };
  } // extraSpecialArgs;

in {
  # NixOS configuration
  nixosConfig = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = allSpecialArgs;
    modules = allModules;
  };
  
  # Deploy-rs configuration (for future use)
  deployConfig = {
    hostname = "${name}.local"; # Default to .local domain, override if needed
    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.${system}.activate.nixos inputs.self.nixosConfigurations.${name};
    };
  };
}