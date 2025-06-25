{
  pkgs,
  lib,
  python3,
}: let
  pythonEnv = python3.withPackages (ps:
    with ps; [
      click
      paramiko
      cryptography
      pyyaml
      colorama
      rich
    ]);
in
  pkgs.stdenv.mkDerivation {
    pname = "nixos-deploy-cli";
    version = "1.0.0";

    src = ./.;

    buildInputs = [pythonEnv];

    installPhase = ''
      mkdir -p $out/bin
      cp deploy_cli.py $out/bin/deploy-cli
      chmod +x $out/bin/deploy-cli

      # Fix shebang
      substituteInPlace $out/bin/deploy-cli \
        --replace "#!/usr/bin/env python3" "#!${pythonEnv}/bin/python3"
    '';

    meta = with lib; {
      description = "NixOS deployment CLI tool with SOPS integration";
      license = licenses.mit;
      platforms = platforms.unix;
    };
  }
