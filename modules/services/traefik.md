# Traefik Reverse Proxy Module

This module provides a comprehensive NixOS configuration for Traefik, a modern HTTP reverse proxy and load balancer.

## Features

- **Automatic HTTPS**: Let's Encrypt integration with automatic certificate management
- **Dynamic Configuration**: File-based dynamic configuration with hot reloading
- **API & Dashboard**: Optional web dashboard for monitoring and management
- **Security Hardening**: Systemd security features and proper file permissions
- **Logging**: Access logs and configurable log levels
- **Metrics**: Optional Prometheus metrics endpoint

## Basic Usage

```nix
services.traefik-proxy = {
  enable = true;
  api = {
    enable = true;
    dashboard = true;
  };
  staticConfigOptions = {
    entryPoints = {
      web = {
        address = ":80";
      };
      websecure = {
        address = ":443";
      };
    };
    certificatesResolvers = {
      letsencrypt = {
        acme = {
          email = "admin@example.com";
          storage = "/var/lib/traefik/acme.json";
          httpChallenge = {
            entryPoint = "web";
          };
        };
      };
    };
  };
  dynamicConfigOptions = {
    http = {
      routers = {
        api = {
          rule = "Host(`traefik.example.com`)";
          service = "api@internal";
          tls = {
            certResolver = "letsencrypt";
          };
        };
      };
    };
  };
};
```

## Configuration Options

### Core Options

- `enable`: Enable the Traefik service
- `package`: Traefik package to use (default: `pkgs.traefik`)
- `configFile`: Path to external configuration file (alternative to options-based config)
- `dataDir`: Directory for Traefik data (default: `/var/lib/traefik`)
- `user`/`group`: System user/group for the service
- `logLevel`: Logging level (DEBUG, INFO, WARN, ERROR, FATAL, PANIC)

### Static Configuration

Use `staticConfigOptions` to define:
- Entry points (ports to listen on)
- Certificate resolvers (Let's Encrypt configuration)
- Global settings
- Provider configurations

### Dynamic Configuration

Use `dynamicConfigOptions` to define:
- HTTP/TCP routers
- Services and load balancers
- Middlewares
- TLS configurations

### API & Dashboard

```nix
api = {
  enable = true;          # Enable API
  dashboard = true;       # Enable web dashboard
  debug = false;          # Debug mode
  insecure = false;       # Allow insecure access (not recommended)
};
```

### Access Logging

```nix
accessLog = {
  enable = true;
  filePath = "/var/log/traefik/access.log";
  format = "json";        # "json" or "common"
};
```

### Metrics

```nix
metrics = {
  prometheus = true;      # Enable Prometheus metrics
};
```

## Security Considerations

1. **Certificate Storage**: ACME certificates are stored in `/var/lib/traefik/acme.json` with restrictive permissions
2. **API Access**: The dashboard should be protected with authentication middleware
3. **File Permissions**: Configuration files are created with appropriate user/group ownership
4. **Systemd Security**: Service runs with NoNewPrivileges, PrivateTmp, and other security features

## Example: Complete Setup with Services

```nix
services.traefik-proxy = {
  enable = true;
  api = {
    enable = true;
    dashboard = true;
  };
  staticConfigOptions = {
    entryPoints = {
      web = {
        address = ":80";
        http.redirections.entrypoint = {
          to = "websecure";
          scheme = "https";
        };
      };
      websecure = {
        address = ":443";
      };
    };
    certificatesResolvers = {
      letsencrypt = {
        acme = {
          email = "admin@example.com";
          storage = "/var/lib/traefik/acme.json";
          httpChallenge.entryPoint = "web";
        };
      };
    };
  };
  dynamicConfigOptions = {
    http = {
      routers = {
        traefik = {
          rule = "Host(`traefik.example.com`)";
          service = "api@internal";
          entryPoints = ["websecure"];
          tls.certResolver = "letsencrypt";
          middlewares = ["auth"];
        };
        app = {
          rule = "Host(`app.example.com`)";
          service = "app";
          entryPoints = ["websecure"];
          tls.certResolver = "letsencrypt";
        };
      };
      services = {
        app = {
          loadBalancer.servers = [
            { url = "http://127.0.0.1:3000"; }
          ];
        };
      };
      middlewares = {
        auth = {
          basicAuth.users = [
            "admin:$2y$10$..." # Generate with htpasswd
          ];
        };
      };
    };
  };
  accessLog = {
    enable = true;
    format = "json";
  };
};
```

## Networking

The module automatically opens firewall ports based on configured entry points. Ensure your DNS points to the server's IP address for the domains you're using.

## Troubleshooting

1. **Check service status**: `systemctl status traefik`
2. **View logs**: `journalctl -u traefik -f`
3. **Access logs**: Check `/var/log/traefik/access.log` if enabled
4. **Certificate issues**: Check `/var/lib/traefik/acme.json` permissions and content
5. **Dashboard access**: Ensure the API is enabled and accessible via configured route

## Integration

This module works well with:
- Docker containers (add Docker provider)
- Kubernetes (add Kubernetes provider)
- File-based services (using dynamic configuration)
- Other NixOS services on the same host