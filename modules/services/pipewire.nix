{ config, pkgs, ... }:

let
  json = pkgs.formats.json {};
in
{

  # Main PipeWire configuration
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # Custom audio sinks and sources for gaming/streaming
  environment.etc."/etc/pipewire/pipewire.conf.d/pipewire.conf".source = json.generate "pipewire.conf" {
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

  # Add audio utilities
  environment.systemPackages = with pkgs; [
    alsa-utils
    pulsemixer
    pavucontrol
    qpwgraph    # PipeWire graph
    easyeffects # Audio effects
  ];

  # Ensure audio group exists
  users.groups.audio = {};
}
