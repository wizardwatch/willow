{
  inputs,
  system,
  ...
}:
# This function creates a NixOS configuration with standardized structure
# It combines NixOS configuration and home-manager in a consistent way
{
  # Required parameters
  name, # Hostname
  # Optional user configuration
  username ? null, # Primary user (null means no home-manager)
  # Optional NixOS configuration overrides
  nixosModules ? [], # Additional NixOS modules to include (automatically includes hosts/name/default.nix)
  extraSpecialArgs ? {}, # Additional specialArgs to pass to NixOS
  # Optional home-manager configuration overrides (only used when username is set)
  homeModules ? [], # Additional home-manager modules to include
  homeSpecialArgs ? {}, # Additional specialArgs to pass to home-manager
  # System type for specialized configuration
  isDesktop ? false, # Whether this is a desktop system (with GUI) or server
}: let
  # Access to nixpkgs lib
  lib = inputs.nixpkgs.lib;

  # Common modules for all machines
  baseNixosModules = [
    # Only include home-manager if a username is provided
    (lib.optional (username != null) inputs.home-manager.nixosModules.home-manager)
    inputs.sops-nix.nixosModules.sops
    inputs.microvm.nixosModules.host
    {
      networking.hostName = name;
    }
    # Home-manager configuration (only when a username is provided)
    (lib.optionalAttrs (username != null) {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs =
          {
            inherit inputs system;
            # Only include GUI-related inputs for desktop systems
            inherit (homeSpecialArgs) self;
          }
          // (
            if isDesktop
            then homeSpecialArgs
            else {}
          );

        users.${username} = {...}: {
          imports = homeModules;
          # Set a reasonable default
          home.stateVersion = "23.11";
        };
      };
    })
  ];

  # Automatically include the host's default.nix file
  hostDefaultModule =
    if builtins.pathExists ../hosts/${name}/default.nix
    then [../hosts/${name}/default.nix]
    else [];

  # Combine base modules with machine-specific modules and host default module
  # Flatten the list to remove any nested lists from optionals
  allModules = lib.flatten (baseNixosModules ++ hostDefaultModule ++ nixosModules);

  # Machine-specific special arguments
  allSpecialArgs =
    {
      inherit inputs system;
      host = {
        inherit name isDesktop;
      };
    }
    // extraSpecialArgs;
in {
  # NixOS configuration
  nixosConfig = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = allSpecialArgs;
    modules = allModules;
  };

  # Deploy-rs configuration (for future use)
  deployConfig = {
    hostname = "${name}.local"; # Default hostname (override with --hostname)
    profiles.system = {
      user = "root"; # Default user (override with --ssh-user)
      path = inputs.deploy-rs.lib.${system}.activate.nixos inputs.self.nixosConfigurations.${name};
    };
  };
}
