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
    discord-canary
    nixmaster.osu-lazer
  ];
  #nixpkgs.config.packageOverrides = pkgs: {
  # steam = pkgs.steam.override {
  #  nativeOnly = true;
  # };
  #};
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  hardware.steam-hardware.enable = true;
}
