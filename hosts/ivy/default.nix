{
  config,
  lib,
  ...
}: {
  imports = [
    # Import hardware configuration
    ./hardware.nix

    # Import Ivy-specific configuration
    ./configuration.nix

    # Import modular configuration
    ../../modules/base.nix

    # Import user configuration
    ../../users
  ];

  # Ivy-specific deployment settings

  # Enable deployment via SSH
  services.openssh = {
    # Allow root login with SSH key only during initial deployment
    settings.PermitRootLogin = lib.mkForce "prohibit-password";

    # Make sure SSH starts early in the boot process
    startWhenNeeded = false;
  };

  # Make sure we have a predictable hostname for deployment
  networking.hostName = "ivy";

  # Ensure deployment user has appropriate access
  nix.settings.trusted-users = ["root" "willow"];
}
