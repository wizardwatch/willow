{
  inputs,
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
    # darktable # build broken

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
    deno
    gemini-cli
    python3

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
    iwd
    iwgtk
    lutris
    # support both 32-bit and 64-bit applications
    wineWowPackages.full
    piper
    radeontop

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
  services.foundryvtt = {
    enable = false;
    hostName = "willow";
    minifyStaticFiles = true;
    proxyPort = 443;
    package = inputs.foundry.packages.${pkgs.system}.foundryvtt_13.overrideAttrs {
      #version = "13.0.0+347";
    };
    proxySSL = false;
    upnp = false;
  };
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
  services.ratbagd.enable = true;
  # GNOME keyring for credentials
  services.gnome.gnome-keyring.enable = true;

  # Enable Xwayland for X11 app compatibility
  programs.xwayland.enable = true;

  # Enable iwd for wifi support
  networking.wireless.iwd.enable = true;
}
