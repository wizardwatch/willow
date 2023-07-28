{ config, pkgs, ... }: {
  # Enable unstable nix so that I can use flakes.
  #imports = [ <sops-nix/modules/sops> ];
  sops.defaultSopsFile = ../secrets/github.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
  #sops.secrets.example-key = {};
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
  nix = {
    #package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      restrict-eval = false
      access-tokens = github.com !include ${config.sops.secrets.nixAccessTokens.path}
    '';
  };
  networking.nameservers = [ "192.168.1.146" "1.1.1.1" ];
  networking.defaultGateway = "192.168.1.1";
  # networking.wireguard.enable = true;
  time.timeZone = "America/New_York";
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.nomad.enableDocker = true;
  virtualisation = {
    docker.enable   = false;
    waydroid.enable = false;
    lxd.enable      = false;
  };
  # This was removed? services.dbus.packages = [ pkgs.gnome3.dconf ];
  # programs.dconf.packages = [ pkgs.gnome3.dconf ];
  services = {
    transmission = {
      enable = true;
    };
  };
}
