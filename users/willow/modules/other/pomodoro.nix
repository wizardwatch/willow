# Pomodoro Timer Integration for NixOS with Waybar Support
#
# This module provides:
# - openpomodoro-cli installation
# - Waybar integration with click handlers
# - Desktop notifications via hooks
# - Shell aliases for convenience
#
# Waybar integration is handled in waybar.nix
#
# Usage:
# - Left click: Start/clear pomodoro or show status
# - Right click: Context menu with all options
# - Terminal: Use 'pom' commands (poms, pomt, pomc, etc.)
{
  pkgs,
  lib,
  config,
  host ? {isDesktop = false;},
  ...
}: let
  # Only use this module if we're on a desktop system
  isDesktop = host.isDesktop or false;

  # Use openpomodoro-cli from nixpkgs
  openpomodoro-cli = pkgs.openpomodoro-cli;

  # Pomodoro waybar module script
  pomodoroScript = pkgs.writeShellScript "waybar-pomodoro" ''
    #!${pkgs.bash}/bin/bash

    # Check if pomodoro command is available
    if ! command -v pomodoro &> /dev/null; then
      echo '{"text": "❌", "tooltip": "Pomodoro CLI not found"}'
      exit 0
    fi

    # Get the current status
    status=$(pomodoro status 2>/dev/null || echo "")

    if [ -z "$status" ]; then
      # No active pomodoro
      echo '{"text": "🍅", "tooltip": "No active pomodoro\nClick to start", "class": "inactive"}'
    elif [[ "$status" == *"❗"* ]]; then
      # Pomodoro finished
      echo '{"text": "❗🍅", "tooltip": "Pomodoro finished!\nClick to clear", "class": "finished"}'
    else
      # Active pomodoro - extract time
      time=$(echo "$status" | head -n1 | cut -d' ' -f1)
      description=$(echo "$status" | tail -n+2 | head -n1 || echo "")

      if [ -n "$description" ]; then
        tooltip="$time remaining\n$description\nRight-click for actions"
      else
        tooltip="$time remaining\nRight-click for actions"
      fi

      echo "{\"text\": \"$time 🍅\", \"tooltip\": \"$tooltip\", \"class\": \"active\"}"
    fi
  '';

  # Pomodoro control script for waybar clicks
  pomodoroControl = pkgs.writeShellScript "pomodoro-control" ''
    #!${pkgs.bash}/bin/bash

    case "$1" in
      "start")
        # Use rofi or wofi to get pomodoro description
        if command -v rofi &> /dev/null; then
          description=$(rofi -dmenu -p "Pomodoro description:")
        elif command -v wofi &> /dev/null; then
          description=$(echo "" | wofi --dmenu -p "Pomodoro description:")
        else
          description=""
        fi

        if [ -n "$description" ]; then
          pomodoro start "$description"
        else
          pomodoro start
        fi
        ;;
      "cancel")
        pomodoro cancel
        ;;
      "finish")
        pomodoro finish
        ;;
      "clear")
        pomodoro clear
        ;;
      "break")
        pomodoro break
        ;;
      "status")
        status=$(pomodoro status 2>/dev/null || echo "No active pomodoro")
        if command -v notify-send &> /dev/null; then
          notify-send "Pomodoro Status" "$status"
        else
          echo "$status"
        fi
        ;;
      *)
        # Default action based on current state
        status=$(pomodoro status 2>/dev/null || echo "")
        if [ -z "$status" ]; then
          # No active pomodoro, start one
          exec "$0" start
        elif [[ "$status" == *"❗"* ]]; then
          # Finished pomodoro, clear it
          pomodoro clear
        else
          # Active pomodoro, show status
          exec "$0" status
        fi
        ;;
    esac
  '';

  # Context menu script for right-click actions
  pomodoroMenu = pkgs.writeShellScript "pomodoro-menu" ''
    #!${pkgs.bash}/bin/bash

    # Create menu options based on current state
    status=$(pomodoro status 2>/dev/null || echo "")

    if [ -z "$status" ]; then
      # No active pomodoro
      options="Start Pomodoro\nStart with description\nShow history"
      actions="start\nstart\nhistory"
    elif [[ "$status" == *"❗"* ]]; then
      # Finished pomodoro
      options="Clear finished\nStart new\nShow history"
      actions="clear\nstart\nhistory"
    else
      # Active pomodoro
      options="Show status\nFinish early\nCancel\nTake break\nShow history"
      actions="status\nfinish\ncancel\nbreak\nhistory"
    fi

    # Use rofi or wofi for menu
    if command -v rofi &> /dev/null; then
      choice=$(echo -e "$options" | rofi -dmenu -p "Pomodoro:")
    elif command -v wofi &> /dev/null; then
      choice=$(echo -e "$options" | wofi --dmenu -p "Pomodoro:")
    else
      echo "No menu program available (rofi/wofi)"
      exit 1
    fi

    case "$choice" in
      "Start Pomodoro")
        ${pomodoroControl} start
        ;;
      "Start with description")
        ${pomodoroControl} start
        ;;
      "Start new")
        ${pomodoroControl} start
        ;;
      "Clear finished")
        ${pomodoroControl} clear
        ;;
      "Show status")
        ${pomodoroControl} status
        ;;
      "Finish early")
        ${pomodoroControl} finish
        ;;
      "Cancel")
        ${pomodoroControl} cancel
        ;;
      "Take break")
        ${pomodoroControl} break
        ;;
      "Show history")
        history=$(pomodoro history | tail -10)
        if command -v notify-send &> /dev/null; then
          notify-send "Pomodoro History" "$history"
        else
          echo "$history"
        fi
        ;;
    esac
  '';
