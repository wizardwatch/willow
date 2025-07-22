{
  pkgs,
  lib,
  hyprland,
  ...
}: let
  # Import the clipse keybindings to get package requirements
  clipseKeybindings = import ../clipse/keybindings.nix {inherit pkgs;};
  clipseConfig = clipseKeybindings.getClipseKeybindings;
in {
  # Ensure Hyprland prerequisites are installed
  home.packages = with pkgs;
    [
      hyprpaper # Wallpaper utility for Hyprland
      grimblast # Screenshot utility for Hyprland
      brightnessctl # Brightness control
      libnotify # Notifications
      wl-clipboard # Clipboard utilities
      zenity # File dialogs for screenshot save
      imv # Lightweight image viewer for screenshot preview
      playerctl # Media player control for video detection
    ]
    ++ clipseConfig.packages
    # Add Hyprland package if not provided via inputs
    ++ lib.optional (hyprland == null) pkgs.hyprland;
}
