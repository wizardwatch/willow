{ config, pkgs, ... }:{
	services = {
		acpid.enable = true;
		dbus = {
			enable = true;
		};
                xserver = {
                        wacom.enable = true;
                        inputClassSections = [
  ''
    Identifier "Wacom One Pen Display 13"
    MatchUSBID "056a:03a6"
    MatchIsTablet "on"
    MatchDevicePath "/dev/input/event*"
    Driver "wacom"
  ''
  ''
    Identifier "Wacom One Pen Display 13"
    MatchUSBID "056a:03a6"
    MatchIsKeyboard "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
                        ''
                        ];
			enable = true;
			exportConfiguration = true;
			xrandrHeads = [
				{
				output = "DisplayPort-3";
				primary = true;
				monitorConfig = ''
				Option "Position" "0 0"
				'';
				}
				{
					output = "DisplayPort-2";
					monitorConfig = ''
						Option "Position" "3440 0"
					'';
				}
				{
					output = "HDMI-A-0";
					monitorConfig = ''
						Option "Position" "855 1440"
					'';
				}
			];
			libinput.enable = true;
			displayManager.startx.enable = true;
			windowManager.qtile.enable = true;
			videoDrivers = [ "amdgpu" ];
		};
	};
	environment.systemPackages = with pkgs; [
		#xterm
		glxinfo
		#xorg.xkill
		xorg.xev
		xorg.xf86inputlibinput
		libinput
		#rofi
		xorg.xrandr
		arandr
	];
}
