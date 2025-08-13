{
  config,
  lib,
  ...
}: {
  sops.templates."ddns-updater.json" = {
    content = ''
      SETTINGS=[{"provider":"namecheap","domain":"holymike.com","password":"${config.sops.placeholder.ddns-pass}"}]
    '';
    # Ensure only root/systemd can read it
    mode = "0400";
  };

  services.ddns-updater = {
    enable = true;
    environment = {CONFIG_FILEPATH = config.sops.templates."ddns-updater.json".path;};
  };
}
