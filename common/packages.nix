{ config, pkgs, wizardwatch_utils, xtodoc, ... }:
let
  my-python-packages = python-packages: with python-packages; [
    pip
    setuptools
    wheel
    pillow
    numpy
    click
    pycrypto
    black
    gmpy2
    # other python packages you want
  ];
  python-with-my-packages = pkgs.python39.withPackages my-python-packages;
  myKakoune =
    let
      config = pkgs.writeTextFile (rec {
        name = "kakrc.kak";
        destination = "/share/kak/autoload/${name}";
        text = ''
          set global ui_options ncurses_assistant=cat
        '';
      });
    in
    pkgs.kakoune.override {
      plugins = with pkgs.kakounePlugins; [
        config
        connect-kak
        parinfer-rust
        kakoune-rainbow
        prelude-kak
        pandoc-kak
      ];
    };
in
{
  environment.systemPackages = with pkgs; [
    (xtodoc.defaultPackage.x86_64-linux)
    (wizardwatch_utils.defaultPackage.x86_64-linux)
    tree
    glow
    hugo
    gcc
    #clang-tools
    ffmpeg
    jq
    ## source control; linus style
    git
    ## download the web right to your own computer!
    wget
    ## monitor all the things, except gpu usage.
    htop
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
    #nixos-generators
    tmux
    unzip
    # myKakoune
    tldr
    pandoc
    texlive.combined.scheme-full
    starship
    breeze-icons
    tokei
  ];
}
