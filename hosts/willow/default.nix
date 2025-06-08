{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Import hardware configuration
    ./hardware.nix

    # Import Willow-specific configuration
    ./configuration.nix

    # Import modular configuration
    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/virtualization/docker.nix

    ../../users
  ];
}
