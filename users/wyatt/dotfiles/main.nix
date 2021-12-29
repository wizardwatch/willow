{pkgs, ...}:{
	fonts.fontconfig = {
		enable = true;
              };
              services.mpd = {
                enable = true;
                package = pkgs.mpd;
                dataDir = "/home/wyatt/.config/mpd";
                musicDirectory = "/home/wyatt/Music";
                extraConfig = ''
                audio_output {
                  type "pulse"
                  name "fakepipe"
                }
                audio_output {
                  type    "fifo"
                  name    "my_fifo"
                  path    "/tmp/mpd.fifo"
                  format  "44100:16:2"
}
                '';
              };
	gtk = {
		enable = true;
		font.name = "Iosevka";
		font.size = 14;
		theme.package = pkgs.dracula-theme;
		theme.name = "Dracula";
        };
        home.file = {
          river = {
            source = ./wayland/init;
            target = "./.config/river/init";
          };
          eww = {
            source = ./other/eww;
            recursive = true;
            target = "./.config/eww/";
          };
        };
        imports = [
          ./textEditors/neovim.nix
          #./textEditors/emacs/main.nix
          ./wayland/main.nix
          ./x/main.nix
          ./other/ncmpcpp.nix
          ./other/starship.nix
        ];
	programs.foot = {
		enable = true;
		settings = {
			main = {
				term = "xterm-256color";
				font = "Iosevka:size=14";
				dpi-aware = "yes";
			};
			mouse = {
				hide-when-typing = "yes";
                        };
                        colors = {
                          background = "0x282a36";
                        };
		};
	};
}
