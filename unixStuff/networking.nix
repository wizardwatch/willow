{ config, pkgs, lib, trunk, home-manager, self, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
  networking = {
    hostName = "willow";
    firewall = {
      allowedTCPPorts = [ 27036 27037 49737 6969];
      allowedUDPPorts = [ 27031 27036 6969 122];
    };
    # Used previously, likely useful in the future
    /*
    interfaces.enp6s0.ipv4.addresses = [{
      address = "192.168.1.169";
      prefixLength = 24;
    }];
    nat = {
      enable = true;
      internalInterfaces = ["ve-*"];
      externalInterface = "enp6s0";
    };*/
    nameservers = [ "192.168.0.1" ];
    networkmanager.enable = true;
    extraHosts = ''
      10.129.229.198 board.htb crm.board.htb test.board.htb
      10.129.222.148 boardlight.htb
    '';
  };
}
