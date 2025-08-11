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
      macaroon_secret_key = "changeme-dev-macaroon-secret";

      listeners = [
        {
          port = 8008;
          bind_addresses = ["0.0.0.0"];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [{ names = ["client" "federation"]; compress = true; }];
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
