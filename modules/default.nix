{ lib, ... }:

{
  # This file exposes all modules in a structured way
  # It allows importing the entire modules directory with:
  # imports = [ ./modules ];

  imports = [
    # Base system modules
    ./base.nix

    # Desktop system modules
    ./desktop.nix

    # Common modules (can be imported individually)
    ./common/nix.nix
    ./common/environment.nix
    ./common/fonts.nix
    ./common/hardware.nix
    ./common/networking.nix


    # Service modules
    ./services/pipewire.nix
    ./services/printing.nix
    ./services/ssh.nix
    ./services/secrets.nix

    # Desktop modules
    ./desktop/wayland.nix
    ./desktop/applications.nix
    ./desktop/security.nix

    # Virtualization modules
    ./virtualization/docker.nix
  ];

  # Module options
  options = {
    # Add any module-specific options here
  };

  # Module implementation
  config = {
    # Add any module-specific configuration here
  };
}
