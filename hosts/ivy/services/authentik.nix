{
  inputs,
  pkgs,
  ...
}: {
  # Import required service modules
  imports = [
    inputs.authentik-nix.nixosModules.default
  ];

  # Authentik SSO configuration using nix-community/authentik-nix
  services.authentik = {
    enable = true;
    environmentFile = "/var/lib/authentik/authentik.env";
    nginx.enable = false; # Using Traefik instead
  };

  # Create authentik directories and secrets
  systemd.tmpfiles.rules = [
    "d /var/lib/authentik 0750 authentik authentik -"
    "f /var/lib/authentik/secret-key 0600 authentik authentik - changeme-authentik-secret-key-replace-this"
    "f /var/lib/authentik/db-password 0600 authentik authentik - changeme-authentik-db-password"
  ];
}
