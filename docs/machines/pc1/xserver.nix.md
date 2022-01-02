---
title: xserver.nix
---
```nix
{ config, pkgs, ... }:{
	services = {
		dbus = {
			enable = true;
		};
                xserver = {
			enable = true;
			exportConfiguration = true;
			libinput.enable = true;
			displayManager.startx.enable = true;
			videoDrivers = [ "intel"];
		};
	};
	environment.systemPackages = with pkgs; [
		glxinfo
		xorg.xev
		xorg.xf86inputlibinput
		libinput
		xorg.xrandr
		arandr
        ];
        imports = [
            ../../common/qtile.nix
        ];      
}
```
