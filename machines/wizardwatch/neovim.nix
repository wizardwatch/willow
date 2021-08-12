{ config, lib, pkgs, ... }:{
	let
		my-plugins = with pkgs.vimPlugins [
			coc-nvim
			coc-vimtex
			vimtex
		];
	in {
		programs.neovim = {
			enable = true;
			coc = {
				enable = true;
			};
			vimAlias = true;
			plugins = my-plugins;
		};
	};

}

