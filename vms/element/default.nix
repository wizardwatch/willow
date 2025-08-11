{
  config,
  lib,
  pkgs,
  ...
}: {
  # Override element-web package inside this VM to embed config.json
  nixpkgs.overlays = [
    (final: prev: {
      element-web = prev.element-web.override {
        conf = {
          default_server_config = {
            "m.homeserver" = {
              base_url = "http://10.0.0.10:8008";
            };
            "m.identity_server" = {
              base_url = "https://vector.im";
            };
          };
          default_server_name = "matrix.holymike.com";
          disable_custom_urls = true;
          brand = "Element";
        };
      };
    })
  ];
  imports = [
    ./element-web.nix
  ];

  # Static addressing on the microvm network
  networking.useDHCP = false;
  systemd.network.enable = true;
  systemd.network.networks."10-microvm-eth" = {
    matchConfig = {
      # Match the MicroVM NIC by MAC set in vms/main.nix
      MACAddress = "02:00:00:00:00:02";
    };
    networkConfig = {
      DHCP = "no";
      Address = ["10.0.0.11/24"];
      Gateway = "10.0.0.1";
      DNS = ["1.1.1.1" "9.9.9.9"];
    };
  };

  # SSH for management (same policy as Matrix VM)
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # Admin user
  users.users.willow = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    initialPassword = "gex";
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../../users/willow/keys/willow_ssh.pub)
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  # Firewall
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [22 8082];
  };

  environment.systemPackages = with pkgs; [ vim curl htop element-web ];

  system.stateVersion = "23.11";
}
