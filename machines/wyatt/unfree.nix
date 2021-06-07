{pkgs, config, ...}:
{
  nixpkgs.config = {
    allowUnfree = true;
  };
  environment.systemPackages = with pkgs; [
    nixmaster.discord-canary
  ];
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
}
