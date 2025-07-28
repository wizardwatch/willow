{
  config,
  pkgs,
  lib,
  ...
}: let
  matrixConfig = {
    http = {
      routers = {
        # Matrix client API
        matrix-client = {
          rule = "Host(`matrix.ivy.local`)";
          service = "matrix-service";
          entryPoints = ["web"];
          middlewares = ["matrix-headers"];
        };

        # Matrix federation API
        matrix-federation = {
          rule = "Host(`ivy.local`) && PathPrefix(`/_matrix`)";
          service = "matrix-service";
          entryPoints = ["web"];
          middlewares = ["matrix-headers"];
        };

        # Matrix well-known endpoints
        matrix-wellknown = {
          rule = "Host(`ivy.local`) && PathPrefix(`/.well-known/matrix`)";
          service = "matrix-service";
          entryPoints = ["web"];
          middlewares = ["matrix-headers"];
        };
      };

      services = {
        matrix-service = {
          loadBalancer = {
            servers = [
              {url = "http://10.0.0.10:8008";}
            ];
            healthCheck = {
              path = "/_matrix/client/versions";
              interval = "30s";
              timeout = "5s";
            };
          };
        };
      };

      middlewares = {
        matrix-headers = {
          headers = {
            customRequestHeaders = {
              X-Forwarded-Proto = "http";
              X-Forwarded-Host = "matrix.ivy.local";
            };
            customResponseHeaders = {
              X-Matrix-Server = "ivy.local";
              Access-Control-Allow-Origin = "*";
              Access-Control-Allow-Methods = "GET, POST, PUT, DELETE, OPTIONS";
              Access-Control-Allow-Headers = "Origin, X-Requested-With, Content-Type, Accept, Authorization";
            };
          };
        };
      };
    };
  };
in {
  # Create dynamic configuration file for Matrix routing
  environment.etc."traefik/dynamic/matrix.yml".text = lib.generators.toYAML {} matrixConfig;

  # Create well-known matrix configuration for server discovery
  environment.etc."traefik/dynamic/matrix-wellknown.yml".text = lib.generators.toYAML {} {
    http = {
      routers = {
        wellknown-server = {
          rule = "Host(`ivy.local`) && Path(`/.well-known/matrix/server`)";
          service = "wellknown-server-service";
          entryPoints = ["web"];
        };
        wellknown-client = {
          rule = "Host(`ivy.local`) && Path(`/.well-known/matrix/client`)";
          service = "wellknown-client-service";
          entryPoints = ["web"];
        };
      };

      services = {
        wellknown-server-service = {
          loadBalancer = {
            servers = [
              {url = "http://127.0.0.1:8081";}
            ];
          };
        };
        wellknown-client-service = {
          loadBalancer = {
            servers = [
              {url = "http://127.0.0.1:8081";}
            ];
          };
        };
      };
    };
  };

  # Simple HTTP server for well-known endpoints
  systemd.services.matrix-wellknown = {
    description = "Matrix Well-Known Server";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "5";
      ExecStart = "${pkgs.python3}/bin/python3 -m http.server 8081 --directory /var/lib/matrix-wellknown";
      WorkingDirectory = "/var/lib/matrix-wellknown";
      User = "matrix-wellknown";
      Group = "matrix-wellknown";
    };
  };

  # Create well-known user
  users.users.matrix-wellknown = {
    isSystemUser = true;
    group = "matrix-wellknown";
    home = "/var/lib/matrix-wellknown";
    createHome = true;
  };
  users.groups.matrix-wellknown = {};

  # Create well-known files
  systemd.tmpfiles.rules = [
    "d /var/lib/matrix-wellknown 0755 matrix-wellknown matrix-wellknown -"
    "d /var/lib/matrix-wellknown/.well-known 0755 matrix-wellknown matrix-wellknown -"
    "d /var/lib/matrix-wellknown/.well-known/matrix 0755 matrix-wellknown matrix-wellknown -"
  ];

  # Create well-known server file
  environment.etc."matrix-wellknown/server.json" = {
    target = "/var/lib/matrix-wellknown/.well-known/matrix/server";
    text = builtins.toJSON {
      "m.server" = "ivy.local:443";
    };
    mode = "0644";
    user = "matrix-wellknown";
    group = "matrix-wellknown";
  };

  # Create well-known client file
  environment.etc."matrix-wellknown/client.json" = {
    target = "/var/lib/matrix-wellknown/.well-known/matrix/client";
    text = builtins.toJSON {
      "m.homeserver" = {
        "base_url" = "https://matrix.ivy.local";
      };
      "m.identity_server" = {
        "base_url" = "https://vector.im";
      };
    };
    mode = "0644";
    user = "matrix-wellknown";
    group = "matrix-wellknown";
  };
}
