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
        # Serve static Element Web assets (config.json embedded in package)
        root * ${pkgs.element-web}
        encode zstd gzip
        file_server
      '';
    };
  };

  # No runtime config.json needed; element-web serves its embedded config.json
}
