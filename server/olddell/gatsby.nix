{ config, pkgs, ... }:
{
 	environment.systemPackages = with pkgs; [
    ## does not work
    nodePackages.gatsby-cli
    nodePackages.npm
    nodejs
    autoconf
    automake
    libtool
    libtool_1_5
    autogen
    autobuild
    coreutils-full
    pkgconfig
    nasm
    libpng
    dpkg
    gettext
    intltool
    mozjpeg
    autoreconfHook
  ];
    
}
