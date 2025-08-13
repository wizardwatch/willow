{...}: {
  services.ddns-updater = {
    enable = true;
    environment = {
      settings = [
        {
          provider = "namecheap";
          domain = "holymike.com";
        }
      ];
    };
  };
}
