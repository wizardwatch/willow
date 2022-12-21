{ pkgs, config, ... }:
{
  programs.mako = {
    enable = true;
    output = "DP-2";
  };
}
