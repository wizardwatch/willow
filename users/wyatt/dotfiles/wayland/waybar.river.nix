{ config, pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    settings = [{
      modules = { };
      modules-left = [ "river/tags" ];
    }];
  };
}
