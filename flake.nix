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
    sops-nix.url = "github:Mic92/sops-nix/feat/home-manager";
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
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags.url = "github:Aylur/ags";
  };
  outputs = 
    { self
    , nixpkgs
    , trunk
    , home-manager
    , sops-nix
    , nix-alien
    , ags
    , ironbar
    , anyrun
    , hyprland-contrib
    , hyprland
    , ...
    }@inputs: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        # imports the system variable
        inherit system;
        # enable non free packages
        config = {
          allowUnfree = true;
        };
      };
    in{
    nixosConfigurations.willow = nixpkgs.lib.nixosSystem{
      system = "x86_64-linux";
      specialArgs = { 
        inherit self;
        inherit inputs;
      };
      modules =
        [
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          (trunk.nixosModules.common)
          (import ./main.nix)
          (import ./hardware.nix)
          ({ pkgs, lib, ... }: {
            home-manager = {
              extraSpecialArgs = {
                inherit self;
                inherit inputs;
                inherit system;
                inherit hyprland;
              };
              useUserPackages = true;
              users.willow = pkgs.lib.mkMerge [
                (trunk.nixosModules.userZshStarship)
                (trunk.nixosModules.userHyprland (import ./overrides/hyprland.nix))
                inputs.ironbar.homeManagerModules.default
                inputs.anyrun.homeManagerModules.default
                (import ./home.nix)
              ];
            };
          })
        ];
    };
  };
}
