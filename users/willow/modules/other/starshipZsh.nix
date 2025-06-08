{ pkgs, config, ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    envExtra = ''
      eval "$(starship init zsh)"
    '';
  };
}