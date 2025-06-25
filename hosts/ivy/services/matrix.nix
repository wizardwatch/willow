{
  inputs,
  pkgs,
  ...
}: {
  # Matrix Synapse homeserver - static configuration
  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = "ivy.local";
      public_baseurl = "https://matrix.ivy.local";

      listeners = [
        {
          port = 8008;
          bind_addresses = ["127.0.0.1"];
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
          password = "@DB_PASSWORD@";
          cp_min = 5;
          cp_max = 10;
        };
      };

      media_store_path = "/var/lib/matrix-synapse/media";
      uploads_path = "/var/lib/matrix-synapse/uploads";
      max_upload_size = "100M";
      max_image_pixels = "32M";
      enable_media_repo = true;

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
      default_room_version = "9";

      # Performance settings
      event_cache_size = "10K";
      caches = {
        global_factor = 0.5;
      };

      # Logging
      log_config = pkgs.writeText "matrix-log-config.yaml" ''
        version: 1
        formatters:
          precise:
            format: '%(asctime)s - %(name)s - %(lineno)d - %(levelname)s - %(request)s - %(message)s'
        handlers:
          file:
            class: logging.handlers.TimedRotatingFileHandler
            formatter: precise
            filename: /var/lib/matrix-synapse/logs/homeserver.log
            when: midnight
            backupCount: 10
          console:
            class: logging.StreamHandler
            formatter: precise
        loggers:
          synapse.storage.SQL:
            level: INFO
        root:
          level: INFO
          handlers: [file, console]
        disable_existing_loggers: false
      '';
    };
  };

  # Create matrix-synapse directories and secrets
  systemd.tmpfiles.rules = [
    "d /var/lib/matrix-synapse 0750 matrix-synapse matrix-synapse -"
    "d /var/lib/matrix-synapse/media 0750 matrix-synapse matrix-synapse -"
    "d /var/lib/matrix-synapse/uploads 0750 matrix-synapse matrix-synapse -"
    "d /var/lib/matrix-synapse/logs 0750 matrix-synapse matrix-synapse -"
    "f /var/lib/matrix-synapse/db-password 0600 matrix-synapse matrix-synapse - changeme-matrix-db-password"
  ];
}
