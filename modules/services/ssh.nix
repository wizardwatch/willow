{ config, pkgs, ... }:

{
  # OpenSSH server configuration
  services.openssh = {
    enable = true;
    
    # Security settings
    settings = {
      # Disable password authentication
      PasswordAuthentication = false;
      
      # Don't allow root login
      PermitRootLogin = "no";
      
      # Use modern crypto only
      KexAlgorithms = [
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group-exchange-sha256"
      ];
      
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
        "aes256-ctr"
        "aes192-ctr"
        "aes128-ctr"
      ];
      
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];
    };
    
    # Automatically open firewall
    openFirewall = true;
    
    # For better security, use host keys from persisted storage
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };
  
  # Additional security settings
  security.pam.enableSSHAgentAuth = true;
}