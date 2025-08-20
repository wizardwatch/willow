{
  config,
  lib,
  ...
}: {
  # SSH authorized keys configuration for willow
  # This centralized approach allows us to reuse the same keys across different machines

  # Define the authorized keys - use the same keys for both regular user and deployment
  # Add your actual SSH public keys here
  # Read public key from file
  _module.args.sshKeys = let
    # Import the public key from the file
    willowPublicKey = builtins.readFile ./willow_ssh.pub;
    #ssh2 = builtins.readFile ./ssh2.pub;
  in {
    # Personal keys
    personal = [
      #ssh2
      willowPublicKey
    ];

    # Deployment keys (for deploy-rs)
    deployment = [
      # Example format:
      # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... deploy-key-comment"
    ];

    # Combined list of all keys for convenience
    all = lib.mkMerge [
      config._module.args.sshKeys.personal
      config._module.args.sshKeys.deployment
    ];
  };
}
