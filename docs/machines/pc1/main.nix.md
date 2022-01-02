---
title: main.nix
---
```nix
{ config, inputs, pkgs, fetchurl, eww, ... }:
let
  publicKey = "AAAAB3NzaC1yc2EAAAADAQABAAABgQDBEq4NHUglnfwIZYT9dIV5RpYE5s+eGBs1DhX8ieoMXDDZDw/kRo9aeWqKlxElpVJepzHtydQdp73PPjYQT5BhuM7Nw/OKRIH2eEYN8BDqPsTJOVgnZ3287O8OStqnmCiBD2AmVEFuaxtnz5sL2PzsdAS20bvdnyig56TzGFkm3RnDrVfS+8RPbSmOzqVA9+xW4NeN/u1CA32VTfRjE696XpHG5Zg2ByCUGot0+yBLgkEj+RBiChg6rtnwga8QOgSLncZtjVS0WFH9u0lhoGBjOtL2qtMZkTVCLcjmE6Fa6Nd8igoss9JmbDQMh7McUxS1D9d4UE4Vh3IPAHAuaVbMvGNZ9upaye90Vt2PuejOXbnQ4dGKmlxq0wAMWx20uVbWiY1VimVeYPlMLeNOcVcHglVGkVChhgMEbDvsl6HcesfgR/tivHgPhXrkF9f2j80O53VIBWltqt2iz06xUiolQNYDYhq+HiXcQI11+gWRDrdgU5Q5B7OVWPVdXonTfkk=";
in
{
  imports =
    [
      ./hw_config.nix
      ../../common/common_desktop.nix
      ../../common/ruby.nix
    ];
  # Use the systemd-boot EFI boot loader. This is required for uefi boot.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Set up` networking
  networking = {
    # While my first machine, my desktop, is named wizardwatch moving forward all machines will get a suffix, dc for desktop computer, pc for portable computer, and server. This is followed by a number representing the order in which they where assimilated.
    hostName = "pc1";
    # Sometimes enp0s13f0u3u4 is not connected, it is a USB network adapter. By default this adds 1.5 minutes to the boot time while the nonexistent interface attempts to receive an IP address. This instead forks it immediately.
    dhcpcd = {
      wait = "background";
    };
    interfaces = {
      # built in wireless adapter
      wlp0s20f3.useDHCP = true;
      # USB Ethernet adapter
      enp0s13f0u3u4.useDHCP = true;
    };
    wireless = {
      enable = true;
    };
  };
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      brlaser
    ];
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
        programs.zsh.enable = true;
	users.users.wyatt = {
		isNormalUser = true;
		extraGroups = [ "wheel" "mpd" "audio" ]; # Enable ‘sudo’ for the user.
		openssh.authorizedKeys.keys = [ ("${publicKey}") ];
                shell = pkgs.zsh;
	};
	environment.systemPackages = with pkgs; [
          musescore
          starship
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
		obs-studio
		## password manager
		bitwarden
		### email, like snail mail, but harder to block the spam!
		mailspring
		## font fix maybe. Allows use of gnome tweaks. I had to turn on aa.
		gnome.gnome-settings-daemon
		## boring work just got a little more mundane
		libreoffice-fresh
		## make the usbs into oses!
		etcher
		radeontop
		broot
		nyxt
                ncmpcpp
                helvum
                kile-wl
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
  # services.flatpak.enable = true;
  # Let the passwords be stored in something other than plain text. Required for at least mailspring
  services = {
    gnome.gnome-keyring.enable = true;
    ympd = {
      enable = true;
    };
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
```
