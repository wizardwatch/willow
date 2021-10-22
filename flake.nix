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
        xmonad.url = "github:xmonad/xmonad";
        xmonad-contrib.url = "github:xmonad/xmonad-contrib";
        # Hibernating for when xmonad-extras gets a flake
        # xmonad-extras.url = "github:xmonad/xmonad-extras";
};
outputs = { self, 
            nixpkgs, 
            home-manager,
            neovim-nightly,
            nixmaster,
            eww,
            xmonad,
            xmonad-contrib,
            #xmonad-extras, 
...}@inputs:
let
	system = "x86_64-linux";
	hostname = "wizardwatch";
	username = "wyatt";
	networking.hostname = "${hostname}";
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
				nixpkgs.overlays = [ neovim-nightly.overlay xmonad.overlay xmonad-contrib.overlay (import ./overlays)];
				imports = [
					(./machines + ("/" + hostname) + /dotfiles/main.nix)
				];
			};
		};
	};
	nixosConfigurations = {
		nixos = lib.makeOverridable lib.nixosSystem{
			# imports the system variable
			inherit system; 
                        # import the config file
                        modules = [
                           { _module.args = inputs; }               
				{ nixpkgs.overlays = [ overlays.nixmaster xmonad.overlay xmonad-contrib.overlay (import ./overlays)]; }
				(./common/common.nix)
				#(./common/hsctf.nix)
				(./machines + ("/" + hostname) + /main.nix)
			];
		};
	};
};
}
