{
  config,
  lib,
  ...
}: {
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      restrict-eval = false
      # Only use access-tokens if the secret exists
      ${lib.optionalString (config.sops.secrets ? nixAccessTokens) ''
        access-tokens = github.com !include ${config.sops.secrets.nixAccessTokens.path}
      ''}
    '';

    # Garbage collection settings
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 90d";
    };

    # Optimization settings
    settings = {
      auto-optimise-store = true;
      trusted-users = ["root" "@wheel"];
    };
  };
}
