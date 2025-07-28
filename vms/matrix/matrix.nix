{
  config,
  pkgs,
  ...
}: {
  # Matrix Synapse homeserver configuration for microvm
  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = "ivy.local";
      public_baseurl = "https://matrix.ivy.local";

      listeners = [
        {
          port = 8008;
          bind_addresses = ["0.0.0.0"]; # Bind to all interfaces for microvm
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = ["client" "federation"];
              compress = false;
            }
          ];
        }
      ];

      database = {
        name = "psycopg2";
        args = {
          host = "localhost";
          port = 5432;
          database = "synapse";
          user = "synapse";
          # Use trust authentication for simplicity in microvm
          password = "";
          cp_min = 5;
          cp_max = 10;
        };
      };

      media_store_path = "/var/lib/matrix-synapse/media";
      uploads_path = "/var/lib/matrix-synapse/uploads";
      max_upload_size = "100M";
      max_image_pixels = "32M";
      enable_media_repo = true;

      # Registration settings
      registration_enabled = true;
      registration_requires_token = false;
      allow_guest_access = false;
      auto_join_rooms = [];

      # Security settings
      use_presence = true;
      require_auth_for_profile_requests = true;
      limit_profile_requests_to_users_who_share_rooms = true;
      include_profile_data_on_invite = false;
      allow_public_rooms_without_auth = false;
      allow_public_rooms_over_federation = false;
      default_room_version = "10";

      # Performance settings for microvm
      event_cache_size = "5K";
      caches = {
        global_factor = 0.3; # Reduced for microvm memory constraints
      };

      # Logging configuration
      log_config = pkgs.writeText "matrix-log-config.yaml" ''
        version: 1
        formatters:
          precise:
            format: '%(asctime)s - %(name)s - %(lineno)d - %(levelname)s - %(request)s - %(message)s'
        handlers:
          console:
            class: logging.StreamHandler
            formatter: precise
        loggers:
          synapse.storage.SQL:
            level: INFO
        root:
          level: INFO
          handlers: [console]
        disable_existing_loggers: false
      '';
    };

    # Database configuration
    dataDir = "/var/lib/matrix-synapse";
  };

  # Create necessary directories
  systemd.tmpfiles.rules = [
    "d /var/lib/matrix-synapse 0750 matrix-synapse matrix-synapse -"
    "d /var/lib/matrix-synapse/media 0750 matrix-synapse matrix-synapse -"
    "d /var/lib/matrix-synapse/uploads 0750 matrix-synapse matrix-synapse -"
  ];

  # Health check service
  systemd.services.matrix-health-check = {
    description = "Matrix Synapse Health Check";
    after = ["matrix-synapse.service"];
    wants = ["matrix-synapse.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "matrix-health-check" ''
        sleep 10
        echo "=== Matrix Synapse Health Check ==="
        echo "Checking if Matrix is listening on port 8008:"
        ${pkgs.nettools}/bin/netstat -tlnp | grep :8008 || echo "Port 8008 not listening"

        echo "Testing Matrix health endpoint:"
        ${pkgs.curl}/bin/curl -s http://localhost:8008/_matrix/client/versions 2>&1 || echo "Health check failed"

        echo "Matrix service status:"
        systemctl is-active matrix-synapse || echo "Matrix service not active"
      '';
    };
  };
}
