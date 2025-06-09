{ config, pkgs, lib, inputs, ... }:

{
  # Enable anyrun
  programs.anyrun = {
    enable = true;
    
    # Basic configuration
    config = {
      plugins = [
        # Applications plugin
        inputs.anyrun.packages.${pkgs.system}.applications
        # Shell plugin for command execution
        inputs.anyrun.packages.${pkgs.system}.shell
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