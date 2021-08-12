{ config, lib, pkgs, ... }:
in {
	programs.neovim = {
		enable = true;
		coc = {
			enable = true;
		};
		vimAlias = true;
		plugins = with pkgs.vimPlugins; [
			coc-nvim
			coc-vimtex
			vimtex
			vim-nix
			nvim-treesitter
		];
	};
}

