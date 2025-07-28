{
  config,
  lib,
  pkgs,
  microvm,
  ...
}: {
  # Import the microvm.nix module from the microvm-nix flake
  imports = [
    microvm.nixosModules.microvm
  ];

  # Common MicroVM configuration options
  config = {
    # Enable microvm support
    microvm = {
      # Default hypervisor
      hypervisor = lib.mkDefault "qemu";

      # Default kernel package
      kernel = lib.mkDefault {
        package = pkgs.linuxPackages_latest.kernel;
      };

      # Default memory allocation
      mem = lib.mkDefault 512;

      # Default CPU count
      vcpu = lib.mkDefault 1;

      # Enable guest agent for better integration
      qemu.guestAgent.enable = lib.mkDefault true;

      # Default network configuration
      interfaces = lib.mkDefault [
        {
          type = "tap";
          id = "vm-tap0";
          mac = "02:00:00:00:00:00";
        }
      ];

      # Default shares for Nix store
      shares = lib.mkDefault [
        {
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
          tag = "ro-store";
          proto = "virtiofs";
          socket = "store.sock";
        }
      ];

      # Enable writableStoreOverlay for package management
      writableStoreOverlay = lib.mkDefault "/nix/.rw-store";
    };

    # Ensure necessary kernel modules are available
    boot.kernelModules = [
      "kvm-intel"
      "kvm-amd"
      "vhost_net"
      "vhost_vsock"
    ];

    # Enable virtualization support
    virtualisation = {
      libvirtd.enable = lib.mkDefault false; # Don't conflict with microvm
    };

    # Networking support for microvms
    networking = {
      nat = {
        enable = lib.mkDefault true;
        internalInterfaces = ["virbr+"];
      };
    };
  };
}
