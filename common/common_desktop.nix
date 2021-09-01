{ config, pkgs, ...}:
{
	#       #
	# fonts #
	#       #
	virtualisation.virtualbox.host.enable = true;
	users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
	environment.systemPackages = with pkgs; [
		mpv
		gimp
		zathura
                #alacritty
                # terminator
                konsole
		# for rifle used with broot
		ranger
	];
	fonts.fonts = with pkgs; [
		## for everything except :
		jetbrains-mono
		## for emacs, duh
		#emacs-all-the-icons-fonts
		## for waybar icons
		#font-awesome
		## non monospaced text sexifier.
		#roboto
	];
	fonts.fontconfig.defaultFonts.monospace = [
		"JetBrains Mono"
	];
	#fonts.fontconfig.defaultFonts.sansSerif = [
	#	"Roboto-Regular"
	#];
	## fixes some problems problems with pure gtk applications a little bit.
	fonts.fontconfig.hinting.enable = false;
	## made some fonts look really bad
	#fonts.fontconfig.antialias = false;
	#          #
	# pipewire #
	#          #
	# enabling sound.enable is said to cause conflicts with pipewire.
	# sound.enable = true;
	hardware.pulseaudio.enable = false;
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		# If you want to use JACK applications, uncomment this
		jack.enable = true;
	};
}
