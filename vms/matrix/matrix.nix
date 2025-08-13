{
  config,
  pkgs,
  ...
}: {
  services.matrix-synapse = {
    enable = true;
    settings = {
      # Keep server_name stable (MXIDs stay @user:matrix.holymike.com)
      server_name = "matrix.holymike.com";
      # Serve the homeserver via this HTTPS base URL
      public_baseurl = "https://matrix.onepagerpolitics.com";
      suppress_key_server_warning = true;
      enable_registration = true;
      registration_requires_token = true;
      registration_shared_secret_path = "/run/host-secrets/matrix/registration";
      listeners = [
        {
          port = 8008;
          bind_addresses = ["0.0.0.0"];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = ["client" "federation"];
              compress = true;
            }
          ];
        }
      ];

      database = {
        name = "psycopg2";
        # Allow non-C collation without reinitializing the cluster
        allow_unsafe_locale = true;
        args = {
          host = "/run/postgresql";
          database = "synapse";
          user = "synapse";
        };
      };

      # Disable rate limiting for login attempts
      rc_login = {
        account = {
          per_second = 1000;
          burst_count = 1000;
        };
        failed_attempts = {
          per_second = 1000;
          burst_count = 1000;
        };
      };
    };
  };
}
