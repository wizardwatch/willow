{ config, pkgs, inputs, ... }: {
  xsession.windowManager.xmonad = {
    enable = true;
    #enableContribAndExtras = true;
    extraPackages = haskellPackages: [ haskellPackages.xmonad-contrib ];
    config = ./xmonad.hs;
    package = pkgs.haskellPackages.wizardwatch-xmonad.defaultPackage.x86_64-linux;
  };
}
