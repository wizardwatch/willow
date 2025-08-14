{config, ...}: {
  sops.templates."acme/dns" = {
    content = ''
      # Tokens for lego Cloudflare provider (Traefik ACME)
      CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder.ddns-pass}
    '';
    mode = "0640";
    group = "acme";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "osterling2705@icloud.com";
    certs = {
      "holymike.com" = {
        domain = "*.holymike.com";
        group = "traefik";
        dnsProvider = "cloudflare";
        environmentFile = config.sops.templates."traefik/dns.env".path;
      };
    };
  };
}
