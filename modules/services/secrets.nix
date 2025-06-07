{ config, ... }:

{
  # SOPS (Secrets OPerationS) configuration
  # This manages secrets using age encryption

  # Use the project's default secrets file
  sops.defaultSopsFile = ../../secrets/github.yaml;

  # Use SSH host key for age decryption
  sops.age = {
    sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
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
  };
}