# User configuration for willow
{
  pkgs,
  config,
  host,
  ...
}: {
  # Import SSH keys configuration
  imports = [
    ./keys/ssh.nix
  ];

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
    openssh.authorizedKeys.keys = config._module.args.sshKeys.all;
  };

  # Create user group
  users.groups.willow = {};

  # Load different home-manager configurations based on host type
  home-manager.users.willow = {
    imports = if host.isDesktop then [
      # Full desktop configuration with all GUI components
      ./profiles/desktop.nix
    ] else [
      # Basic server configuration with just the essentials
      ./profiles/base.nix
    ];
  };
}
