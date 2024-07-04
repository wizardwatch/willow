{ config, pkgs, lib, trunk, home-manager, self, inputs, ... }:
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
     "steam"
     "steam-original"
     "steam-run"
   ];
  imports = [
    ### Basic Settings and Config
    ### You Know
    ### unixStuff
    ./unixStuff/users.nix
    ./unixStuff/environment.nix
    ./unixStuff/extraHardware.nix
    ./unixStuff/networking.nix
    ###
    ### Programs, it's in the name
    ###
    ./programs/cyberSecurity.nix
    ./programs/desktop/main.nix
    ### These Programs run for longer
    ### Thus wanted a special dir
    ###
    ./services/services.nix
    ### I Would Tell You Whats in Here
    ### But it's a Secret
    ###
    ./secrets/secrets.nix
  ];
  environment.systemPackages = with pkgs; [
    inputs.ags.packages.x86_64-linux.default
    sshfs
    nodejs_18
    alsa-utils
    tree
    hugo
    gcc
    jq
    pandoc
    tokei
    age
    ssh-to-age
    sops
    nix-alien
    nix-index
  ];
  security.rtkit.enable = true;
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      restrict-eval = false
      access-tokens = github.com !include ${config.sops.secrets.nixAccessTokens.path}
    '';
  };
  time.timeZone = "America/New_York";
  virtualisation = {
    docker = {
      enable   = true;
      daemon.settings = {
        data-root = "/home/dockerFolder/";
      };
    };
    waydroid.enable = false;
    lxd.enable      = false;
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # amd gpu
  boot = {
    initrd.kernelModules = [ "amdgpu" ];
  };
  sops.secrets.wyattPassword.neededForUsers = true;
  nixpkgs.overlays = [
    self.inputs.nix-alien.overlays.default
  ];
  system.stateVersion = "23.05";
}
