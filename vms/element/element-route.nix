{
  config,
  pkgs,
  lib,
  ...
}: let
  elementConfig = {
    http = {
      routers = {
        element-external-https = {
          rule = "Host(`chat.holymike.com`)";
          service = "element-service";
          entryPoints = ["websecure"];
          middlewares = ["element-headers"];
          tls = {};
          priority = 100;
        };
        element-external-http-redirect = {
          rule = "Host(`chat.holymike.com`)";
          service = "noop@internal";
          entryPoints = ["web"];
          middlewares = ["redirect-https@file"];
          priority = 90;
        };
      };

      services = {
        element-service = {
          loadBalancer = {
            servers = [
              { url = "http://10.0.0.11:8082"; }
            ];
            healthCheck = {
              path = "/index.html";
              interval = "30s";
              timeout = "5s";
            };
          };
        };
      };

      middlewares = {
        # Security headers local to this file
        element-headers = {
          headers = {
            customResponseHeaders = {
              X-Frame-Options = "DENY";
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
  environment.etc."traefik/dynamic/element.yml".text = lib.generators.toYAML {} elementConfig;
}
