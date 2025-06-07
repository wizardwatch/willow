{ pkgs, ... }:
{
  programs = {
    zsh.enable = true;
  };
  #       #
  # fonts #
  #       #
  fonts = {
    packages = with pkgs; [
      corefonts
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Iosevka Nerd Font" ];
        serif = [ "Iosevka Etoile" ];
        sansSerif = [ "Iosevka Aile" ];
      };
    };
  };
  ## fixes some problems problems with pure gtk applications a little bit.
  # fonts.fontconfig.hinting.enable = false;
  ## made some fonts look really bad
  #fonts.fontconfig.antialias = false;
  #          #
  # pipewire #
  #          #
  # enabling sound.enable is said to cause conflicts with pipewire. Cidkid says it does not?
  #sound.enable = true;
  environment.etc = let
    json = pkgs.formats.json {};
  in {
      "machine-id".source = "/nix/persist/etc/machine-id";
      "ssh/ssh_host_rsa_key".source = "/nix/persist/etc/ssh/ssh_host_rsa_key";
      "ssh/ssh_host_rsa_key.pub".source = "/nix/persist/etc/ssh/ssh_host_rsa_key.pub";
      "ssh/ssh_host_ed25519_key".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
      "ssh/ssh_host_ed25519_key.pub".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key.pub";
    "/etc/pipewire/pipewire.conf.d/pipewire.conf".source = json.generate "pipewire.conf" {
      context.objects = [
        {
          factory = "adapter";
          args = {
            "factory.name"     = "support.null-audio-sink";
            "node.name"        = "Game_Audio";
            "node.description" = "Game Output";
            "media.class"      = "Audio/Sink";
            "audio.position"   = "FL,FR";
          };
        }
        {
          factory = "adapter";
          args = {
            "factory.name"     = "support.null-audio-sink";
            "node.name"        = "Game-Mic-Proxy";
            "node.description" = "Game Mic";
            "media.class"      = "Audio/Source/Virtual";
            "audio.position"   = "FL,FR";
          };
        }
    ];
  };
  };
  environment = {
    sessionVariables = {
      #HOME = "/home/willow/";
      #XDG_CONFIG_HOME = "/home/willow/.config";
      GDK_SCALE = "1.5";
      GDK_DPI_SCALE = "1";
    };
  };
}
