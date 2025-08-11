{
  config,
  pkgs,
  lib,
  ...
}: let
  matrixConfig = {
    http = {
      routers = {
        # Local-only Matrix (no Host), allow LAN by IP
        matrix-local = {
          rule = "PathPrefix(`/_matrix`)";
          service = "matrix-service";
          entryPoints = ["web"];
          middlewares = ["matrix-headers" "allow-lan"];
          priority = 200;
        };

        # External Matrix via public subdomain
        matrix-external = {
          rule = "Host(`matrix.holymike.com`) && PathPrefix(`/_matrix`)";
          service = "matrix-service";
          entryPoints = ["web"];
          middlewares = ["matrix-headers"];
          priority = 100;
        };

        # Local-only well-known endpoints (no Host)
        matrix-wellknown-local = {
          rule = "PathPrefix(`/.well-known/matrix`)";
          service = "matrix-wellknown-service";
          entryPoints = ["web"];
          middlewares = ["allow-lan"];
          priority = 200;
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

        matrix-wellknown-service = {
          loadBalancer = {
            servers = [
              {url = "http://127.0.0.1:8081";}
            ];
          };
        };
      };

      middlewares = {
        matrix-headers = {
          headers = {
            customRequestHeaders = {
              X-Forwarded-Proto = "http";
              X-Forwarded-Host = "matrix.holymike.com";
            };
            customResponseHeaders = {
              X-Matrix-Server = "matrix.holymike.com";
              Access-Control-Allow-Origin = "*";
              Access-Control-Allow-Methods = "GET, POST, PUT, DELETE, OPTIONS";
              Access-Control-Allow-Headers = "Origin, X-Requested-With, Content-Type, Accept, Authorization";
            };
          };
        };

        # Redefine allow-lan here so this dynamic file is self-contained
        allow-lan = {
          ipWhiteList = {
            sourceRange = ["192.168.0.0/24" "127.0.0.1/32"];
          };
        };
      };
    };
  };
in {
  # Create dynamic configuration file for Matrix routing
  environment.etc."traefik/dynamic/matrix.yml".text = lib.generators.toYAML {} matrixConfig;

  # Create well-known matrix configuration for server discovery (served by local service above)
  environment.etc."traefik/dynamic/matrix-wellknown.yml".text = lib.generators.toYAML {} {
    http = {
      routers = {
        wellknown-server = {
          rule = "Path(`/.well-known/matrix/server`)";
          service = "wellknown-server-service";
          entryPoints = ["web"];
          middlewares = ["allow-lan"];
        };
        wellknown-client = {
          rule = "Path(`/.well-known/matrix/client`)";
          service = "wellknown-client-service";
          entryPoints = ["web"];
          middlewares = ["allow-lan"];
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
      "m.server" = "matrix.holymike.com:443";
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
        "base_url" = "https://matrix.holymike.com";
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
