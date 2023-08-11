{ config, pkgs, lib, trunk, home-manager, self, inputs, ... }:
{
         nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
             "steam"
             "steam-original"
           ];
         
  sops.defaultSopsFile = ./secrets/github.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
  sops = {
    secrets.nixAccessTokens = {
      mode = "0440";
      group = config.users.groups.keys.name;
    };
    secrets.spotifyPassword = { 
      mode = "0440";
      group = config.users.groups.keys.name;
    };
  };
  users.users.willow = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "";
  };
  environment = {
    sessionVariables = {
      HOME = "/home/willow/";
      XDG_CONFIG_HOME = "/home/willow/.config";
      GDK_SCALE = "1.5";
      GDK_DPI_SCALE = "1";
    };
  };
  programs = {
    hyprland.enable = true;
  };
  environment.systemPackages = with pkgs; [
    inputs.ags.packages.x86_64-linux.default
    networkmanagerapplet
    mpvpaper
    socat
    tree
    glow
    hugo
    gcc
    #clang-tools
    ffmpeg
    jq
    ## source control; linus style
    git
    ## download the web right to your own computer!
    wget
    ## monitor all the things, except gpu usage.
    htop
    ## faster grep
    ripgrep
    ## god I hate java
    jdk11
    ## those videos aren't going to download themselves!
    youtube-dl
    ## the prefered way to install rust
    rustup
    #nixos-generators
    tmux
    unzip
    # myKakoune
    tldr
    pandoc
    breeze-icons
    tokei
    gnome.cheese
    gnome.gnome-boxes
    alacritty
    # for rifle used with broot
    ranger
    inkscape
    openscad
    musescore
    pavucontrol
    ## pipewire equalizer
    easyeffects
    qpwgraph
    ## if only i could draw
    krita
    prusa-slicer
    logseq
    mpv
    gimp
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
    inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
  ];
  #       #
  # fonts #
  #       #
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Iosevka Nerd Font" ];
        serif = [ "Iosevka Etoile" ];
        sansSerif = [ "Iosevka Aile" ];
      };
    };
    fonts = with pkgs; [
      (iosevka-bin.override { variant = "aile"; })
      (iosevka-bin.override { variant = "etoile"; })
      (nerdfonts.override { fonts = [ "Iosevka" ]; })
      ibm-plex
    ];
  };
  ## fixes some problems problems with pure gtk applications a little bit.
  # fonts.fontconfig.hinting.enable = false;
  ## made some fonts look really bad
  #fonts.fontconfig.antialias = false;
  #          #
  # pipewire #
  #          #
  # enabling sound.enable is said to cause conflicts with pipewire. Cidkid says it does not?
  #sound.enable = true;
  environment.etc = let
    json = pkgs.formats.json {};
  in {
      "machine-id".source = "/nix/persist/etc/machine-id";
      "ssh/ssh_host_rsa_key".source = "/nix/persist/etc/ssh/ssh_host_rsa_key";
      "ssh/ssh_host_rsa_key.pub".source = "/nix/persist/etc/ssh/ssh_host_rsa_key.pub";
      "ssh/ssh_host_ed25519_key".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
      "ssh/ssh_host_ed25519_key.pub".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key.pub";
    "/etc/pipewire/pipewire.conf.d/pipewire.conf".source = json.generate "pipewire.conf" {
      context.objects = [
        {
          factory = "adapter";
          args = {
            "factory.name"     = "support.null-audio-sink";
            "node.name"        = "Game_Audio";
            "node.description" = "Game Output";
            "media.class"      = "Audio/Sink";
            "audio.position"   = "FL,FR";
          };
        }
        {
          factory = "adapter";
          args = {
            "factory.name"     = "support.null-audio-sink";
            "node.name"        = "Game-Mic-Proxy";
            "node.description" = "Game Mic";
            "media.class"      = "Audio/Source/Virtual";
            "audio.position"   = "FL,FR";
          };
        }
    ];
  };
};
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    wireplumber.enable = true;
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = false;
  };
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      restrict-eval = false
      access-tokens = github.com !include ${config.sops.secrets.nixAccessTokens.path}
    '';
  };
  networking = {
    nameservers = [ "192.168.1.146" "1.1.1.1" ];
    defaultGateway = "192.168.1.1";
    networkmanager.enable = true;
  };
  time.timeZone = "America/New_York";
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  virtualisation = {
    docker.enable   = false;
    waydroid.enable = false;
    lxd.enable      = false;
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
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



  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      brlaser
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
  users.users.wyatt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "mpd" "audio" "dialout"]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    initialPassword = "mount";/*config.sops.secrets.wyattPassword.path;*/
  };
  nixpkgs.overlays = [
    self.inputs.nix-alien.overlay
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
    };
  };
  services = {
    flatpak.enable = true;
    gnome.gnome-keyring.enable = true;
    fstrim.enable = true;
  };
  system.stateVersion = "23.05"; 
}
