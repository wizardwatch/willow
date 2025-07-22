{
  pkgs,
  lib,
  config,
  ...
}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
      "obsidian"
      "code-cusor"
    ];
  # Common desktop applications for all systems

  environment.systemPackages = with pkgs; [
    # Communication
    signal-desktop
    vesktop # Better Discord client

    # Productivity
    pdfarranger
    firefox
    xfce.thunar
    obsidian

    # Media
    mpv
    mpvpaper # Wallpaper engine using mpv
    gimp
    krita # Digital painting
    darktable

    # Development
    package-version-server # Used for zed-editor
    zed-editor
    rust-analyzer
    cargo
    rustc
    libgcc
    popsicle
    code-cursor
    config.boot.kernelPackages.perf
    valgrind

    # 3D/CAD
    freecad-wayland
    openscad
    prusa-slicer

    # Gaming
    prismlauncher # Minecraft launcher
    gamescope
    # System
    pavucontrol # Audio control
    appimage-run # Run AppImages
    eww # Widget toolkit

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
  programs.thunderbird.enable = true;
  # Required programs
  programs.gamescope = {enable = true;};
  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
    };
    package = pkgs.steam.override {
      extraEnv = {
        MANGOHUD = true;
        OBS_VKCAPTURE = true;
        RADV_TEX_ANISO = 16;
      };
      extraLibraries = p:
        with p; [
          atk
        ];
      extraPkgs = pkgs:
        with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ];
    };
  };
  # GNOME keyring for credentials
  services.gnome.gnome-keyring.enable = true;

  # Enable Xwayland for X11 app compatibility
  programs.xwayland.enable = true;
}