in
  lib.mkIf isDesktop {
    # Install the openpomodoro-cli package
    home.packages = [openpomodoro-cli];

    # Export scripts for waybar integration
    _module.args.pomodoroScript = pomodoroScript;
    _module.args.pomodoroControl = pomodoroControl;
    _module.args.pomodoroMenu = pomodoroMenu;

    # Create configuration directory
    home.file.".pomodoro/.keep".text = "";

    # Add hooks for notifications
    home.file.".pomodoro/hooks/start" = {
      text = ''
        #!/usr/bin/env bash
        if command -v notify-send &> /dev/null; then
          notify-send "🍅 Pomodoro Started" "Focus time! Get to work." --urgency=normal
        fi
      '';
      executable = true;
    };

    home.file.".pomodoro/hooks/stop" = {
      text = ''
        #!/usr/bin/env bash
        if command -v notify-send &> /dev/null; then
          notify-send "🍅 Pomodoro Finished" "Great work! Time for a break." --urgency=critical
        fi
      '';
      executable = true;
    };

    home.file.".pomodoro/hooks/break" = {
      text = ''
        #!/usr/bin/env bash
        if command -v notify-send &> /dev/null; then
          notify-send "☕ Break Time" "Relax and recharge!" --urgency=normal
        fi
      '';
      executable = true;
    };

    # Add shell aliases for convenience
    programs.zsh.shellAliases = lib.mkIf (config.programs.zsh.enable or false) {
      pom = "pomodoro";
      poms = "pomodoro start";
      pomt = "pomodoro status";
      pomc = "pomodoro clear";
      pomx = "pomodoro cancel";
      pomf = "pomodoro finish";
      pomb = "pomodoro break";
      pomh = "pomodoro history";
    };

    programs.bash.shellAliases = lib.mkIf (config.programs.bash.enable or false) {
      pom = "pomodoro";
      poms = "pomodoro start";
      pomt = "pomodoro status";
      pomc = "pomodoro clear";
      pomx = "pomodoro cancel";
      pomf = "pomodoro finish";
      pomb = "pomodoro break";
      pomh = "pomodoro history";
    };
  }
