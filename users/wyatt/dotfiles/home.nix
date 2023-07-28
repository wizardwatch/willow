{ pkgs, unstable, /*spicetify-nix,*/ lib, config, ... }: {
  fonts.fontconfig = {
    enable = true;
  };
  home = {
    username = "wyatt";
    stateVersion = "23.05";
    #homeDirectory = "/home/wyatt/.config";
  };
  /*
  services.mpd = {
    enable = false;
    package = pkgs.mpd;
    dataDir = "/home/wyatt/.config/mpd";
    musicDirectory = "/home/wyatt/Music";
    extraConfig = ''
                      audio_output {
                        type "pulse"
                        name "fakepipe"
                      }
                      audio_output {
                        type    "fifo"
                        name    "my_fifo"
                        path    "/tmp/mpd.fifo"
                        format  "44100:16:2"
      }
    '';
  };
  gtk = {
    enable = true;
    font.name = "Iosevka";
    font.size = 14;
    theme.package = pkgs.dracula-theme;
    theme.name = "Dracula";
  };
  */
  /*
  home.file = {
    river = {
      source = ./wayland/init;
      target = "./.config/river/init";
    };
    eww = {
      source = ./other/eww;
      recursive = true;
      target = "./.config/eww/";
    };
  };
  */
  imports = [
    ./textEditors/neovim.nix
    ./textEditors/emacs/main.nix
    ./wayland/main.nix
    #./x/main.nix
    #./other/ncmpcpp.nix
    #./other/starship.nix
    #./spotify_plus.nix
  ];
  services.spotifyd = {
    enable = true;
    settings = {
      username = "wyatt.osterling@hotmail.com";
      password_cmd = "echo $SPOTIFY";
      device_name = "willow";
    };
  };
  # import the flake's module for your system

  # configure spicetify :)
    programs = {
    /*
      spicetify = 
      let
        officialThemesPINNED = pkgs.fetchgit {
          url = "https://github.com/spicetify/spicetify-themes";
          rev = "eb6b818368d9c01ef92522623b37aa29200d0bc0";
          sha256 = "Q/LBS+bjt2WP/s43LE8hDjYHxPVorT/RA71esPraLOM=";
        };
      in {
        enable = true;
        theme = {
          src = officialThemesPINNED;
          name = "Dribbblish";
          injectCss = true;
          replaceColors = true;
          overwriteAssets = true;
          sidebarConfig = true;
        };
        colorScheme = "custom";
        enabledExtensions = [
          "fullAppDisplay.js"
          "shuffle+.js"
          "hidePodcasts.js"
        ];
        customColorScheme = {
          text = "ebbcba";
          subtext = "F0F0F0";
          sidebar-text = "e0def4";
          main = "191724";
          sidebar = "2a2837";
          player = "191724";
          card = "191724";
          shadow = "1f1d2e";
          selected-row = "797979";
          button = "31748f";
          button-active = "31748f";
          button-disabled = "555169";
          tab-active = "ebbcba";
          notification = "1db954";
          notification-error = "eb6f92";
          misc = "6e6a86";
        };
      };*/
      foot = {
        enable = true;
        settings = {
          main = {
            term = "xterm-256color";
            font = "Iosevka:size=14";
            dpi-aware = "yes";
          };
          mouse = {
            hide-when-typing = "yes";
          };
          colors = {
            background = "0x282a36";
        };
      };
    };
  };
}
