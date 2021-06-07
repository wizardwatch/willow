{config, pkgs, masterpkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    ## source control; linus style
    git
    ## download the web right to your own computer!
    wget
    ## monitor all the things, except gpu usage.
    htop
    ## the cool kids all use vim, so I should too.
    vim
    ## manage my things
    home-manager
    ## python
    python39
    ## faster grep
    ripgrep
    ## god I hate java
    jdk11
    ## those videos aren't going to download themselves!
    youtube-dl
    ## the prefered way to install rust
    rustup
  ];
}
