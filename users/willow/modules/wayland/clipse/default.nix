{
  config,
  pkgs,
  lib,
  host ? { isDesktop = false; },
  ...
}: let
  # Only use this module if we're on a desktop system
  isDesktop = host.isDesktop or false;

  # Import the keybindings module
  keybindingsModule = import ./keybindings.nix {inherit pkgs;};

  # Get the clipse configuration from the keybindings module
  clipseConfig = keybindingsModule.getClipseKeybindings;
in {
  options = {
    wayland.clipse = {
      enable = lib.mkEnableOption "Enable Clipse clipboard manager";
    };
  };

  config = lib.mkIf (isDesktop && config.wayland.clipse.enable) {
    # Enable clipse daemon service

    # Add the packages to the user environment
    home.packages = clipseConfig.packages;
  };
}
