{
  inputs,
  pkgs,
  ...
}: {
  # Import modular service configurations
  imports = [
    ./services/traefik.nix
    ./services/authentik.nix
    ./services/matrix.nix
    ./services/system.nix
  ];

  # Users are created by their respective modules
  # - Traefik module creates traefik user/group
  # - authentik-nix module creates authentik user/group
  # - matrix-synapse service creates matrix-synapse user/group
}
