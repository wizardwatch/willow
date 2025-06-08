# User configuration for willow
{pkgs, ...}: {
  # User account
  users.users.willow = {
    isNormalUser = true;
    description = "Willow";
    extraGroups = [
      "wheel" # Administrator privileges
      "networkmanager"
      "video"
      "audio"
      "docker"
      "dialout" # Serial port access
      "input" # Input devices
    ];
    initialPassword = "mount"; # Change in production
    shell = pkgs.zsh;
    group = "willow";
  };

  # Create user group
  users.groups.willow = {};

  # This is where we would add any additional configurations
  # specific to this user, such as SSH keys, global user settings, etc.
  home-manager.users.willow = {
    imports = [
      ./home.nix
    ];
  };
}
