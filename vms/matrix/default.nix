{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./matrix.nix
  ];

  # Basic system configuration
  boot.kernelParams = ["console=ttyS0"];

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
      Address = [ "10.0.0.10/24" ];
      Gateway = "10.0.0.1";
      DNS = [ "1.1.1.1" "9.9.9.9" ];
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

  # Create matrix-synapse user if not already created
  users.users.matrix-synapse = {
    isSystemUser = true;
    group = "matrix-synapse";
    home = "/var/lib/matrix-synapse";
    createHome = true;
  };
  users.groups.matrix-synapse = {};

  # Create admin user for VM management
  users.users.admin = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      # Add your SSH key here
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
    '';

    settings = {
      port = 5432;
    };
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
  ];

  # Ensure PostgreSQL starts before Matrix
  systemd.services.matrix-synapse.after = ["postgresql.service"];
  systemd.services.matrix-synapse.requires = ["postgresql.service"];

  system.stateVersion = "23.11";
}
