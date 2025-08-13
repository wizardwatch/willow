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
          rule = "Host(`chat.onepagerpolitics.com`)";
          service = "element-service";
          entryPoints = ["websecure"];
          middlewares = ["element-headers"];
          tls = { certResolver = "letsencrypt"; };
          priority = 100;
        };
        element-external-http-redirect = {
          rule = "Host(`chat.onepagerpolitics.com`)";
          service = "noop@internal";
          entryPoints = ["web"];
          middlewares = ["redirect-https@file"];
          priority = 90;
        };
        # Optional local path-based access for LAN without DNS
        element-local = {
          rule = "PathPrefix(`/element`)";
          service = "element-service";
          entryPoints = ["web" "websecure"];
          middlewares = ["strip-element-prefix" "allow-lan" "element-headers"];
          tls = {};
          priority = 50;
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
        # Allow LAN-only path access
        allow-lan = {
          ipWhiteList = {
            sourceRange = ["192.168.0.0/24" "127.0.0.1/32"];
          };
        };
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
        # Strip /element prefix for path-based access
        strip-element-prefix = {
          stripPrefix = {
            prefixes = ["/element"];
          };
        };
      };
    };
  };
in {
  environment.etc."traefik/dynamic/element.yml".text = lib.generators.toYAML {} elementConfig;
}
