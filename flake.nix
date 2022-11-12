{
  description = "My system conf";
  inputs = rec {
    # set the channel
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # enable home-manager
    home-manager.url = "github:nix-community/home-manager/master";
    # tell home manager to use the nixpkgs channel set above.
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # master channel
    nixmaster.url = "github:NixOS/nixpkgs";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    eww.url = "github:elkowar/eww";
    nix-doom-emacs.url = "github:vlaci/nix-doom-emacs";
    spicetify-nix = { 
      url = "github:the-argus/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # custom package
    wizardwatch_utils = {
      url = "path:/etc/nixos/packages/wizardwatch_utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xtodoc = {
      url = "github:wizardwatch/xtodoc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ld = {
      url = "github:Mic92/nix-ld/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self
    , nixpkgs
    , home-manager
    , neovim-nightly
    , nixmaster
    , eww
    , nix-doom-emacs
    , wizardwatch_utils
    , xtodoc
    , nixos-generators
    , flake-utils
    , nix-alien
    , spicetify-nix
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      username = "wyatt";
      pkgs = import nixpkgs {
        # imports the system variable
        inherit system;
        # enable non free packages
        config = {
          allowUnfree = true;
        };
      };
      overlays = {
        /*
        OpenDis = self: super: {
          discord = super.discord.override { withOpenASAR = true; };
        };
        */
        nixmaster = final: prev: {
          nixmaster = (import nixmaster {
            inherit system;
            config = {
              allowUnfree = true;
            };
          });
        };
      };
      overrides = self: super: rec {
          minecraft-bedrock-appimage = super.appimageTools.wrapType2 {
            name = "minecraft-bedrock";
            src = super.fetchurl {
              url = "https://github.com/ChristopherHX/linux-packaging-scripts/releases/download/v0.3.4-688/Minecraft_Bedrock_Launcher-x86_64-v0.3.4.688.AppImage";
              sha256 = "sha256-TP76SypSk9JIOPnSGzpYmp+g40RE4pCuBmAapL7vqzY=";
            };
            extraPkgs = pkgs: with super; [ libpulseaudio alsa-lib alsa-utils zlib ];
          };
      };
      # install helper functions
      lib = nixpkgs.lib;
    in
    {
      homeManagerConfigurations = {
        wyatt = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            inputs.spicetify-nix.homeManagerModule
            ./users/wyatt/dotfiles/home.nix
            {
              nixpkgs = {
                #config.allowUnfreePredicate = (pkg: true);
                overlays = [ neovim-nightly.overlay ];
              };
              home = {
                username = "wyatt";
                homeDirectory = "/home/wyatt/.config";
                stateVersion = "20.09";
              };
            }
          ];
        };
      };
      nixosConfigurations = {
        wizardwatch = lib.makeOverridable lib.nixosSystem {
          # imports the system variable
          inherit system;
          # Taken from nix alien github
          specialArgs = { inherit self; };
          # import the config file
          modules = [
            { _module.args = inputs; }
            { nixpkgs.overlays = [ overlays.nixmaster /*overlays.OpenDis*/ (import ./overlays) overrides]; }
            (./common/common.nix)
            (./machines/wizardwatch/main.nix)
          ];
        };
        pc1 = lib.makeOverridable lib.nixosSystem {
          # imports the system variable
          inherit system;
          # import the config file
          modules = [
            { _module.args = inputs; }
            {
              nixpkgs.overlays = [
                overlays.nixmaster
                (import ./overlays)
              ];
            }
            (./common/common.nix)
            (./machines/pc1/main.nix)
          ];
        };
      };
      installer = nixos-generators.nixosGenerate {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          { _module.args = inputs; }
          {
            nixpkgs.overlays = [
              overlays.nixmaster
              (import ./overlays)
            ];
          }
          ./machines/installer/main.nix
        ];
        format = "iso";
      };

    };
}
