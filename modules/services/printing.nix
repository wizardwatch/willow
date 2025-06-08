{
  pkgs,
  lib,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "brgenml1lpr"
    ];
  # Printing services
  services.printing = {
    enable = true;

    # CUPS browsing and sharing
    browsing = true;
    listenAddresses = ["*:631"]; # Listen on all interfaces
    allowFrom = ["all"]; # Allow from all hosts
    defaultShared = true;

    # Common printer drivers
    drivers = with pkgs; [
      gutenprint
      gutenprintBin
      brlaser
      brgenml1lpr
      brgenml1cupswrapper
    ];
  };

  # Enable Avahi for printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
      addresses = true;
      domain = true;
    };
  };

  # Add scanning support
  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.sane-airscan];
  };
  # The Brother_MFC_J4335DW printer is currently unsupported by NixOS. See https://github.com/NixOS/nixpkgs/issues/395055
  # Add printing related utilities
  environment.systemPackages = with pkgs; [
    system-config-printer
    simple-scan
  ];

  # Open firewall for printer discovery and access
  networking.firewall.allowedTCPPorts = [631];
  networking.firewall.allowedUDPPorts = [631];
}
