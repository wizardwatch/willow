{
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
    wut = (with pkgs; stdenv.mkDerivation {
      pname = "wut";
      version = "0.0.2";
      src = ./.;
      installPhase = ''
        mkdir -p $out/bin
        mv ./wut.rb $out/bin/wut
        chmod +x $out/bin/wut
      '';
    });
  in rec {
      defaultApp = flake-utils.lib.mkApp {
        drv = defaultPackage;
      };
      defaultPackage = wut;
      devShell = pkgs.mkShell {
        buildInputs = [
          wut
        ];
      };
  });
}
