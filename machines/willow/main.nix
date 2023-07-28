{ config, inputs, trix, pkgs, fetchurl, eww, self, ... }:
let
  publicKey = "AAAAB3NzaC1yc2EAAAADAQABAAABgQDBEq4NHUglnfwIZYT9dIV5RpYE5s+eGBs1DhX8ieoMXDDZDw/kRo9aeWqKlxElpVJepzHtydQdp73PPjYQT5BhuM7Nw/OKRIH2eEYN8BDqPsTJOVgnZ3287O8OStqnmCiBD2AmVEFuaxtnz5sL2PzsdAS20bvdnyig56TzGFkm3RnDrVfS+8RPbSmOzqVA9+xW4NeN/u1CA32VTfRjE696XpHG5Zg2ByCUGot0+yBLgkEj+RBiChg6rtnwga8QOgSLncZtjVS0WFH9u0lhoGBjOtL2qtMZkTVCLcjmE6Fa6Nd8igoss9JmbDQMh7McUxS1D9d4UE4Vh3IPAHAuaVbMvGNZ9upaye90Vt2PuejOXbnQ4dGKmlxq0wAMWx20uVbWiY1VimVeYPlMLeNOcVcHglVGkVChhgMEbDvsl6HcesfgR/tivHgPhXrkF9f2j80O53VIBWltqt2iz06xUiolQNYDYhq+HiXcQI11+gWRDrdgU5Q5B7OVWPVdXonTfkk=";
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./unfree.nix
      ../../common/common_desktop.nix
      ../../common/ruby.nix
      #../../common/home-assistant.nix
      ./xserver.nix
    ];
  # Use the systemd-boot EFI boot loader. no touchy
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  #networking.useDHCP = false;
  #networking.interfaces.enp0s31f6.ipv4.addresses = [{
  #  address = "192.168.1.169";
  #  prefixLength = 24;
  #}];
  networking = {
    hostName = "willow";
    firewall = {
      allowedTCPPorts = [ 27036 27037 ];
      allowedUDPPorts = [ 27031 27036 ];
    };
    interfaces.enp6s0.ipv4.addresses = [{
      address = "192.168.1.169";
      prefixLength = 24;
    }];
    nat = {
      enable = true;
      internalInterfaces = ["ve-*"];
      externalInterface = "enp6s0";
    };
  };
  environment.etc."machine-id".source = "/nix/persist/etc/machine-id";
  environment.etc."ssh/ssh_host_rsa_key".source = "/nix/persist/etc/ssh/ssh_host_rsa_key";
  environment.etc."ssh/ssh_host_rsa_key.pub".source = "/nix/persist/etc/ssh/ssh_host_rsa_key.pub";
  environment.etc."ssh/ssh_host_ed25519_key".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
  environment.etc."ssh/ssh_host_ed25519_key.pub".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key.pub";
systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wants = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
};


  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      brlaser
      mfcl2740dwcupswrapper
    ];
  };
  # amd gpu
  boot = {
    initrd.kernelModules = [ "amdgpu" ];
    #kernelPackages = pkgs.linuxPackages_5_10;
  };
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = [ pkgs.mesa.drivers ];
  };
  sops.secrets.wyattPassword.neededForUsers = true;
  security.pam.services.swaylock = { };
  programs.zsh.enable = true;
  programs.hyprland.enable = true;
  programs.sway.enable = true;
  users.users.wyatt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "mpd" "audio" "dialout"]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ ("${publicKey}") ];
    shell = pkgs.zsh;
    initialPassword = "mount";/*config.sops.secrets.wyattPassword.path;*/
  };
  nixpkgs.overlays = [
    self.inputs.nix-alien.overlay
  ];
  environment.systemPackages = with pkgs; [
    #tor-browser-bundle-bin
    (tor-browser-bundle-bin.override {
      useHardenedMalloc = false;
    })
    aria
    age
    ssh-to-age
    sops
    lyrebird
    inxi
    lutris
    libunwind
    minecraft-bedrock-appimage
    eww-wayland
    nix-alien
    nix-index
    #nix-index-update
    #fuzzel
    ungoogled-chromium
    #xdg-desktop-portal-wlr
    xdg-desktop-portal-hyprland
    grim
    slurp
    wl-clipboard
    seatd
    kanshi
    wlr-randr
    swaylock
    #haskellPackages.wizardwatch-xmonad
    appimage-run
    ## password entry for gui applications
    ## firefox
    firefox-wayland
    emacs28NativeComp
    #only tested in emacs
    hunspell
    hunspellDicts.en_US-large
    ## desktop notifications
    libnotify
    ## remote into ras-pi
    obs-studio
    ## password manager
    # bitwarden
    ## email, like snail mail, but harder to block the spam!
    # mailspring
    ## make the usbs into oses!
    #etcher
    broot
    nyxt
    #ncmpcpp
    helvum
    (river.override { xwaylandSupport = true; })
    #kile-wl
  ];
  security.polkit.enable = true; #for river maybe
  programs.dconf.enable = true;
  #
  # XDG-desktop-screenshare
  #
  xdg = {
    portal = {
      enable = true;
      wlr.enable = true;
      #extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
      #++ lib.optional (!gnome) pkgs.xdg-desktop-portal-gtk;
      ## fixes gtk themeing so that it uses the .config. set to true in order to use native file pickers. If set to true, gtk apps take forever to start. Finish implementing the solution here https://github.com/fufexan/dotfiles/blob/1bb2bb6ed9e196ab97b3891c68064afcbdc7144c/modules/desktop.nix to fix.
      #gtkUsePortal = !gnome;
    };
  };
  environment.sessionVariables = {
    ### probably not needed due to firefox-wayland
    #MOZ_ENABLE_WAYLAND = "1";
    ### makes emacs use .config instead of the home dir. ~/.config breaks at least sway
    XDG_CONFIG_HOME = "/home/wyatt/.config";
    ### shouldn't be needed but some software is bad
    #XDG_CURRENT_DESKTOP = "sway";
    ### fixes some ugly. TODO: more work on the right numbers
    GDK_SCALE = "1.5";
    GDK_DPI_SCALE = "1";
    SPOTIFY = "!include ${config.sops.secrets.spotifyPassword.path}";
  };
  # Let the passwords be stored in something other than plain text. Required for at least mailspring
      #trix.nixosModules.minecraft = true;
      /*
      users.users.minecraft = {
        description     = "Minecraft server service user";
        isSystemUser    = true;
        group           = "minecraft";
      };
      users.groups.minecraft = {};
      systemd.services.minecraft = {
        wantedBy = [ "default.target" ];
        after = [ "network.target" ];
        description = "start minecraft";
        serviceConfig = {
        Type = "simple";
        User = "wyatt";
        RestartSec = "10s";
        Restart = "always";
        StandardError= "journal";

        # run the start script for the specified server
        ExecStart = ''
        /usr/bin/env bash $(wget https://raw.githubusercontent.com/wizardwatch/winter-wonderland-pack/main/start.sh) 
        '';
        WorkingDirectory = /etc/minecraft;
      };
    };*/
  services = {
    flatpak.enable = true;
    gnome.gnome-keyring.enable = true;
    ympd = {
      #enable = true;
    };
    fstrim.enable = true;
  };
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  #system.stateVersion = "20.09"; # Did you read the comment?

  system.stateVersion = "23.05"; # Did you read the comment?
}
