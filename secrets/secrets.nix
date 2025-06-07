{ config, ... }:
{  
  sops.defaultSopsFile = ./github.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
  sops = {
    secrets.nixAccessTokens = {
      mode = "0440";
      group = config.users.groups.keys.name;
    };
    secrets.spotifyPassword = {
      mode = "0440";
      group = config.users.groups.keys.name;
    };
  };
}
