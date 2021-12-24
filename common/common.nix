{ pkgs, config, ... }:{
	imports = [
		./config.nix
                ./packages.nix
                ./lsp.nix
	];
}
