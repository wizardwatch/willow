{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    hashcat
    netcat-gnu
  ];
  programs = {
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };
}
