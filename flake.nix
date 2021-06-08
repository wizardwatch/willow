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
    # doesn't seem to work. 
    iso.url = "github:nix-community/nixos-generators";
  };
  outputs = inputs:
    let
      hostname = "wyatt";
      networking.hostname = "${hostname}";
      # set the arch
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        # imports the system variable
        inherit system;
        # enable non free packages
        config = {
          allowUnfree = true;
        }; 
      };
      overlays = {
        nixmaster = final: prev: {
          nixmaster = (import inputs.nixmaster {
            inherit system;
             config = {
               allowUnfree = true;
             };
          });
        };
        iso = final: prev: {
          nixmaster = (import inputs.iso{
            inherit system;
          });
        };
      };
      # install helper functions
      lib = inputs.nixpkgs.lib;
    in {
      homeManagerConfigurations = {
        wyatt = inputs.home-manager.lib.homeManagerConfiguration {
          inherit system pkgs;
          username = hostname;
          homeDirectory = ("/home/" + hostname);
          configuration = {
            imports = [
              (./machines + ("/" + hostname) + /homeManager.nix)
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
            { nixpkgs.overlays = [ overlays.nixmaster ]; }
            # does not work: gives error command flake not found
            { nixpkgs.overlays = [ overlays.iso ]; }
            (./common/common.nix)
            (./common/hsctf.nix)
            (./machines + ("/" + hostname) + ("/" + hostname + ".nix"))
          ];
        };
      };
      
    };
}
