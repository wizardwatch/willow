{
  config,
  lib,
  pkgs,
  microvm,
  ...
}: let
  # Common configuration for all VMs
  commonConfig = {
    # Basic system configuration
    system.stateVersion = "23.11";

    # Common network settings for VMs
    networking = {
      useDHCP = false; # VMs will have static IPs
      defaultGateway = {
        address = "10.0.0.1"; # Host's bridge IP
        interface = "eth0";
      };
      nameservers = ["10.0.0.1"]; # Use the host as DNS forwarder
      firewall.enable = false; # VMs don't need their own firewall if host handles NAT
    };

    # Shared directories
    microvm.shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "ro-store";
        proto = "virtiofs";
      }
    ];
  };
in {
  # Enable microvm support on the host
  microvm.host.enable = true;

  # Make the host use the local DNS server
  networking.nameservers = ["127.0.0.1"];

  # Configure microvm storage and network interfaces
  microvm.vms = {
    # Matrix Synapse server VM
    matrix = {
      config = lib.recursiveUpdate commonConfig {
        imports = [./matrix/default.nix];
        networking = {
          hostName = "matrix";
          interfaces.eth0.ipv4.addresses = [
            {
              address = "10.0.0.10";
              prefixLength = 24;
            }
          ];
        };
        microvm = {
          interfaces = [
            {
              type = "bridge";
              bridge = "microvm";
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

    # Traefik reverse proxy VM
    traefik = {
      config = lib.recursiveUpdate commonConfig {
        imports = [./traefik/default.nix];
        networking = {
          hostName = "traefik";
          interfaces.eth0.ipv4.addresses = [
            {
              address = "10.0.0.20";
              prefixLength = 24;
            }
          ];
        };
        microvm = {
          interfaces = [
            {
              type = "bridge";
              bridge = "microvm";
              id = "vm-traefik";
              mac = "02:00:00:00:00:02";
            }
          ];
          vcpu = 1;
          mem = 1024;
          volumes = [
            {
              image = "/var/lib/microvms/traefik/rootfs.img";
              mountPoint = "/";
              size = 4096;
            }
          ];
        };
      };
    };
  };

  systemd.network.netdevs."10-microvm".netdevConfig = {
    Kind = "bridge";
    Name = "microvm";
  };
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

  # Allow inbound traffic for the DHCP server
  networking.firewall.allowedUDPPorts = [67];

  # Add systemd dependency to ensure br0 exists before VMs start
  systemd.services."microvm@traefik".unitConfig.BindsTo = ["sys-subsystem-net-devices-microvm.device"];
  systemd.services."microvm@traefik".unitConfig.After = ["sys-subsystem-net-devices-microvm.device"];
  systemd.services."microvm@matrix".unitConfig.BindsTo = ["sys-subsystem-net-devices-microvm.device"];
  systemd.services."microvm@matrix".unitConfig.After = ["sys-subsystem-net-devices-microvm.device"];

  # Enable IP forwarding on the host
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Firewall configuration for NAT on the host
  networking.firewall = {
    enable = true;
    trustedInterfaces = ["microvm"]; # Trust the internal bridge
    # Add the NAT rule for the internal network to access external network via wlo1
    extraCommands = ''
      iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o wlo1 -j MASQUERADE
    '';
  };

  # Allow qemu-bridge-helper to use br0 (for non-root QEMU)
  environment.etc."qemu/bridge.conf".text = "allow microvm";

  # Create microvm storage directories
  systemd.tmpfiles.rules = [
    "d /var/lib/microvms 0755 root root -"
    "d /var/lib/microvms/matrix 0755 root root -"
    "d /var/lib/microvms/traefik 0755 root root -"
  ];
}
