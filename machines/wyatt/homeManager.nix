{pkgs, ...}:
{
  home.packages = [
    pkgs.vim
  ];
  fonts.fontconfig = {
    enable = true;
  };
  gtk = {
    enable = true;
    font.name = "JetBrains Mono";
    font.size = 14;
    theme.package = pkgs.dracula-theme;
    theme.name = "Dracula";
  };
}
