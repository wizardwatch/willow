{
  inputs = {
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # USED TO GET WAYBAR PKG
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ironbar = {
      url = "github:JakeStanger/ironbar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    trunk = {
      url = "github:wizardwatch/trunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anyrun = {
      url = "github:anyrun-org/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags.url = "github:Aylur/ags";

    # For future deployment capabilities
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self
    , nixpkgs
    , trunk
    , home-manager
    , sops-nix
    , nix-alien
    , ags
    , anyrun
    , ironbar
    , hyprland-contrib
    , hyprland
    , deploy-rs
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      # Import the mkHost function
      mkHost = import ./lib/mkHost.nix { inherit inputs system; };
      # Host definitions
      hosts = {
        # Current system: willow
        willow = mkHost {
          name = "willow";
          username = "willow"; # Explicitly specify the username
          nixosModules = [
            # Pass trunk modules to home-manager
            ({ ... }: {
              home-manager.users.willow = { ... }: {
                imports = [
                  (trunk.nixosModules.userZshStarship)
                  (trunk.nixosModules.userHyprland (import ./overrides/hyprland.nix))
                  inputs.ironbar.homeManagerModules.default
                ];
              };
            })
          ];
          extraSpecialArgs = {
            inherit self;
          };
          homeSpecialArgs = {
            inherit self hyprland anyrun ags ironbar;
          };
        };


        # ISO for deployments
        iso = mkHost {
          name = "iso";
          username = null; # Explicitly disable home-manager for ISO
          nixosModules = [];
          extraSpecialArgs = {
            inherit self;
          };
        };
      };

    in {
      # NixOS configurations
      nixosConfigurations = builtins.mapAttrs (name: host: host.nixosConfig) hosts;

      # Deploy-rs nodes (for future use)
      deploy.nodes = builtins.mapAttrs (name: host: host.deployConfig) hosts;

      # Checks for deploy-rs
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      # ISO image for deployments
      packages.${system}.iso = self.nixosConfigurations.iso.config.system.build.isoImage;
    };
}
