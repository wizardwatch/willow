{
  config,
  pkgs,
  lib,
  ...
}: {
  # Serve Element Web via Caddy on :8082
  services.caddy = {
    enable = true;
    virtualHosts.":8082" = {
      extraConfig = ''
        # Serve a generated config.json from a writable path
        handle /config.json {
          root * /var/lib/element-web
          file_server
        }

        # Serve the static Element Web assets from the Nix store
        root * ${pkgs.element-web}/share/element-web
        encode zstd gzip
        file_server
      '';
    };
  };

  # Directory for runtime config.json
  systemd.tmpfiles.rules = [
    "d /var/lib/element-web 0755 root root -"
  ];

  # Element Web configuration pointing at the Matrix VM via Traefik
  environment.etc."element-web/config.json" = {
    target = "/var/lib/element-web/config.json";
    text = builtins.toJSON {
      default_server_config = {
        "m.homeserver" = {
          base_url = "https://matrix.holymike.com";
          server_name = "matrix.holymike.com";
        };
      };
      disable_custom_urls = true;
      brand = "Element";
    };
    mode = "0644";
  };
}
