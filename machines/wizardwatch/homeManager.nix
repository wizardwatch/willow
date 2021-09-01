{pkgs, ...}:{
	fonts.fontconfig = {
		enable = true;
	};
	#gtk = {
	#	enable = true;
#	#	font.name = "JetBrains Mono";
	#	font.size = 14;
#		theme.package = pkgs.dracula-theme;
#		theme.name = "Dracula";
	#};
	imports = [./nvim/neovim.nix];
	programs.foot = {
		enable = true;
		settings = {
			main = {
				term = "xterm-256color";
				font = "JetBrains Mono:size=14";
				dpi-aware = "yes";
			};
			mouse = {
				hide-when-typing = "yes";
			};
		};
	};
}
