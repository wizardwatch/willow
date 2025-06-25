{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "redoak" = {
        hostname = "172.28.0.156";
        user = "willow";
      };
    };
    # Add private key to ssh-agent
    addKeysToAgent = "yes";
  };

  # Enable the SSH agent service
  services.ssh-agent.enable = true;

  # Auto-add the deployment key if it exists
  home.activation.addSshKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ -f /nix/persist/etc/ssh/ssh_host_ed25519_key_willow ]; then
      $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-add /nix/persist/etc/ssh/ssh_host_ed25519_key_willow || true
    fi
  '';
}