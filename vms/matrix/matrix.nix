{
  config,
  pkgs,
  ...
}: {
  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = "matrix.holymike.com";
      public_baseurl = "https://matrix.holymike.com";
      suppress_key_server_warning = true;
      enable_registration = true;
      registration_requires_token = true;
      registration_shared_secret_path = "/run/host-secrets/matrix/registration.yaml";
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
    };
  };
}
