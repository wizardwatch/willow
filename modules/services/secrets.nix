{
  config,
  lib,
  ...
}: {
  # SOPS (Secrets OPerationS) configuration
  # This manages secrets using age encryption
  # Prerequisites (SSH keys, directories) are handled by the deployment CLI tool

  # Use the project's default secrets file
  sops.defaultSopsFile = ./secrets/github.yaml;

  # Use SSH host key for age decryption
  sops.age = {
    sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    keyFile = "/var/lib/sops-nix/key.txt";
    generateKey = true;
  };

  # Define the secrets that should be available
  sops.secrets = {
    # GitHub access tokens for Nix
    nixAccessTokens = {
      mode = "0440";
      group = config.users.groups.keys.name;
    };

    # Spotify credentials
    spotifyPassword = {
      mode = "0440";
      group = config.users.groups.keys.name;
    };

    # User password for wyatt
    wyattPassword = {
      neededForUsers = true;
    };

    # Private SSH key for deployment with deploy-rs
    ssh_key = {
      sopsFile = ./secrets/ssh_willow.yaml;
      mode = "600"; # Explicitly set restrictive permissions
      path = "/nix/persist/etc/ssh/ssh_host_ed25519_key_willow"; # Path where the key will be stored
      owner = "willow"; # Ensure willow owns the key
      group = "willow"; # Ensure willow's group has access
    };
  };

  users.users."willow".openssh.authorizedKeys = {
    keys = [config.sops.secrets.ssh_key.path];
  };

  /*
    # SSH configuration for deploy-rs
  programs.ssh = {
    # SSH client configuration to use the key

    extraConfig = lib.optionalString (config.sops.secrets ? ssh_key) ''
      # Configuration for deploy-rs SSH key
      IdentityFile ${config.sops.secrets.ssh_key.path}
    '';
    };
  */
}
