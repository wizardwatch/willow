{
  inputs,
  pkgs,
  authentikDir,
  ...
}: {
  # Import required service modules
  imports = [
    inputs.authentik-nix.nixosModules.default
  ];

  # Authentik SSO configuration using nix-community/authentik-nix
  services.authentik = {
    enable = true;
    environmentFile = authentikDir + "/authentik.env";
    nginx.enable = false; # Using Traefik instead
  };

  # Create authentik directories and secrets
  systemd.tmpfiles.rules = [
    "d /var/lib/authentik 0750 authentik authentik -"
    "f /var/lib/authentik/secret-key 0600 authentik authentik - changeme-authentik-secret-key-replace-this"
    "f /var/lib/authentik/db-password 0600 authentik authentik - changeme-authentik-db-password"
  ];

  # Create the environment file that Authentik expects
  environment.etc."authentik/authentik.env".text = ''
    AUTHENTIK_SECRET_KEY=changeme-authentik-secret-key-replace-this
    AUTHENTIK_POSTGRESQL__PASSWORD=changeme-authentik-db-password
    AUTHENTIK_BOOTSTRAP_PASSWORD=changeme-bootstrap-password
    AUTHENTIK_BOOTSTRAP_TOKEN=changeme-bootstrap-token
    AUTHENTIK_BOOTSTRAP_EMAIL=admin@ivy.local
    AUTHENTIK_LOG_LEVEL=info
    AUTHENTIK_REDIS__HOST=localhost
    AUTHENTIK_REDIS__PORT=6379
  '';

  # Enable required services for Authentik
  services.postgresql = {
    enable = true;
    ensureDatabases = ["authentik"];
    ensureUsers = [
      {
        name = "authentik";
        ensureDBOwnership = true;
      }
    ];
  };

  services.redis.servers.authentik = {
    enable = true;
    port = 6379;
    bind = "127.0.0.1";
  };
}
