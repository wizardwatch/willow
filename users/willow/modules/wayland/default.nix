{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hyprland.nix
    ./anyrun.nix
    ./waybar.nix
    ./clipse
  ];
  
  # Enable clipse clipboard manager
  wayland.clipse.enable = true;
}