{pkgs, config, ...}:
{
  programs.emacs = {
    enable = true;
  };
  home.file.emacs = {
    source = ./init.el;
    target = "./.config/emacs/init.el";
  };
}
