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
      # API and dashboard configuration
      api = {
        dashboard = true;
        insecure = true; # Allow dashboard without HTTPS for internal use
      };

      # Entry points
      entryPoints = {
        web = {
          address = ":80";
          http = {
            redirections = {
              entryPoint = {
                to = "websecure";
                scheme = "https";
              };
            };
          };
        };
        websecure = {
          address = ":443";
        };
        traefik = {
          address = ":8080"; # Dashboard port
        };
      };

      # (TLS certificates configured via file provider common.yml)

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

  # Common dynamic config shared by file provider configs
  environment.etc."traefik/dynamic/common.yml".text = lib.generators.toYAML {} {
    http = {
      middlewares = {
        redirect-https = {
          redirectScheme = {
            scheme = "https";
            permanent = true;
          };
        };
      };
    };
    # Load ACME certificates via dynamic provider (ensures visibility without static TLS)
    tls = {
      certificates = [
        {
          certFile = "/var/lib/acme/holymike_apex/fullchain.pem";
          keyFile = "/var/lib/acme/holymike_apex/key.pem";
        }
        {
          certFile = "/var/lib/acme/holymike_real/fullchain.pem";
          keyFile = "/var/lib/acme/holymike_real/key.pem";
        }
      ];
      stores = {
        default = {
          defaultCertificate = {
            certFile = "/var/lib/acme/holymike_apex/fullchain.pem";
            keyFile = "/var/lib/acme/holymike_apex/key.pem";
          };
        };
      };
    };
  };
  # Ensure traefik user can access log directory and exists
  users.users.traefik = {
    isSystemUser = true;
    group = "traefik";
    home = "/var/lib/traefik";
    createHome = true;
    extraGroups = [ "acme" ];
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
    after = [ "systemd-tmpfiles-setup.service" "acme-holymike_real.service" "acme-holymike_apex.service" ];
    wants = [ "acme-holymike_real.service" "acme-holymike_apex.service" ];
    requires = [ "systemd-tmpfiles-setup.service" ];
    restartTriggers = [
      "/etc/traefik/dynamic" # dynamic config
      "/var/lib/acme/holymike_real/fullchain.pem"
      "/var/lib/acme/holymike_real/key.pem"
      "/var/lib/acme/holymike_apex/fullchain.pem"
      "/var/lib/acme/holymike_apex/key.pem"
    ];
    serviceConfig = {
      User = "traefik";
      Group = "traefik";
      # Ensure /var/log/traefik exists before start
      LogsDirectory = "traefik";
      LogsDirectoryMode = "0755";
    };
  };

  sops.templates."traefik/dns.env" = {
    content = ''
      # Tokens for lego Cloudflare provider (Traefik ACME)
      CLOUDFLARE_API_TOKEN=${config.sops.placeholder.ddns-pass}
      CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder.ddns-pass}
      CF_DNS_API_TOKEN=${config.sops.placeholder.ddns-pass}
    '';
    mode = "0640";
    group = "traefik";
  };
}
