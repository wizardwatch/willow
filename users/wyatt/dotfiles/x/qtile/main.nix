{ config, pkgs, ... }: {
  home.file = {
    qtile = {
      source = ./config.py;
      target = "./.config/qtile/config.py";
    };
  };
}
