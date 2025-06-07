{ config, lib, pkgs, ... }:

{
  # Base configuration for all NixOS systems
  # This module imports all the common modules that should be present on all systems

  imports = [
    # Common system configuration
    ./common/nix.nix
    ./common/users.nix
    ./common/environment.nix
    ./common/fonts.nix
    ./common/hardware.nix
    ./common/networking.nix

    # Core services
    ./services/ssh.nix
    ./services/secrets.nix
  ];

  # Enable basic programs on all systems
  programs = {
    git.enable = true;
  };

  # Set a fallback locale
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    supportedLocales = lib.mkDefault [ "en_US.UTF-8/UTF-8" ];
  };

  # Set basic time settings
  time.timeZone = lib.mkDefault "UTC";

  # Boot loader defaults - can be overridden by specific hosts
  boot.loader = {
    systemd-boot.enable = lib.mkDefault true;
    efi.canTouchEfiVariables = lib.mkDefault true;
  };

  # Set a reasonable state version
  system.stateVersion = lib.mkDefault "23.05";
}
