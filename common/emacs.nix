{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    ## the text editor of the past, today
    emacs
    # for emacs pdfs
    poppler
    # for emacs latex
    texlive.combined.scheme-full
    # for emacs github/magit forge
    gnupg
    # for decrypting .authinfo
    pinentry-emacs
    pinentry
    ## emacs and other stuff dependency.
    sqlite
  ];
  #
  # pinentry
  #
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "emacs";
  };
}
