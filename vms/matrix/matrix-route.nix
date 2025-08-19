{
  config,
  pkgs,
  lib,
  ...
}: let
  matrixConfig = {
    http = {
      routers = {
        # HTTPS: Registration endpoints (external)
        matrix-register-external-https = {
          rule = "Host(`matrix.holymike.com`) && (Path(`/_matrix/client/v3/register`) || Path(`/_matrix/client/r0/register`))";
          service = "matrix-service";
          entryPoints = ["websecure"];
          middlewares = ["matrix-headers"];
          tls = {};
          priority = 350;
        };

        # HTTP: redirect registration to HTTPS
        matrix-register-external-http-redirect = {
          rule = "Host(`matrix.holymike.com`) && (Path(`/_matrix/client/v3/register`) || Path(`/_matrix/client/r0/register`))";
          service = "noop@internal";
          entryPoints = ["web"];
          middlewares = ["redirect-https@file"];
          priority = 340;
        };

        # HTTPS: All Matrix traffic on dedicated host
        matrix-external-https = {
          rule = "Host(`matrix.holymike.com`)";
          service = "matrix-service";
          entryPoints = ["websecure"];
          middlewares = ["matrix-headers"];
          tls = {};
          priority = 200;
        };

        # HTTP: redirect all host traffic to HTTPS
        matrix-external-http-redirect = {
          rule = "Host(`matrix.holymike.com`)";
          service = "noop@internal";
          entryPoints = ["web"];
          middlewares = ["redirect-https@file"];
          priority = 190;
        };

        # (Well-known routes moved to separate file; client only retained)
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
              X-Forwarded-Proto = "https";
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

        # (No local-only routes needed; using global redirect middleware from main config)
      };
    };
  };
in {
  # Create dynamic configuration file for Matrix routing
  environment.etc."traefik/dynamic/matrix.yml".text = lib.generators.toYAML {} matrixConfig;

  # Create well-known config (public over HTTPS)
  environment.etc."traefik/dynamic/matrix-wellknown.yml".text = lib.generators.toYAML {} {
    http = {
      routers = {
        wellknown-client-https = {
          rule = "Path(`/.well-known/matrix/client`)";
          service = "wellknown-client-service";
          entryPoints = ["websecure"];
          tls = {};
        };
        # HTTP redirectors
        wellknown-client-http-redirect = {
          rule = "Path(`/.well-known/matrix/client`)";
          service = "noop@internal";
          entryPoints = ["web"];
          middlewares = ["redirect-https@file"];
        };
      };
      services = {
        wellknown-client-service = {
          loadBalancer = {
            servers = [
              {url = "http://10.0.0.10:8081";}
            ];
          };
        };
      };
    };
  };
}
