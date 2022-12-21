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
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$nRKieTSd90ywMrPN$fX81v2bNq4Y569MFwYmI9XjxvcmHF/mtcYrgKHLem2MhioqwHEwR1OZchIxNaR6rLKafbsOcrUwIE9B1yeltD/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICMuAtmbBikSQoxYChMawsQUnr39TD6PgCwo8cbE3AdV"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBMdh5NICjc/arvCNfgdbDm3LZlA6VjBxjTx/HY9Mw/ wyatt@wizardwatch"
    ];
  };
  networking.useDHCP = lib.mkDefault true;
  services = {
    xserver = {
      enable = false;
    };
    openssh= {
      passwordAuthentication = false;
      enable = true;
      permitRootLogin = true;
    };
  };
  environment.systemPackages = with pkgs; [
    parted
    gparted
    vim
    git
  ];
}
