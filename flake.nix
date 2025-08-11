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
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anyrun = {
      url = "github:anyrun-org/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags.url = "github:Aylur/ags";

    # Authentik NixOS module
    authentik-nix = {
      url = "github:nix-community/authentik-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For future deployment capabilities
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex = {
      url = "github:openai/codex";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    foundry = {
      url = "github:reckenrode/nix-foundryvtt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    foundry,
    codex,
    microvm,
    nixpkgs,
    home-manager,
    sops-nix,
    nix-alien,
    ags,
    anyrun,
    ironbar,
    hyprland-contrib,
    hyprland,
    authentik-nix,
    deploy-rs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    # Import the mkHost function
    mkHost = import ./lib/mkHost.nix {inherit inputs system;};

    # Function to create deployment overrides for a host
    mkDeployment = host: host; # Keep the host unchanged - hostname is passed via command line

    # System types
    systemTypes = {
      desktop = {isDesktop = true;};
      server = {isDesktop = false;};
      minimal = {isDesktop = false;};
    };

    # Host definitions
    hosts = {
      # Current system: willow
      willow = mkHost {
        name = "willow";
        username = "willow"; # Explicitly specify the username

        extraSpecialArgs = {
          inherit self;
          host = systemTypes.desktop;
        };
        homeSpecialArgs = {
          inherit self hyprland anyrun ags ironbar;
          host = systemTypes.desktop;
        };
        isDesktop = true; # Mark as a desktop system
      };

      # Server: ivy
      ivy = mkHost {
        name = "ivy";
        username = "willow"; # Using willow user for consistency

        extraSpecialArgs = {
          inherit self microvm;
          host = systemTypes.server;
        };
        isDesktop = false; # Mark as a server system
      };

      # ISO for deployments
      iso = mkHost {
        name = "iso";
        username = null; # Explicitly disable home-manager for ISO

        extraSpecialArgs = {
          inherit self;
          host = systemTypes.server;
        };
        isDesktop = false; # ISO doesn't need desktop features
      };
    };
  in {
    # NixOS configurations
    nixosConfigurations = builtins.mapAttrs (name: host: host.nixosConfig) hosts;

    # Deploy-rs nodes
    deploy.nodes =
      builtins.mapAttrs (name: host: host.deployConfig) hosts
      // {
        # Add ivy with a custom deploy config that can be accessed via .#ivy-custom
        # Example: deploy .#ivy-custom --hostname 192.168.1.20 --ssh-user willow
        "ivy-custom" = (mkDeployment hosts.ivy).deployConfig;
      };

    # Checks for deploy-rs
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    # Packages
    packages.${system} = {
      # ISO image for deployments
      iso = self.nixosConfigurations.iso.config.system.build.isoImage;
    };
  };
}
