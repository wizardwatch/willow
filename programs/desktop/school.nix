{ config, pkgs, lib, trunk, home-manager, self, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    openconnect # Why oh why could my school not just provide a ovpn file
  ];
}
