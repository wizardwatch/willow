```nix{
  description = "Collection of utilities meant to be used with my NixOS configuration.";
  
  inputs = { 
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs {
      inherit system;
    };
    wizardwatch_utils = (with pkgs; stdenv.mkDerivation {
      pname = "wizardwatch_utils";
      version = "0.0.2";
      src = ./.;
      installPhase = ''
        mkdir -p $out/bin
        mv ./lib/wizardwatch_utils.rb $out/bin/wizardwatch_utils
        chmod +x $out/bin/wizardwatch_utils
      '';
    });
  in rec {
      defaultApp = flake-utils.lib.mkApp {
        drv = defaultPackage;
      };
      defaultPackage = wizardwatch_utils;
      devShell = pkgs.mkShell {
        buildInputs = [
          wizardwatch_utils
        ];
      };
  });
}
```
