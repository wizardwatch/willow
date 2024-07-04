{ config, pkgs, lib, trunk, home-manager, self, inputs, ... }:
{
  users.groups.dockerAccess = {

  };
  users.users.wyatt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "mpd" "audio" "dialout"]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    initialPassword = "mount";/*config.sops.secrets.wyattPassword.path;*/
  };
  users.users.willow = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "mount";
  };
  users.users.dockerFolder = {
    isNormalUser = false;
    isSystemUser = true;
    group = "dockerAccess";
  };
}
