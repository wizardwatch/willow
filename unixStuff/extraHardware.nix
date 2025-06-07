{ pkgs, ... }:
{
  hardware = {
    graphics = {
      enable = true;
      extraPackages = [ 
        pkgs.intel-compute-runtime
        pkgs.mesa
      ];
    };
  };
  services = {
    pulseaudio.enable = false;
  };
}
