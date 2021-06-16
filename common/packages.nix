{config, pkgs, ...}:
let
  my-python-packages = python-packages: with python-packages; [
    pip
    setuptools
    wheel
    pillow
    numpy
    click
    
    # other python packages you want
  ]; 
  python-with-my-packages = pkgs.python39.withPackages my-python-packages;
in
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
    python-with-my-packages
    ## faster grep
    ripgrep
    ## god I hate java
    jdk11
    ## those videos aren't going to download themselves!
    youtube-dl
    ## the prefered way to install rust
    rustup
    nixos-generators
    wireguard
    gcc
    clang
    unzip
  ];
}
