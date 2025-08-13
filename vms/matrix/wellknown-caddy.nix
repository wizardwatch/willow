{
  config,
  pkgs,
  lib,
  ...
}: {
  # Serve Matrix well-known files inside the Matrix VM via Caddy on :8081
  services.caddy = {
    enable = true;
    virtualHosts.":8081" = {
      extraConfig = ''
        root * /var/lib/matrix-wellknown
        encode zstd gzip
        file_server
      '';
    };
  };

  # User/group for ownership (world-readable is fine for Caddy)
  users.users.matrix-wellknown = {
    isSystemUser = true;
    group = "matrix-wellknown";
    home = "/var/lib/matrix-wellknown";
    createHome = true;
  };
  users.groups.matrix-wellknown = {};

  # Ensure directories exist
  systemd.tmpfiles.rules = [
    "d /var/lib/matrix-wellknown 0755 matrix-wellknown matrix-wellknown -"
    "d /var/lib/matrix-wellknown/.well-known 0755 matrix-wellknown matrix-wellknown -"
    "d /var/lib/matrix-wellknown/.well-known/matrix 0755 matrix-wellknown matrix-wellknown -"
  ];

  # Well-known: server (federation target)
  environment.etc."matrix-wellknown/server.json" = {
    target = "/var/lib/matrix-wellknown/.well-known/matrix/server";
    text = builtins.toJSON {
      # Keep federation on the canonical server name
      "m.server" = "matrix.holymike.com:443";
    };
    mode = "0644";
    user = "matrix-wellknown";
    group = "matrix-wellknown";
  };

  # Well-known: client (HS base URL for clients)
  environment.etc."matrix-wellknown/client.json" = {
    target = "/var/lib/matrix-wellknown/.well-known/matrix/client";
    text = builtins.toJSON {
      "m.homeserver" = {
        "base_url" = "https://matrix.onepagerpolitics.com";
      };
      "m.identity_server" = {
        "base_url" = "https://vector.im";
      };
    };
    mode = "0644";
    user = "matrix-wellknown";
    group = "matrix-wellknown";
  };
}
