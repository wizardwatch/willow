{ config, pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainbar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
      };
    };
  };
}
