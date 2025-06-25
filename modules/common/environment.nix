{pkgs, ...}: let
  # Local deployment CLI tool
  deploy-cli = pkgs.callPackage ../../tools {};
in {
  # Basic environment configuration
  environment = {
    # Session variables
    sessionVariables = {
      # Scaling for HiDPI displays
      GDK_SCALE = "1.5";
      GDK_DPI_SCALE = "1";
    };

    # Persistent files - for systems using tmpfs root
    etc = {
      "machine-id".source = "/nix/persist/etc/machine-id";
      "ssh/ssh_host_rsa_key".source = "/nix/persist/etc/ssh/ssh_host_rsa_key";
      "ssh/ssh_host_rsa_key.pub".source = "/nix/persist/etc/ssh/ssh_host_rsa_key.pub";
      "ssh/ssh_host_ed25519_key".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
      "ssh/ssh_host_ed25519_key.pub".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key.pub";
      "ssh/ssh_host_ed25519_key_willow".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key_willow";
      "ssh/ssh_host_ed25519_key_willow.pub".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key_willow.pub";
    };

    # System packages available to all hosts
    systemPackages = with pkgs; [
      # Basic utilities
      curl
      wget
      git
      tree
      jq
      ripgrep
      inxi
      deploy-rs

      # Terminal utilities
      tmux
      htop
      broot
      tldr
      sshfs

      # Editors
      vim

      # Nix tools
      # nix-alien
      nix-index
      nil
      alejandra
      nixd

      # Security
      age
      ssh-to-age
      sops

      # Deployment tools
      deploy-cli
    ];
  };

  # Default shell and programs
  programs = {
    zsh.enable = true;
  };

  # Set hostname in the host configuration
}
