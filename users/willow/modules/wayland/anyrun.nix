{ config, pkgs, lib, inputs ? {}, host ? { isDesktop = false; }, ... }:

let
  # Only use this module if we're on a desktop system
  isDesktop = host.isDesktop or false;
  
  # Check if anyrun input is available
  anyrun = inputs.anyrun or null;
  anyrunAvailable = isDesktop && anyrun != null && anyrun ? packages;
in

lib.mkIf anyrunAvailable {
  # Enable anyrun only on desktop systems with the anyrun input
  programs.anyrun = {
    enable = true;
    
    # Basic configuration
    config = {
      plugins = [
        # Applications plugin
        anyrun.packages.${pkgs.system}.applications
        # Shell plugin for command execution
        anyrun.packages.${pkgs.system}.shell
      ];
      width = { fraction = 0.3; };
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = false;
      closeOnClick = false;
      showResultsImmediately = false;
      maxEntries = null;
    };
    
    # Configure the shell plugin
    extraConfigFiles = {
      "shell.ron".text = ''
        Config(
          prefix: ":",
          shell: "${pkgs.bash}/bin/bash",
          interm_shell: false,
        )
      '';
    };
  };
}