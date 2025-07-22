{
  inputs,
  pkgs,
  ...
}: let
  authentikDir = "/var/lib/matrix/authentik";
in {
  # Import modular service configurations # matrix user
  users.users."matrix" = {
    isSystemUser = true;
    home = "/var/lib/matrix";
    group = "matrix";
  };
  # set the Authernik directory inside the matrix user's home
  imports = [
    ./services/traefik.nix
    ./services/authentik.nix
    # ./services/matrix.nix  # Disabled to focus on Authentik
    ./services/system.nix
  ];

  # Users are created by their respective modules
  # - Traefik module creates traefik user/group
  # - authentik-nix module creates authentik user/group
  # - matrix-synapse service creates matrix-synapse user/group
}
