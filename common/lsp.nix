{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    rnix-lsp
  ];
}
