{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./matrix.nix
    ./wellknown-caddy.nix
  ];

  # Directly include the host-rendered registration secret YAML from the mounted path
  services.matrix-synapse.settings.include = [
    "/run/host-secrets/matrix/registration.yaml"
  ];

  # Basic system configuration
  #boot.kernelParams = ["console=ttyS0"];

  # Use static addressing on the microvm network
  networking.useDHCP = false;
  systemd.network.enable = true;
  systemd.network.networks."10-microvm-eth" = {
    matchConfig = {
      # Match the MicroVM NIC by MAC set in vms/main.nix
      MACAddress = "02:00:00:00:00:01";
    };
    networkConfig = {
      DHCP = "no";
      Address = ["10.0.0.10/24"];
      Gateway = "10.0.0.1";
      DNS = ["1.1.1.1" "9.9.9.9"];
    };
  };

  # Enable SSH for management
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Allow inbound access to Matrix and SSH
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [22 8008 8081];
  };

  # Create matrix-synapse user if not already created
  users.users.matrix-synapse = {
    isSystemUser = true;
    group = "matrix-synapse";
    home = "/var/lib/matrix-synapse";
    createHome = true;
  };
  users.groups.matrix-synapse = {};

  # Create admin user for VM management
  users.users.willow = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    initialPassword = "gex";
    openssh.authorizedKeys.keys = [
      # Willow's public key
      (builtins.readFile ../../users/willow/keys/willow_ssh.pub)
    ];
  };

  # Enable sudo without password for wheel group
  security.sudo.wheelNeedsPassword = false;

  # PostgreSQL database for Matrix
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;

    ensureDatabases = ["synapse"];
    ensureUsers = [
      {
        name = "synapse";
        ensureDBOwnership = true;
      }
    ];

    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host synapse synapse 127.0.0.1/32 trust
      host synapse synapse ::1/128 trust
    '';
  };

  # Firewall configuration
  /*
    networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 8008]; # SSH and Matrix Synapse
  };
  */

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    curl
    htop
    postgresql
    matrix-synapse
  ];

  # Ensure proper ownership of persistent volumes
  systemd.tmpfiles.rules = [
    "d /var/lib/postgresql 0755 postgres postgres -"
    "d /var/lib/matrix-synapse 0700 matrix-synapse matrix-synapse -"
  ];

  # Ensure PostgreSQL starts before Matrix
  systemd.services.matrix-synapse.after = ["postgresql.service"];
  systemd.services.matrix-synapse.requires = ["postgresql.service"];

  system.stateVersion = "23.11";
}
