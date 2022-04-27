{ config, pkgs, ...}:
{
        # Was causing kernel problems
        #virtualisation.virtualbox.host.enable = true;
        #users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
	environment.systemPackages = with pkgs; [
	  mpv
	  gimp
          nixmaster.zathura
          gnome.cheese
          alacritty
	  # for rifle used with broot
          ranger
          inkscape
          openscad
          musescore
          pavucontrol
          ## pipewire equalizer
          pulseeffects-pw
          ## if only I could draw
          krita
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
	hardware.pulseaudio.enable = false;
	security.rtkit.enable = true;
        services.pipewire = {
          media-session.enable = true;
          wireplumber.enable = false;
	  enable = true;
	  alsa.enable = true;
	  alsa.support32Bit = true;
	  pulse.enable = true;
	  jack.enable = false;
	};
}
