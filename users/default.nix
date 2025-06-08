# Central Users Configuration
{
  lib,
  pkgs,
  ...
}: {
  imports = [
    # User configurations
    ./willow
    ./system
  ];

  # Common settings for all users
  users = {
    mutableUsers = lib.mkDefault true;

    # Defaults that apply to all users
    defaultUserShell = pkgs.bash;
  };

  # Common user-related programs
  programs = {
    zsh.enable = true;
  };
}
