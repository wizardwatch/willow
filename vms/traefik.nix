{
  config,
  pkgs,
  lib,
  ...
}: {
  # Traefik reverse proxy configuration (runs on host)
  networking.firewall.allowedTCPPorts = [80 443];
  services.traefik = {
    enable = true;

    staticConfigOptions = {
      certificatesResolvers = {
        letsencrypt = {
          acme = {
            storage = "/var/lib/traefik/acme.json";
            httpChallenge = {
              entryPoint = "web";
            };
          };
        };
      };
      # API and dashboard configuration
      api = {
        dashboard = true;
        insecure = true; # Allow dashboard without HTTPS for internal use
      };

      # Entry points
      entryPoints = {
        web = {
          address = ":80";
        };
        websecure = {
          address = ":443";
        };
        traefik = {
          address = ":8080"; # Dashboard port
        };
      };

      # Providers configuration
      providers = {
        file = {
          directory = "/etc/traefik/dynamic";
          watch = true;
        };
      };

      # Logging
      log = {
        level = "INFO";
        filePath = "/var/log/traefik/traefik.log";
      };

      accessLog = {
        filePath = "/var/log/traefik/access.log";
      };

      # Metrics (optional)
      metrics = {
        prometheus = {
          addEntryPointsLabels = true;
          addServicesLabels = true;
        };
      };
    };

    # Dynamic configuration
    dynamicConfigOptions = {
      http = {
        # Routers
        routers = {
          # Local-only dashboard via path, gated by LAN IPs
          traefik-dashboard = {
            rule = "PathPrefix(`/dashboard`)";
            service = "api@internal";
            entryPoints = ["web"];
            middlewares = ["dashboard-redirect" "allow-lan" "security-headers"];
            priority = 200;
          };

          # Local-only API access via path
          traefik-api = {
            rule = "PathPrefix(`/api`)";
            service = "api@internal";
            entryPoints = ["web"];
            middlewares = ["allow-lan"];
            priority = 200;
          };
        };

        # Services (matrix service routes added via dynamic files)
        services = {};

        # Middlewares
        middlewares = {
          # Redirect HTTP -> HTTPS (reusable)
          redirect-https = {
            redirectScheme = {
              scheme = "https";
              permanent = true;
            };
          };
          # Add trailing slash for dashboard
          dashboard-redirect = {
            redirectRegex = {
              regex = "^(.*)/dashboard$$";
              replacement = "$${1}/dashboard/";
              permanent = true;
            };
          };

          # Security headers
          security-headers = {
            headers = {
              customRequestHeaders = {
                X-Forwarded-Proto = "https";
              };
              customResponseHeaders = {
                X-Frame-Options = "DENY";
                X-Content-Type-Options = "nosniff";
                X-XSS-Protection = "1; mode=block";
                Strict-Transport-Security = "max-age=31536000; includeSubDomains";
              };
            };
          };

          # Rate limiting
          rate-limit = {
            rateLimit = {
              burst = 100;
              average = 50;
            };
          };

          # Allow LAN-only access by IP range
          allow-lan = {
            ipWhiteList = {
              sourceRange = ["192.168.0.0/24" "127.0.0.1/32"];
            };
          };
        };
      };
    };
  };

  # Health check service for Traefik
  systemd.services.traefik-health-check = {
    description = "Traefik Health Check";
    after = ["traefik.service"];
    wants = ["traefik.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "traefik-health-check" ''
        sleep 5
        echo "=== Traefik Health Check ==="
        echo "Checking if Traefik is listening on port 80:"
        ${pkgs.nettools}/bin/netstat -tlnp | grep :80 || echo "Port 80 not listening"

        echo "Checking if Traefik is listening on port 8080:"
        ${pkgs.nettools}/bin/netstat -tlnp | grep :8080 || echo "Port 8080 not listening"

        echo "Testing Traefik API:"
        ${pkgs.curl}/bin/curl -s http://localhost:8080/api/http/routers 2>&1 | head -5 || echo "Cannot connect to Traefik API"

        echo "Testing dashboard access:"
        ${pkgs.curl}/bin/curl -s -I http://localhost:8080/dashboard/ 2>&1 | head -3 || echo "Dashboard not accessible"

        echo "Traefik service status:"
        systemctl is-active traefik || echo "Traefik service not active"

        echo "Dynamic configuration files:"
        ls -la /etc/traefik/dynamic/ || echo "No dynamic config files found"
      '';
    };
  };

  # Ensure traefik user can access log directory and exists
  users.users.traefik = {
    isSystemUser = true;
    group = "traefik";
    home = "/var/lib/traefik";
    createHome = true;
  };
  users.groups.traefik = {};

  # Create traefik directories
  systemd.tmpfiles.rules = [
    "d /etc/traefik 0755 root root -"
    "d /etc/traefik/dynamic 0755 root root -"
    "d /etc/traefik/basicauth 0750 root traefik -"
    "f /var/lib/traefik/acme.json 0600 traefik traefik -"
    "d /var/log/traefik 0755 traefik traefik -"
  ];

  systemd.services.traefik = {
    serviceConfig = {
      User = "traefik";
      Group = "traefik";
    };
  };

  # Expose an htpasswd file for guarding registration; expects sops.secrets.matrixRegisterHtpasswd
  # to be declared in your secrets module (path content is the htpasswd line).
  environment.etc."traefik/basicauth/matrix.htpasswd".source =
    config.sops.secrets.matrixRegisterHtpasswd.path or "/etc/traefik/basicauth/.missing";
}
