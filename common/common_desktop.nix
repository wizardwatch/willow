{ config, pkgs, ... }:
{
  # Was causing kernel problems
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
  environment.systemPackages = with pkgs; [
    prusa-slicer
    logseq
    mpv
    gimp
    nixmaster.zathura
    gnome.cheese
    gnome.gnome-boxes
    alacritty
    # for rifle used with broot
    ranger
    inkscape
    #nixstaging.openscad
    musescore
    pavucontrol
    ## pipewire equalizer
    easyeffects
    qpwgraph
    ## if only I could draw
    krita
  ];
  #       #
  # fonts #
  #       #
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Iosevka Nerd Font" ];
        serif = [ "Iosevka Etoile" ];
        sansSerif = [ "Iosevka Aile" ];
      };
    };
    fonts = with pkgs; [
      (iosevka-bin.override { variant = "aile"; })
      (iosevka-bin.override { variant = "etoile"; })
      (nerdfonts.override { fonts = [ "Iosevka" ]; })
      ibm-plex
    ];
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
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    #media-session.enable = true;
    wireplumber.enable = true;
    enable = true;
    alsa.enable = true;
    #alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
  };
}
