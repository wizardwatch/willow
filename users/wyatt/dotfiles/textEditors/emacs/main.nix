{ pkgs, config, ... }:
{
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      (with epkgs.elpaPackages;
      [
        auctex
      ]
      )
    ];
  };
  home.file.emacs = {
    source = ./init.el;
    target = "./.config/emacs/init.el";
  };
}
