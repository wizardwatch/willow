# Willow-specific NixOS configuration
{
  config,
  pkgs,
  ...
}: {
  # System identification
  networking.hostName = "willow";
  time.timeZone = "America/New_York";
  # Willow-specific packages
  environment.systemPackages = with pkgs; [
    # Add packages specifically needed on this machine
    # but not part of the standard desktop profile
    signal-desktop
    vesktop
    prismlauncher
    freecad-wayland
    openscad
    prusa-slicer
    krita
    mpvpaper
  ];

  # Willow-specific services
  services = {
    # Add any machine-specific service configurations here
    zerotierone = {
      enable = true;
      joinNetworks = [
        # Add network IDs to auto-join
      ];
    };

    # Enable Bluetooth for this machine
    blueman.enable = true;
  };

  # Hardware-specific settings
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  # Virtualization
  virtualisation = {
    docker = {
      enable = true;
      daemon.settings = {
        data-root = "/home/dockerFolder/";
      };
    };
    waydroid.enable = false;
    lxd.enable = false;
  };

  # Machine-specific boot settings
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    initrd.kernelModules = ["amdgpu"];
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
  };

  # Firewall configuration
  networking.firewall = {
    allowedTCPPorts = [27036 27037 49737 6969];
    allowedUDPPorts = [27031 27036 6969 122];
  };

  # State version
  system.stateVersion = "23.05";
}
