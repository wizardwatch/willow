{ config, pkgs, lib, trunk, home-manager, self, inputs, ... }:
{
  hardware = {
    graphics = {
      enable = true;
      extraPackages = [ 
        pkgs.intel-compute-runtime
        pkgs.mesa.drivers
      ];
    };
    pulseaudio.enable = false;
  };
}
