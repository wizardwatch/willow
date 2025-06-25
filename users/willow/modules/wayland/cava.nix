{
  lib,
  pkgs,
  host ? {isDesktop = false;},
  ...
}: let
  isDesktop = host.isDesktop or false;
in {
  # Enable cava audio visualizer only on desktop systems
  config = lib.mkIf isDesktop {
    # Install cava package
    home.packages = with pkgs; [
      cava
    ];

    # Configure cava with pink and blue color scheme
    xdg.configFile."cava/config".text = ''
      [general]
      # Audio capturing method. Possible methods are:
      # 'pulse', 'alsa', 'fifo', 'sndio' or 'oss'.
      method = pulse

      # Source to capture audio from
      source = auto

      # Sensitivity in dB. Recommended values: -50 to -10
      sensitivity = 90

      # Bars configuration
      bars = 0
      bar_width = 2
      bar_spacing = 1

      [input]
      # Audio capturing method
      method = pipewire

      [output]
      # Output method. Can be 'ncurses', 'noncurses', 'raw', 'wav', or 'sdl'
      method = ncurses

      # Visual styles for ncurses
      style = stereo

      [color]
      # Color scheme using pink and blue gradient
      # Colors can be one of seven predefined: black, blue, cyan, green, magenta, red, white, yellow
      # Or defined by hex code '#rrggbb' or 256 color index

      # Gradient colors from pastel blue through white to pastel pink
      gradient = 1
      gradient_count = 7

      # Define the gradient colors (pastel blue to white to pastel pink)
      gradient_color_1 = '#5bcffb'  # Pastel blue
      gradient_color_2 = '#f5abb9'  # Pastel pink
      gradient_color_3 = '#ffffff'  # White (middle)
      gradient_color_4 = '#f5abb9'  # Pastel pink
      gradient_color_5 = '#5bcffb'  # Pastel blue

      [smoothing]
      # Multiplier for the integral smoothing calculations
      integral = 77

      # Disables or enables the so-called "Monstercat smoothing" with or without "waves"
      monstercat = 0
      waves = 0

      # Set gravity multiplier for "drop off"
      gravity = 30

      # In bar height, bars that would have been lower that this will not be drawn
      ignore = 0

      [eq]
      # This one is tricky. You can have as much keys as you want.
      # Remember to uncomment more than one key! More keys = more precision.
      # Look at readme.md on github for further explanations and examples.
      1 = 1 # bass
      2 = 1
      3 = 1 # midtone
      4 = 1
      5 = 1 # treble
    '';
  };

  # Empty options declaration to avoid warnings
  options = {};
}
