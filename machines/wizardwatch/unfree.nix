{ pkgs, config, ... }:
let
  OpenASAR = self: super: {
    discord = super.discord.override { withOpenASAR = true; };
  };
in
{
  nixpkgs = {
    overlays = [OpenASAR];
    config = {
      allowUnfree = true;
    };
  };
  environment.systemPackages = with pkgs; [
    vscode
    discord
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
