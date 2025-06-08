{
  config,
  pkgs,
  lib,
  ...
}: {
  # Docker configuration
  virtualisation.docker = {
    enable = true;

    # Store Docker data in a custom location
    daemon.settings = {
      data-root = "/home/dockerFolder/";
    };

    # Enable Docker Compose
    enableNvidia = false; # Set to true for NVIDIA GPU support

    # Auto-prune Docker resources
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = ["--all"];
    };
  };

  # Make sure the docker group exists
  users.groups.docker = {};

  # Add docker-compose
  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker # TUI for Docker
  ];

  # Add docker users to docker group
  users.users = lib.mkIf config.virtualisation.docker.enable {
    willow = {
      extraGroups = ["docker"];
    };
  };

  # Ensure Docker data directory exists
  system.activationScripts.dockerFolder = ''
    mkdir -p /home/dockerFolder
    chown -R dockerFolder:dockerAccess /home/dockerFolder
  '';

  # Open ports for Docker
  networking.firewall = {
    trustedInterfaces = ["docker0"];
    allowedTCPPorts = [2375 2376]; # Docker daemon ports
  };
}
