{ pkgs, config, ... }:
{
  nixpkgs.config = {
    allowUnfree = true;
  };
  environment.systemPackages = with pkgs; [
    #nixmaster.discord-canary
    nixmaster.osu-lazer
  ];
  #nixpkgs.config.packageOverrides = pkgs: {
  # steam = pkgs.steam.override {
  #  nativeOnly = true;
  # };
  #};
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
}
