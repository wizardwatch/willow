{
  config,
  lib,
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
  # Enable microvm support on the host
  microvm.host.enable = true;
  # Autostart MicroVMs on boot
  microvm.autostart = ["matrix" "element"];

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
                source = "/var/lib/vms/matrix";
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
              image = "/var/lib/microvms/matrix/rootfs.img";
              mountPoint = "/";
              size = 8192;
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
              image = "/var/lib/microvms/element/rootfs.img";
              mountPoint = "/";
              size = 4096;
            }
          ];
        };
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

  # Enable IP forwarding on the host
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Provide Internet Access with NAT
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "wlo1";
    internalInterfaces = ["microvm"];
  };

  # Firewall configuration for NAT on the host
  networking.firewall = {
    enable = true;
    trustedInterfaces = ["microvm"]; # Trust the internal bridge
  };

  # Ensure necessary kernel modules are available
  boot.kernelModules = [
    "kvm-intel"
    "kvm-amd"
    "vhost_net"
    "vhost_vsock"
  ];

  # Create microvm storage directories
  systemd.tmpfiles.rules = [
    "d /var/lib/microvms 0755 root root -"
    "d /var/lib/microvms/matrix 0755 root root -"
    "d /var/lib/microvms/element 0755 root root -"
    # Directory to host rendered VM secrets like Synapse registration include
    "d /var/lib/matrix 0755 root root -"
  ];

  # Traefik + routes for VMs
  imports = [
    ./traefik.nix
    ./matrix/matrix-route.nix
    ./element/element-route.nix
  ];

  # Render Synapse registration_shared_secret include from sops secret on the host.
  # Expects sops.secrets.reg_token to be declared in modules/services/secrets.nix.
}
