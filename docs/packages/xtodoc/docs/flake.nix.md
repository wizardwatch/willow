```nix```
# About
This file contains Nix code used to allow the installation of xtodoc via the experimental
flakes feature.
```nix
{
  description = "Utility for generating markdown documentation from comments in code";
```
  While xtodoc doesn't depend on any packages except ruby, I follow my standard generic
  installation method, and thus begin by taking the inputs necessary to pull dependencies
  and build code for various platforms. I then take them as outputs. I use various
  flake-utils functions to make this package definitions easier to write, beginning by
  using one to target the current system architecture. Again, this is unnecessary for a
  simple script but it is nice to keep it standard.
```nix
  inputs = { 
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs {
      inherit system;
    };
    xtodoc = (with pkgs; stdenv.mkDerivation {
      pname = "xtodoc";
      version = "0.0.1";
      src = ./.;
```
      During the installPhase I move the ruby file to the appropriate location for it to
      be run when the command xtodoc is run.
```nix
      installPhase = ''
        mkdir -p $out/bin
        mv ./xtodoc.rb $out/bin/xtodoc
        chmod +x $out/bin/xtodoc
      '';
    });
```
    In the following section I allow xtodoc to either be installed or tested in a nix
    shell environment.
```nix
    in rec {
      defaultApp = flake-utils.lib.mkApp {
        drv = defaultPackage;
      };
      defaultPackage = xtodoc;
      devShell = pkgs.mkShell {
        buildInputs = [
          xtodoc
        ];
      };
  });
}
```
