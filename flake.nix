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
        # custom package
        wizardwatch_utils = {
          url = "path:./packages/wizardwatch_utils";
          inputs.nixpkgs.follows = "nixpkgs";
        };
};
outputs = { self, 
            nixpkgs, 
            home-manager,
            neovim-nightly,
            nixmaster,
            eww,
            nix-doom-emacs,
            wizardwatch_utils,
...}@inputs:
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
		nixmaster = final: prev: {
			nixmaster = (import nixmaster {
				inherit system;
				config = {
					allowUnfree = true;
				};
			});
                };
        };
	# install helper functions
	lib = nixpkgs.lib;
	in {
	homeManagerConfigurations = {
		wyatt = home-manager.lib.homeManagerConfiguration {
			inherit system pkgs username;
			homeDirectory = ("/home/" + username + "/.config");
			configuration = {
				nixpkgs.overlays = [ neovim-nightly.overlay (import ./overlays)];
				imports = [
					(./users + ("/" + username) + /dotfiles/main.nix)
				];
			};
		};
	};
	nixosConfigurations = {
		wizardwatch = lib.makeOverridable lib.nixosSystem {
			# imports the system variable
			inherit system; 
                        # import the config file
                        modules = [
                                { _module.args = inputs; }               
				{ nixpkgs.overlays = [ overlays.nixmaster  (import ./overlays)]; }
				(./common/common.nix)
				#(./common/hsctf.nix)
				(./machines + ("/" + "wizardwatch") + /main.nix)
			];
                };
        	pc1 = lib.makeOverridable lib.nixosSystem {
			# imports the system variable
                        inherit system;
                        # import the config file
                        modules = [
                                { _module.args = inputs; }               
				{ nixpkgs.overlays = [ overlays.nixmaster  (import ./overlays)]; }
				(./common/common.nix)
				#(./common/hsctf.nix)
                                (./machines + ("/" + "pc1") + /main.nix)

			];
		};

	};
};
}
