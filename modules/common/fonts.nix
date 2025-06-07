{ config, pkgs, ... }:

{
  # Fonts configuration
  fonts = {
    packages = with pkgs; [

     # Additional font families
      iosevka
    ];

    fontconfig = {
      enable = true;

      # Default font settings
      defaultFonts = {
        monospace = [ "Iosevka Nerd Font" ];
        serif = [ "Iosevka Etoile" ];
        sansSerif = [ "Iosevka Aile" ];
      };

      # Uncomment to fix GTK application issues if needed
      # hinting.enable = false;
      # antialias = false;
    };
  };
}
