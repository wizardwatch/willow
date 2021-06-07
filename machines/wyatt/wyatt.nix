# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
#let desktop_common = toString /etc/nixos/common/desktop_common.nix;

#in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./unfree.nix
      ../../common/common_desktop.nix
      ../../common/emacs.nix
    ];
  # Use the systemd-boot EFI boot loader. no touchy
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.ipv4.addresses = [ {
    address = "192.168.1.169";
    prefixLength = 24;
  } ];
  networking.defaultGateway = "192.168.1.1";
  # networking.networkmanager.enable = true;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the GNOME 3 Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome3.enable = true;
  

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  # amd gpu
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.wyatt = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    #shell = pkgs.nushell;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
	environment.systemPackages = with pkgs; [
    ## password entry for gui applications
    polkit_gnome
    ## firefox with a touch of the farside
		firefox-wayland
    ## bloat just got bloated
    # electron
    ## is it wrong to use a pulse audio tool with pipewire
		pavucontrol
    ## stupid noncompliant websites
    # chromium
    ## no longer using nushell. It is too nu
    nushell
    ## if only I could draw
    krita
    ## pipewire equalizer
    pulseeffects-pw
    ## local password manager. Replaced by 'the cloud'
    # pass
    ## Spell check only tested in emacs
    hunspell
    hunspellDicts.en_US-large
    ## desktop notifications
    libnotify
    ## terminal pdf compressor
    ghostscript
    ## file browser
    gnome3.nautilus
    # doesn't work due to a lack of the overall gnome package group
    gnome3.gnome-tweak-tool
    ## java extra credit
    # greenfoot
    ## remote into ras-pi
    nomachine-client
    ## doesn't seem to work on wayland
    #lxappearance
    obs-studio
    ## obs for wlroots
    obs-wlrobs
    ## password manager
    bitwarden
    bitwarden-cli
    ## email, like snail mail, but harder to block the spam!
    mailspring
    ## font fix maybe. Allows use of gnome tweaks. I had to turn on aa.
    gnome.gnome-settings-daemon
    ## boring work just got a little more mundane
    libreoffice-fresh
    ## make the usbs into oses!
    etcher   
	];
	programs.sway = {
  	enable = true;
 		wrapperFeatures.gtk = true; # so that gtk works properly
		extraPackages = with pkgs; [
		  swaylock
		  swayidle
		  wl-clipboard
		  waybar
		  clipman
		  xwayland
		  mako # notification daemon
		  alacritty # Alacritty is the default terminal in the config
   	  wofi
		  oguri
		  grim
		  slurp
  	];
	};
	#
	# XDG-desktop-screenshare
	#
	xdg = {
  	portal = {
    	enable = true;
    	extraPortals = with pkgs; [
      	xdg-desktop-portal-wlr
        # xdg-desktop-portal-gtk
    	];
      ## fixes gtk themeing so that it uses the .config. set to true in order to use native file pickers
    	gtkUsePortal = false;
		};
	};
	environment.sessionVariables = {
    ### probably not needed due to firefox-wayland
   	MOZ_ENABLE_WAYLAND = "1";
    ### makes emacs use .config instead of the home dir. ~/.config breaks at least sway
	  XDG_CONFIG_HOME = "/home/wyatt/.config";
    ### shouldn't be needed but some software is bad
   	XDG_CURRENT_DESKTOP = "sway";
    ### fixes some ugly. TODO: more work on the right numbers
    GDK_SCALE = "1.5";
    GDK_DPI_SCALE = "1";
	};
  
  #
  # flatpak
  #
  # services.flatpak.enable = true;
  
  # Let the passwords be stored in something other than plain text. Required for at least mailspring
  services.gnome.gnome-keyring.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  #
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
