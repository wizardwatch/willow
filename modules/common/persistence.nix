{ config, lib, ... }:

{
  # This module configures an ephemeral root filesystem with specific
  # directories persisted across reboots.
  
  # Root filesystem as tmpfs
  fileSystems."/" = lib.mkIf (config.boot.initrd.postDeviceCommands != "") {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=8G" "mode=755" ];
  };
  
  # Persistent directories
  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/nixos"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
    users.willow = {
      directories = [
        ".ssh"
        ".gnupg"
        ".mozilla"
        ".config/Signal"
        ".local/share/keyrings"
        "Documents"
        "Pictures"
        "Videos"
        "Downloads"
        "Projects"
      ];
    };
  };
  
  # Ensure required directories exist
  system.activationScripts.persistentDirs = ''
    mkdir -p /nix/persist/etc/nixos
    mkdir -p /nix/persist/var/log
  '';
}