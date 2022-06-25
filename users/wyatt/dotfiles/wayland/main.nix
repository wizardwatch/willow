{ pkgs, ... }: {
  home.packages = with pkgs; [
    fuzzel
  ];
  imports = [
    ./waybar.nix
    ./sway.nix
    ./mako.nix
    ./kanshi.nix
  ];
}
