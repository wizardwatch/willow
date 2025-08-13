{
  config,
  lib,
  ...
}: {
  sops.templates."ddns-updater.json" = {
    content = ''
      {
        "settings": [
          {
            "provider":"cloudflare",
            "zone_identifier": "${config.sops.placeholder.zone-id}",
            "domain":"*.onepagerpolitics.com",
            "token":"${config.sops.placeholder.ddns-pass}",
            "ttl": 1
          }
        ]
      }
    '';

    mode = "0666";
  };

  services.ddns-updater = {
    enable = true;
    environment = {CONFIG_FILEPATH = config.sops.templates."ddns-updater.json".path;};
  };
}
