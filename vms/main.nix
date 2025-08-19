{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  # Common configuration for all VMs
  commonConfig = {
    # Basic system configuration
    system.stateVersion = "23.11";

    # Common network settings for VMs
    networking.useDHCP = lib.mkDefault true;

    # Shared directories
    microvm.shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/store";
        tag = "ro-store";
        proto = "virtiofs";
      }
    ];
  };
in {
  # Dedicated system user/group for VM storage management
  users.groups.vmm = {};
  users.users.vmm = {
    isSystemUser = true;
    group = "vmm";
    home = "/home/microvms";
    createHome = true;
  };
  # Enable microvm support on the host
  microvm.host.enable = true;
  # Autostart MicroVMs on boot
  microvm.autostart = ["matrix" "element" "foundry"];

  # Configure microvm storage and network interfaces
  microvm.vms = {
    # Matrix Synapse server VM
    matrix = {
      config = lib.recursiveUpdate commonConfig {
        imports = [./matrix/default.nix];
        networking.hostName = "matrix";
        microvm = {
          # Mount host secret directory into the VM for registration_shared_secret
          shares =
            (commonConfig.microvm.shares or [])
            ++ [
              {
                source = "/home/microvms/matrix";
                mountPoint = "/run/host-secrets/matrix";
                tag = "host-secrets-matrix";
                proto = "virtiofs";
              }
            ];
          interfaces = [
            {
              type = "tap";
              id = "vm-matrix";
              mac = "02:00:00:00:00:01";
            }
          ];
          vcpu = 2;
          mem = 3072;
          volumes = [
            {
              image = "/home/microvms/matrix/rootfs.img";
              mountPoint = "/";
              size = 8192;
            }
            {
              image = "/home/microvms/matrix/postgresql-data.img";
              mountPoint = "/var/lib/postgresql";
              size = 4096;
            }
            {
              image = "/home/microvms/matrix/matrix-synapse-data.img";
              mountPoint = "/var/lib/matrix-synapse";
              size = 4096;
            }
          ];
        };
      };
    };

    # Element Web VM
    element = {
      config = lib.recursiveUpdate commonConfig {
        imports = [./element/default.nix];
        networking.hostName = "element";
        microvm = {
          interfaces = [
            {
              type = "tap";
              id = "vm-element";
              mac = "02:00:00:00:00:02";
            }
          ];
          vcpu = 2;
          mem = 3072;
          volumes = [
            {
              image = "/home/microvms/element/rootfs.img";
              mountPoint = "/";
              size = 4096;
            }
          ];
        };
      };
    };

    # Foundry VTT VM
    foundry = {
      config = lib.recursiveUpdate commonConfig {
        imports = [inputs.foundry.nixosModules.foundryvtt ./foundry/default.nix];
        networking.hostName = "foundry";
        microvm = {
          interfaces = [
            {
              type = "tap";
              id = "vm-foundry";
              mac = "02:00:00:00:00:03";
            }
          ];
          vcpu = 2;
          mem = 3072;
          volumes = [
            {
              image = "/home/microvms/foundry/rootfs.img";
              mountPoint = "/";
              size = 4096;
            }
            {
              image = "/home/microvms/foundry/data.img";
              mountPoint = "/var/lib/foundryvtt";
              size = 4096;
            }
          ];
        };
        # Provide Foundry package from flake input
        services.foundryvtt.package = inputs.foundry.packages.${pkgs.system}.foundryvtt_13;
      };
    };
  };

  # Create a bridge for the microvms
  systemd.network.netdevs."10-microvm".netdevConfig = {
    Kind = "bridge";
    Name = "microvm";
  };
  # Configure the bridge and enable DHCP
  systemd.network.networks."10-microvm" = {
    matchConfig.Name = "microvm";
    networkConfig = {
      DHCPServer = true;
      IPv6SendRA = true;
    };
    addresses = [
      {
        addressConfig.Address = "10.0.0.1/24";
      }
      {
        addressConfig.Address = "fd12:3456:789a::1/64";
      }
    ];
    ipv6Prefixes = [
      {
        ipv6PrefixConfig.Prefix = "fd12:3456:789a::/64";
      }
    ];
  };

  # Attach the vm tap interfaces to the bridge
  systemd.network.networks."11-microvm" = {
    matchConfig.Name = "vm-*";
    networkConfig.Bridge = "microvm";
  };
  /*
  # Enable IP forwarding on the host
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  */
  # Ensure necessary kernel modules are available
  boot.kernelModules = [
    "kvm-intel"
    "kvm-amd"
    "vhost_net"
    "vhost_vsock"
  ];

  # Create microvm storage directories
  systemd.tmpfiles.rules = [
    "d /home/microvms 0750 vmm vmm -"
    "d /home/microvms/matrix 0750 vmm vmm -"
    "d /home/microvms/element 0750 vmm vmm -"
    "d /home/microvms/foundry 0750 vmm vmm -"
    # Directory to host rendered VM secrets like Synapse registration include
  ];

  # Traefik + routes for VMs
  imports = [
    ./vm-hardening.nix # Add VM security hardening
    ./traefik.nix
    ./ddns.nix
    ./acme.nix
    ./matrix/matrix-route.nix
    ./element/element-route.nix
    ./foundry/foundry-route.nix
  ];

  # Render a plain file on the host (not a symlink) from the sops secret,
  # so the VM can include it via the mounted directory.
  systemd.services.vm-matrix-render-registration = {
    description = "Render Synapse registration_shared_secret for Matrix VM";
    wantedBy = ["multi-user.target"];
    after = ["sops-nix.service"];
    wants = ["sops-nix.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "render-matrix-registration";
        text = ''
          set -euo pipefail
          mkdir -p /home/microvms/matrix
          secret_file='${config.sops.secrets.reg_token.path}'
          if [ ! -r "$secret_file" ]; then
            echo "reg_token secret not available at $secret_file" >&2
            exit 1
          fi
          echo "file at " "$secret_file"
          secret=$(tr -d '\n' < "$secret_file")
          umask 022
          printf "registration_shared_secret: %s\n" "$secret" > /home/microvms/matrix/registration.yaml
          printf "%s\n" "$secret" > /home/microvms/matrix/registration
          chmod 0444 /home/microvms/matrix/registration.yaml
        '';
      });
    };
  };

  # Ensure the microvm for Matrix starts after the registration file is rendered
  systemd.services."microvm@matrix".after = ["vm-matrix-render-registration.service"];
}
