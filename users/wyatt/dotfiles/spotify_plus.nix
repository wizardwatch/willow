{ pkgs, unstable, lib, spicetify-nix, home, ... }:
{
  # allow spotify to be installed if you don't have unfree enabled already
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "spotify-unwrapped"
  ];

  # import the flake's module for your system

  # configure spicetify :)
  programs.spicetify =
    {
      enable = true;
      theme = "catppuccin-mocha";
      colorScheme = "flamingo";

      enabledExtensions = [
        "fullAppDisplay.js"
        "shuffle+.js"
        "hidePodcasts.js"
      ];
    };
}
