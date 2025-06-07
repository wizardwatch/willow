{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-run"
    "steam-unwrapped"
  ];
  # Common desktop applications for all systems

  environment.systemPackages = with pkgs; [
    # Communication
    signal-desktop
    vesktop         # Better Discord client

    # Productivity
    pdfarranger

    # Media
    mpv
    mpvpaper        # Wallpaper engine using mpv
    gimp
    krita           # Digital painting

    # Development
    zed-editor

    # 3D/CAD
    freecad-wayland
    openscad
    prusa-slicer

    # Gaming
    prismlauncher   # Minecraft launcher

    # System
    pavucontrol     # Audio control
    appimage-run    # Run AppImages
    eww             # Widget toolkit

    # Screen recording/streaming
    (wrapOBS {
      plugins = with obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    })
  ];

  # Enable Bluetooth support
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Enable flatpak for additional app support
  services.flatpak.enable = true;

  # Required programs
  /*
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraEnv = {
        MANGOHUD = true;
        OBS_VKCAPTURE = true;
        RADV_TEX_ANISO = 16;
      };
      extraLibraries = p: with p; [
        atk
      ];
    }
    ;
    };*/
  # GNOME keyring for credentials
  services.gnome.gnome-keyring.enable = true;

  # Enable Xwayland for X11 app compatibility
  programs.xwayland.enable = true;
}
