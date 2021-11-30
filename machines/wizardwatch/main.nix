{ config, inputs, pkgs, fetchurl, eww, ... }:
let
  publicKey = "AAAAB3NzaC1yc2EAAAADAQABAAABgQDBEq4NHUglnfwIZYT9dIV5RpYE5s+eGBs1DhX8ieoMXDDZDw/kRo9aeWqKlxElpVJepzHtydQdp73PPjYQT5BhuM7Nw/OKRIH2eEYN8BDqPsTJOVgnZ3287O8OStqnmCiBD2AmVEFuaxtnz5sL2PzsdAS20bvdnyig56TzGFkm3RnDrVfS+8RPbSmOzqVA9+xW4NeN/u1CA32VTfRjE696XpHG5Zg2ByCUGot0+yBLgkEj+RBiChg6rtnwga8QOgSLncZtjVS0WFH9u0lhoGBjOtL2qtMZkTVCLcjmE6Fa6Nd8igoss9JmbDQMh7McUxS1D9d4UE4Vh3IPAHAuaVbMvGNZ9upaye90Vt2PuejOXbnQ4dGKmlxq0wAMWx20uVbWiY1VimVeYPlMLeNOcVcHglVGkVChhgMEbDvsl6HcesfgR/tivHgPhXrkF9f2j80O53VIBWltqt2iz06xUiolQNYDYhq+HiXcQI11+gWRDrdgU5Q5B7OVWPVdXonTfkk=";
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./unfree.nix
      ../../common/common_desktop.nix
      #../../common/emacs.nix
      #../../common/WireGuard_Server.nix
      ../../common/ruby.nix
      #../../common/qtile.nix
      ./xserver.nix
    ];
  # Use the systemd-boot EFI boot loader. no touchy
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.hostName = "wizardwatch";
  networking.interfaces.enp0s31f6.ipv4.addresses = [ {
    address = "192.168.1.169";
    prefixLength = 24;
  } ];

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
  boot.initrd.kernelModules = [ "amdgpu" ];
  security.pam.services.swaylock = {};
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
        programs.zsh.enable = true;
	users.users.wyatt = {
		isNormalUser = true;
		extraGroups = [ "wheel" "mpd" "audio" ]; # Enable ‘sudo’ for the user.
		openssh.authorizedKeys.keys = [ ("${publicKey}") ];
                #shell = pkgs.fish;
                shell = pkgs.zsh;
	};
	# List packages installed in system profile. To search, run:
        # $ nix search wget
	environment.systemPackages = with pkgs; [
          #overlaystwo.eww
          (eww.defaultPackage.x86_64-linux)
          musescore
          starship
          inkscape
          openscad
          #fuzzel
          xdg-desktop-portal-wlr
          grim
          slurp
          wl-clipboard
          seatd
          kanshi
          wlr-randr
          swaylock
          haskellPackages.wizardwatch-xmonad
                alacritty
                kitty
                ## password entry for gui applications
                appimage-run 
                nixmaster.polkit_gnome
		## firefox
		firefox
		## is it wrong to use a pulse audio tool with pipewire
		pavucontrol
		## if only I could draw
		krita
		## pipewire equalizer
		pulseeffects-pw
		#only tested in emacs
		hunspell
		hunspellDicts.en_US-large
		## desktop notifications
		libnotify
		## terminal pdf compressor
		#ghostscript
		## file browser
		gnome3.nautilus
		# doesn't work due to a lack of the overall gnome package group
		gnome3.gnome-tweak-tool
		## remote into ras-pi
		nomachine-client
		obs-studio
		## obs for wlroots
		#obs-studio-plugins.wlrobs
		## password manager
		bitwarden
		#bitwarden-cli
		### email, like snail mail, but harder to block the spam!
		mailspring
		## font fix maybe. Allows use of gnome tweaks. I had to turn on aa.
		gnome.gnome-settings-daemon
		## boring work just got a little more mundane
		libreoffice-fresh
		## make the usbs into oses!
		etcher
		## irc. It just won't die
		#weechat
		radeontop
		broot
		nyxt
                ncmpcpp
                helvum
                river
                kile-wl
                multimc
	];
        security.polkit.enable = true; #for river maybe
        programs.dconf.enable = true;
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
		#MOZ_ENABLE_WAYLAND = "1";
		### makes emacs use .config instead of the home dir. ~/.config breaks at least sway
		XDG_CONFIG_HOME = "/home/wyatt/.config";
		### shouldn't be needed but some software is bad
		#XDG_CURRENT_DESKTOP = "sway";
		### fixes some ugly. TODO: more work on the right numbers
		GDK_SCALE = "1.5";
		GDK_DPI_SCALE = "1";
	};
  
  #
  # flatpak
  #
  # services.flatpak.enable = true;
  
  
  # Let the passwords be stored in something other than plain text. Required for at least mailspring
  services = {
    gnome.gnome-keyring.enable = true;
    ympd = {
      enable = true;
    }; 
  };
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
