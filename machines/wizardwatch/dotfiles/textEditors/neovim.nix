{ config, lib, pkgs, ... }:
	let
		perlPkgs = with pkgs.perl532Packages; [
			Appcpanminus
			ArchiveZip
		];
	in {
		home.packages = with pkgs; [
			perl
			perl534Packages.Appcpanminus
                        perl534Packages.ArchiveZip
                        tree-sitter
                        languagetool
		];
		programs.neovim = {
			enable = true;
			#package = pkgs.neovim-nightly/*.neovim-nightly*//*.neovim*/;
			withNodeJs = true;
			withPython3 = true;
			withRuby = true;
			coc = {
				enable = true;
			};
			vimAlias = true;
			plugins = with pkgs.vimPlugins; [
				coc-nvim
				coc-vimtex
				{
                                        plugin = vimtex;
                                        config = '' let g:vimtex_view_method = 'zathura' '';
				}
                                # { plugin = dracula-vim;
                                #	optional = true;
                                # }
                                nvim-base16
				vim-nix
                                undotree
                                {
                                  plugin = nvim-treesitter;
                                  config = ''lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",
  highlight = {
    enable = true,
    disable = {},
  },
 }
EOF'';
                                }
                                ale
                                LanguageTool-nvim
			];
			extraPackages = with pkgs;  [
				neovim-remote
                              ];
                        # setting the colorscheme to dracula seems to break things due to alacritty 
                        extraConfig = ''
                                let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
                                let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"                               
                                set termguicolors
                                colorscheme base16-dracula
                                set spelllang=en
                                hi spellbad gui=undercurl guisp=red cterm=undercurl
                                set spell
                                let g:languagetool_server_jar='${pkgs.languagetool}/share/languagetool-server.jar'
			'';
		};
}

