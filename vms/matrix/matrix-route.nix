{
  config,
  pkgs,
  lib,
  ...
}: let
  matrixConfig = {
    http = {
      routers = {
        # HTTPS: Guarded registration endpoints (external): require BasicAuth
        matrix-register-external-https = {
          rule = "Host(`matrix.holymike.com`) && (Path(`/_matrix/client/v3/register`) || Path(`/_matrix/client/r0/register`))";
          service = "matrix-service";
          entryPoints = ["websecure"];
          middlewares = ["matrix-headers" "matrix-register-basicauth"];
          tls = { certResolver = "letsencrypt_dns"; };
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

        # Guarded registration (local path access), still LAN-gated
        matrix-register-local = {
          rule = "Path(`/_matrix/client/v3/register`) || Path(`/_matrix/client/r0/register`)";
          service = "matrix-service";
          entryPoints = ["web"];
          middlewares = ["matrix-headers" "matrix-register-basicauth" "allow-lan"];
          priority = 300;
        };
        # HTTPS: External Matrix on apex domain
        matrix-external-https = {
          rule = "Host(`matrix.holymike.com`) && PathPrefix(`/_matrix`)";
          service = "matrix-service";
          entryPoints = ["websecure"];
          middlewares = ["matrix-headers"];
          tls = { certResolver = "letsencrypt_dns"; };
          priority = 200;
        };

        # HTTP: redirect to HTTPS for Matrix paths
        matrix-external-http-redirect = {
          rule = "Host(`matrix.holymike.com`) && PathPrefix(`/_matrix`)";
          service = "noop@internal";
          entryPoints = ["web"];
          middlewares = ["redirect-https@file"];
          priority = 190;
        };

        # HTTPS: Public well-known endpoints
        matrix-wellknown-https = {
          rule = "PathPrefix(`/.well-known/matrix`)";
          service = "matrix-wellknown-service";
          entryPoints = ["websecure"];
          tls = { certResolver = "letsencrypt_dns"; };
          priority = 150;
        };

        # HTTP: redirect well-known to HTTPS
        matrix-wellknown-http-redirect = {
          rule = "PathPrefix(`/.well-known/matrix`)";
          service = "noop@internal";
          entryPoints = ["web"];
          middlewares = ["redirect-https"];
          priority = 140;
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
              {url = "http://10.0.0.10:8081";}
            ];
          };
        };
      };

      middlewares = {
        # BasicAuth for registration endpoints, reads htpasswd file managed via sops
        matrix-register-basicauth = {
          basicAuth = {
            usersFile = "/etc/traefik/basicauth/matrix.htpasswd";
            removeHeader = true;
            headerField = "X-Forwarded-User";
          };
        };
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

        # Redirect HTTP -> HTTPS
        redirect-https = {
          redirectScheme = {
            scheme = "https";
            permanent = true;
          };
        };

        # Allow LAN-only access by IP range (used by matrix-register-local)
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

  # Create well-known config (public over HTTPS)
  environment.etc."traefik/dynamic/matrix-wellknown.yml".text = lib.generators.toYAML {} {
    http = {
      routers = {
        wellknown-server-https = {
          rule = "Path(`/.well-known/matrix/server`)";
          service = "wellknown-server-service";
          entryPoints = ["websecure"];
          tls = { certResolver = "letsencrypt_dns"; };
        };
        wellknown-client-https = {
          rule = "Path(`/.well-known/matrix/client`)";
          service = "wellknown-client-service";
          entryPoints = ["websecure"];
          tls = { certResolver = "letsencrypt_tls"; };
        };
        # HTTP redirectors
        wellknown-server-http-redirect = {
          rule = "Path(`/.well-known/matrix/server`)";
          service = "noop@internal";
          entryPoints = ["web"];
          middlewares = ["redirect-https@file"];
        };
        wellknown-client-http-redirect = {
          rule = "Path(`/.well-known/matrix/client`)";
          service = "noop@internal";
          entryPoints = ["web"];
          middlewares = ["redirect-https@file"];
        };
      };
      services = {
        wellknown-server-service = {
          loadBalancer = {
            servers = [
              {url = "http://10.0.0.10:8081";}
            ];
          };
        };
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
