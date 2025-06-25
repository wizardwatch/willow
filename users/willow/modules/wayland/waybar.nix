{
  pkgs,
  inputs ? {},
  lib,
  host ? { isDesktop = false; },
  ...
}: let
  # Only use this module if we're on a desktop system
  isDesktop = host.isDesktop or false;
in lib.mkIf isDesktop {
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        position = "top";
        height = 30;
        layer = "top";
        modules-left = [
          "hyprland/workspaces"
          "tray"
        ];
        modules-right = [
          "network"
          "custom/wireguard"
          "custom/teavpn"
          "pulseaudio"
          "battery"
          "custom/date"
          "clock"
        ];
        "hyprland/workspaces" = {
          on-click = "activate";
        };
      };
    };
  };
}