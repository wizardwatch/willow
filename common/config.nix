{ config, pkgs, ...}:{
	# Enable unstable nix so that I can use flakes.
	nix = {
		package = pkgs.nixUnstable;
		extraOptions = ''
			experimental-features = nix-command flakes
			restrict-eval = false
		'';
	};
	networking.nameservers = [ "192.168.1.146" "1.1.1.1" ];
	networking.defaultGateway = "192.168.1.1";
	networking.wireguard.enable = true;
	time.timeZone = "America/New_York";
	services.openssh.enable = true;
	services.openssh.passwordAuthentication = false;
        services.dbus.packages = [ pkgs.gnome3.dconf ];
        services = {
          transmission = {
            enable = true;
            port = 9091;
          };
        };
}
