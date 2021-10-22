_: pkgs: rec {
  haskellPackages = pkgs.haskellPackages.override (old: {
    overrides = pkgs.lib.composeExtensions (old.overrides or (_: _: { }))
      (self: super: rec {
        wizardwatch-xmonad = self.callCabal2nix "wizardwatch-xmonad"
          (pkgs.lib.sourceByRegex  ../machines/wizardwatch/dotfiles/x/xmonad [
            "xmonad.hs"
            "wizardwatch-xmonad.cabal"
          ]) { };
      });
  });
}
