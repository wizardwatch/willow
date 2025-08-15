{
  config,
  pkgs,
  lib,
  ...
}: let
  foundryConfig = {
    http = {
      routers = {
        foundry-external-https = {
          rule = "Host(`dnd.holymike.com`)";
          service = "foundry-service";
          entryPoints = ["websecure"];
          middlewares = ["foundry-headers" "foundry-basicauth"];
          tls = {};
          priority = 120;
        };
        foundry-external-http-redirect = {
          rule = "Host(`dnd.holymike.com`)";
          service = "noop@internal";
          entryPoints = ["web"];
          middlewares = ["redirect-https@file"];
          priority = 110;
        };
      };

      services = {
        foundry-service = {
          loadBalancer = {
            servers = [
              { url = "http://10.0.0.12:30000"; }
            ];
            healthCheck = {
              path = "/";
              interval = "30s";
              timeout = "5s";
            };
          };
        };
      };

      middlewares = {
        # BasicAuth for Foundry; use htpasswd-formatted file at /var/lib/vms/pass
        foundry-basicauth = {
          basicAuth = {
            usersFile = "/var/lib/vms/pass";
            removeHeader = true;
            headerField = "X-Forwarded-User";
          };
        };
        # Security headers
        foundry-headers = {
          headers = {
            customRequestHeaders = {
              X-Forwarded-Proto = "https";
              X-Forwarded-Host = "dnd.holymike.com";
            };
            customResponseHeaders = {
              X-Frame-Options = "SAMEORIGIN";
              X-Content-Type-Options = "nosniff";
              X-XSS-Protection = "1; mode=block";
              Strict-Transport-Security = "max-age=31536000; includeSubDomains";
            };
          };
        };
      };
    };
  };
in {
  environment.etc."traefik/dynamic/foundry.yml".text = lib.generators.toYAML {} foundryConfig;
}
