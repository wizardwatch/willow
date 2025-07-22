# 🍅 Pomodoro Timer Integration

This module integrates [openpomodoro-cli](https://github.com/open-pomodoro/openpomodoro-cli) with Waybar for a seamless Pomodoro Timer experience on your NixOS desktop.

## Features

- **CLI Pomodoro Timer**: Full-featured command-line pomodoro timer using the Open Pomodoro Format
- **Waybar Integration**: Visual pomodoro status in your status bar with click interactions
- **Desktop Notifications**: Automatic notifications when pomodoros start, finish, or break time begins
- **Context Menus**: Right-click waybar icon for quick access to all pomodoro functions
- **Shell Aliases**: Convenient shortcuts for common pomodoro commands
- **Visual Feedback**: Animated waybar icons showing active, finished, and idle states

## Setup

1. **Enable the module** by importing it in your NixOS configuration
2. **Rebuild** your system: `sudo nixos-rebuild switch`
3. **Restart waybar** to load the new module: `pkill waybar && waybar &`

The pomodoro module will automatically be added to the left side of your waybar.

## Usage

### Waybar Integration

- **Left Click**: 
  - If no pomodoro active: Start a new pomodoro
  - If pomodoro finished: Clear the finished pomodoro
  - If pomodoro running: Show current status
- **Right Click**: Open context menu with all available actions

### Command Line Interface

The module provides convenient shell aliases:

```bash
pom      # pomodoro (base command)
poms     # pomodoro start
pomt     # pomodoro status  
pomc     # pomodoro clear
pomx     # pomodoro cancel
pomf     # pomodoro finish
pomb     # pomodoro break
pomh     # pomodoro history
```

### Full CLI Commands

```bash
# Start a 25-minute pomodoro
pomodoro start

# Start with description and tags
pomodoro start "Write documentation" -t work,docs

# Start with custom duration
pomodoro start --duration 30

# Check current status
pomodoro status

# Custom status format
pomodoro status -f "%R minutes left 🍅"

# Cancel current pomodoro
pomodoro cancel

# Finish current pomodoro early
pomodoro finish

# Clear finished pomodoro
pomodoro clear

# Take a break
pomodoro break

# Take a 15-minute break
pomodoro break 15

# View history
pomodoro history

# View history in JSON format
pomodoro history --output json
```

## Visual States

The waybar icon shows different states:

- **🍅** (gray): No active pomodoro - click to start
- **25:00 🍅** (blue, pulsing): Active pomodoro with time remaining
- **❗🍅** (red, blinking): Finished pomodoro - click to clear

## Notifications

The module automatically sends desktop notifications for:

- **Pomodoro Started**: "Focus time! Get to work."
- **Pomodoro Finished**: "Great work! Time for a break."
- **Break Started**: "Relax and recharge!"

## Configuration

### Pomodoro Settings

The pomodoro configuration is stored in `~/.pomodoro/`. You can customize:

- Default pomodoro duration (25 minutes)
- Break duration (5 minutes)
- Daily goals
- Custom hooks

### Waybar Styling

The waybar styling is configured in `waybar.nix` with:

- **Transparent background**: Main waybar window has transparent background
- **Semi-transparent modules**: Individual modules use rgba backgrounds
- **Gruvbox color scheme**: Based on Gruvbox theme colors
- **Pomodoro states**:
  - **Inactive**: Gray semi-transparent background
  - **Active**: Blue background with subtle pulsing animation
  - **Finished**: Red background with blinking animation

### Custom Hooks

Create executable scripts in `~/.pomodoro/hooks/` to run custom actions:

```bash
# ~/.pomodoro/hooks/start
#!/usr/bin/env bash
echo "Starting focus session!" >> ~/pomodoro.log

# ~/.pomodoro/hooks/stop  
#!/usr/bin/env bash
echo "Completed a pomodoro!" >> ~/pomodoro.log
```

Available hooks:
- `start`: Runs when a pomodoro begins
- `stop`: Runs when a pomodoro ends (finish, cancel, or clear)
- `break`: Runs when a break starts

## Dependencies

Required packages (automatically installed):
- `openpomodoro-cli`: The core pomodoro timer
- `libnotify`: For desktop notifications

Optional but recommended:
- `rofi` or `wofi`: For interactive menus
- A notification daemon (like `dunst`)

## Testing

Run the test script to verify everything is working:

```bash
./test-pomodoro.sh
```

This will test:
- Pomodoro CLI functionality
- Waybar script integration
- Notification system
- Shell aliases
- Configuration files

## Troubleshooting

### Waybar module not showing
- Ensure waybar is restarted after configuration changes
- Check that `custom/pomodoro` is in your waybar modules-left
- Verify scripts are executable and in PATH

### Notifications not working
- Install a notification daemon: `services.dunst.enable = true;`
- Check that `libnotify` is available: `which notify-send`

### Right-click menu not working
- Install rofi: `programs.rofi.enable = true;`
- Or install wofi: `programs.wofi.enable = true;`

### Commands not found
- Restart your shell to load new aliases: `exec $SHELL`
- Check that openpomodoro-cli is in PATH: `which pomodoro`

## Integration Examples

### With Tmux

Use pomodoro status in tmux status line:

```bash
set -g status-right '#[fg=red]#(pomodoro status -f "%R🍅")#[default] %H:%M'
```

### With Scripts

Create productivity scripts that integrate with pomodoro:

```bash
#!/bin/bash
# focus-mode.sh
pomodoro start "Deep work session" -t focus
# Enable do-not-disturb, close distracting apps, etc.
```

### Data Export

Export your pomodoro history:

```bash
# Export to calendar
pomodoro history --output ical > ~/pomodoros.ics

# JSON for analysis
pomodoro history --output json | jq '.pomodoros[] | select(.tags[] == "work")'
```

## Open Pomodoro Format

This tool uses the [Open Pomodoro Format](https://github.com/open-pomodoro/open-pomodoro-format), making your data portable between different pomodoro applications.

Data is stored in: `~/.pomodoro/pomodoros.json`
