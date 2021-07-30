{ config, pkgs, ... }:
{
  services = {
    xserver = {
      enable = true;
      displayManager.defaultSession = "none+qtile";
      windowManager.qtile.enable = true;
      videoDrivers = [ "amdgpu" ];
    };
  };
}
