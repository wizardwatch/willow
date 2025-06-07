{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    openconnect # Why oh why could my school not just provide a ovpn file
    maven # A build tool much worse than nix
    obsidian # Notes to organize my life, academics, and DND
    zoom-us # The one and only video conferencing application used by both my school and doctors
  ];
}
