{ config, pkgs, ...}:{
	# let me install random packages from githubs. Like the AUR, but even less secure!
	nix = {
		package = pkgs.nixUnstable;
		extraOptions = ''
			experimental-features = nix-command flakes
			restrict-eval = false
		'';
	};
	# No more x! No more x!
	# Enable the X11 windowing system.
	# services.xserver.enable = true;
	#services.xserver.displayManager.lightdm.enable = false;
	networking.nameservers = [ "192.168.1.146" "1.1.1.1" ];
	networking.defaultGateway = "192.168.1.1";
	networking.wireguard.enable = true;
	time.timeZone = "America/New_York";
	services.openssh.enable = true;
	services.openssh.passwordAuthentication = false;
	services.dbus.packages = [ pkgs.gnome3.dconf ];
}
