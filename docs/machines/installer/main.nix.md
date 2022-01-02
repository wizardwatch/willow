---
title: main.nix
---
```nix
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports = [
    ../../common/common.nix
  ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  users.users.installer = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "password";
  };
  services.xserver = {
    enable = true;
    desktopManager.lxqt.enable = true;
  };
  environment.systemPackages = with pkgs; [
    parted
    gparted
    vim
    git
  ];
}
```
