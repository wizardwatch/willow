{ config, pkgs, lib, ... }:

{
  # Basic hardware configuration common to all systems
  hardware = {


    # Enable Bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # Enable firmware updates
    enableRedistributableFirmware = true;

    # CPU microcode updates
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  # Enable RTKIT for better audio performance
  security.rtkit.enable = true;

  # Make sure pulseaudio is disabled when using pipewire
  services.pulseaudio.enable = false;

  # Boot settings - basic settings that might be shared
  boot = {
    # Default kernel modules
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];

    # Virtual camera support
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="Virtual Camera" exclusive_caps=1
    '';

    # Enable trim for SSDs
    kernelParams = [ "quiet" ];
  };

  # Enable periodic TRIM
  services.fstrim.enable = true;
}
