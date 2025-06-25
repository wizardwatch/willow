{pkgs, ...}: {
  # Traefik reverse proxy configuration
  services.traefik = {
    enable = true;

    staticConfigOptions = {
      api = {
        dashboard = true;
        insecure = true;
      };

      entryPoints = {
        web = {
          address = ":80";
          asDefault = true;
        };
      };

      log = {
        level = "DEBUG";
      };

      accessLog = {};
    };

    dynamicConfigOptions = {
      http = {
        routers = {
          # Simple Traefik dashboard on root
          traefik-dashboard = {
            rule = "Host(`ivy.local`)";
            service = "api@internal";
            entryPoints = ["web"];
            priority = 100;
          };
          # Test service route
          test-service = {
            rule = "Host(`ivy.local`) && PathPrefix(`/test`)";
            service = "test";
            entryPoints = ["web"];
            priority = 200;
          };
          # Authentik service
          authentik = {
            rule = "Host(`ivy.local`) && PathPrefix(`/auth`)";
            service = "authentik";
            entryPoints = ["web"];
            middlewares = ["auth-stripprefix"];
          };
          # Matrix service
          matrix = {
            rule = "Host(`ivy.local`) && PathPrefix(`/matrix`)";
            service = "matrix";
            entryPoints = ["web"];
            middlewares = ["matrix-stripprefix"];
          };
          # Matrix federation
          matrix-federation = {
            rule = "Host(`ivy.local`) && PathPrefix(`/_matrix/`)";
            service = "matrix";
            entryPoints = ["web"];
          };
        };

        services = {
          test = {
            loadBalancer = {
              servers = [
                {url = "http://127.0.0.1:8888";}
              ];
            };
          };
          authentik = {
            loadBalancer = {
              servers = [
                {url = "http://127.0.0.1:9000";}
              ];
            };
          };
          matrix = {
            loadBalancer = {
              servers = [
                {url = "http://127.0.0.1:8008";}
              ];
            };
          };
        };

        middlewares = {
          auth-stripprefix = {
            stripPrefix = {
              prefixes = ["/auth"];
            };
          };
          matrix-stripprefix = {
            stripPrefix = {
              prefixes = ["/matrix"];
            };
          };
        };
      };
    };
  };

  # Firewall ports are configured in main configuration.nix
  # Add debugging information to logs
  systemd.services.traefik-debug = {
    description = "Traefik Debug Info";
    after = ["traefik.service"];
    wants = ["traefik.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "traefik-debug" ''
        echo "=== Traefik Debug Info ==="
        echo "Checking if Traefik is listening on port 80:"
        ${pkgs.nettools}/bin/netstat -tlnp | grep :80 || echo "Port 80 not listening"
        echo "Checking if Traefik is listening on port 8080:"
        ${pkgs.nettools}/bin/netstat -tlnp | grep :8080 || echo "Port 8080 not listening"

        echo "Testing local connection to Traefik API:"
        ${pkgs.curl}/bin/curl -s http://localhost:8080/api/http/routers 2>&1 || echo "Cannot connect to Traefik API"

        echo "Testing direct Host header:"
        ${pkgs.curl}/bin/curl -s -H "Host: ivy.local" http://localhost:80 2>&1 | head -10 || echo "Host header test failed"

        echo "Traefik config file contents:"
        cat /etc/traefik/dynamic.yml || echo "Config file not found"

        echo "Current Traefik routers from API:"
        ${pkgs.curl}/bin/curl -s http://localhost:8080/api/http/routers 2>/dev/null || echo "Cannot get router info"

        echo "Testing simple curl to port 80:"
        ${pkgs.curl}/bin/curl -I http://localhost:80 2>&1 | head -5 || echo "Cannot connect to port 80"

        echo "Checking file provider configuration:"
        ls -la /etc/traefik/ || echo "Traefik config directory not found"

        echo "Checking if dynamic config file exists:"
        ls -la /etc/traefik/dynamic.yml || echo "Dynamic config file not found"

        echo "Traefik service logs (last 20 lines):"
        journalctl -u traefik --no-pager -n 20 || echo "Cannot get Traefik logs"
      '';
    };
  };
}
