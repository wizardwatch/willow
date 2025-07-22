{pkgs, ...}: {
  # Wayland-specific configuration for desktop environments

  # Required packages for Wayland usage
  environment.systemPackages = with pkgs; [
    # Screenshot and screen recording
    grimblast # Screenshot utility for Hyprland
    grim # Screenshot utility
    slurp # Region selector
    wf-recorder # Screen recorder

    # Clipboard and utilities
    wl-clipboard # Command-line clipboard utilities
    cliphist # Clipboard history

    # Display configuration
    wlr-randr # Similar to xrandr

    # Desktop environment utilities
    seatd # Seat management
    swaylock # Screen locker
    swayidle # Idle management
    waybar # Status bar

    # Notifications
    libnotify # Desktop notifications library
    mako # Notification daemon

    # File management
    xdg-utils # For opening files with correct app

    # Application launcher
    wofi # Application launcher
    fuzzel # Alternative launcher

    # Media
    mpv # Media player
  ];

  # Security settings
  security = {
    # Enable polkit for privilege escalation dialogs
    polkit.enable = true;

    # Authentication agent
    polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';

    # Allow swaylock to authenticate
    pam.services.swaylock = {};
    pam.services.hyprlock = {};
  };

  # Program settings
  programs = {
    # Password store and keyring
    seahorse.enable = true;

    # GNOME settings storage
    dconf.enable = true;

    # Hyprland
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };

  # XDG portal settings (for screen sharing, etc)
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
        xdg-desktop-portal-hyprland
      ];
      configPackages = with pkgs; [
        xdg-desktop-portal-hyprland
      ];
    };
  };

  # Ensure certain services are available
  systemd.user.services = {
    # Set up Polkit authentication agent
    polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
