#!/usr/bin/env bash

# Test script for Pomodoro Waybar Integration
# This script tests the openpomodoro-cli installation and waybar integration

set -e

echo "🍅 Testing Pomodoro Integration..."
echo "================================="

# Check if pomodoro command is available
if ! command -v pomodoro &> /dev/null; then
    echo "❌ ERROR: pomodoro command not found"
    echo "   Make sure openpomodoro-cli is installed and in PATH"
    exit 1
fi

echo "✅ pomodoro command found"

# Test basic pomodoro functionality
echo ""
echo "Testing basic pomodoro commands:"
echo "--------------------------------"

# Test status (should show no active pomodoro initially)
echo "🔍 Testing status command..."
status_output=$(pomodoro status 2>/dev/null || echo "No active pomodoro")
echo "   Status: $status_output"

# Test history command
echo "🔍 Testing history command..."
history_output=$(pomodoro history 2>/dev/null | head -3 || echo "No history")
echo "   Recent history: $history_output"

# Test starting a pomodoro (very short duration for testing)
echo "🔍 Testing start command (5 second test pomodoro)..."
pomodoro start "Test Pomodoro" --duration 5s --tags testing

# Check status again
echo "🔍 Checking status after start..."
active_status=$(pomodoro status 2>/dev/null)
echo "   Active status: $active_status"

# Wait a moment then cancel to clean up
sleep 2
echo "🔍 Canceling test pomodoro..."
pomodoro cancel

# Verify cleanup
final_status=$(pomodoro status 2>/dev/null || echo "No active pomodoro")
echo "   Final status: $final_status"

echo ""
echo "Testing waybar integration:"
echo "--------------------------"

# Check if waybar is running
if pgrep -x "waybar" > /dev/null; then
    echo "✅ Waybar is running"
else
    echo "⚠️  Waybar is not running"
fi

# Check waybar config for pomodoro module
waybar_config_locations=(
    "$HOME/.config/waybar/config"
    "$HOME/.config/waybar/config.json"
)

found_waybar_config=false
for config_path in "${waybar_config_locations[@]}"; do
    if [[ -f "$config_path" ]]; then
        if grep -q "custom/pomodoro" "$config_path"; then
            echo "✅ Found pomodoro module in waybar config: $config_path"
            found_waybar_config=true
        fi
        break
    fi
done

if [[ "$found_waybar_config" == false ]]; then
    echo "⚠️  Pomodoro module not found in waybar config"
    echo "   Check that custom/pomodoro is in modules-left"
fi

# Check if waybar scripts exist and are executable
waybar_script_locations=(
    "$HOME/.nix-profile/bin/waybar-pomodoro"
    "/run/current-system/sw/bin/waybar-pomodoro"
)

found_waybar_script=false
for script_path in "${waybar_script_locations[@]}"; do
    if [[ -x "$script_path" ]]; then
        echo "✅ Found waybar pomodoro script at: $script_path"

        # Test the waybar script output
        echo "🔍 Testing waybar script output..."
        waybar_output=$("$script_path" 2>/dev/null || echo '{"text": "❌", "tooltip": "Script error"}')
        echo "   Waybar JSON: $waybar_output"

        found_waybar_script=true
        break
    fi
done

if [[ "$found_waybar_script" == false ]]; then
    echo "⚠️  Waybar pomodoro script not found in expected locations"
    echo "   This is normal if the module hasn't been fully activated yet"
fi

# Test waybar styling
echo "🔍 Checking waybar styling..."
waybar_style_locations=(
    "$HOME/.config/waybar/style.css"
)

found_waybar_style=false
for style_path in "${waybar_style_locations[@]}"; do
    if [[ -f "$style_path" ]]; then
        if grep -q "custom-pomodoro" "$style_path"; then
            echo "✅ Found pomodoro styling in waybar CSS: $style_path"

            # Check for transparent background
            if grep -q "background-color: transparent" "$style_path"; then
                echo "✅ Transparent background configured"
            else
                echo "⚠️  Transparent background not found in CSS"
            fi

            found_waybar_style=true
        fi
        break
    fi
done

if [[ "$found_waybar_style" == false ]]; then
    echo "⚠️  Pomodoro styling not found in waybar CSS"
fi

echo ""
echo "Testing shell aliases:"
echo "---------------------"

# Test if aliases are available (they might not be in current session)
aliases_to_test=("pom" "poms" "pomt" "pomc" "pomx" "pomf" "pomb" "pomh")
for alias_name in "${aliases_to_test[@]}"; do
    if alias "$alias_name" &>/dev/null; then
        alias_def=$(alias "$alias_name" 2>/dev/null)
        echo "✅ $alias_def"
    else
        echo "⚠️  Alias '$alias_name' not found (may need shell restart)"
    fi
done

echo ""
echo "Testing notification system:"
echo "---------------------------"

if command -v notify-send &> /dev/null; then
    echo "✅ notify-send available"
    echo "🔍 Testing notification..."
    notify-send "🍅 Pomodoro Test" "Integration test completed!" --urgency=normal
else
    echo "⚠️  notify-send not available (notifications won't work)"
fi

echo ""
echo "Testing menu dependencies:"
echo "-------------------------"

if command -v rofi &> /dev/null; then
    echo "✅ rofi available (preferred menu)"
elif command -v wofi &> /dev/null; then
    echo "✅ wofi available (alternative menu)"
else
    echo "⚠️  Neither rofi nor wofi available (right-click menus won't work)"
fi

echo ""
echo "Configuration check:"
echo "-------------------"

# Check if pomodoro config directory exists
if [[ -d "$HOME/.pomodoro" ]]; then
    echo "✅ Pomodoro config directory exists: $HOME/.pomodoro"

    # Check hooks
    hook_files=("start" "stop" "break")
    for hook in "${hook_files[@]}"; do
        hook_path="$HOME/.pomodoro/hooks/$hook"
        if [[ -x "$hook_path" ]]; then
            echo "✅ Hook '$hook' is executable"
        else
            echo "⚠️  Hook '$hook' not found or not executable"
        fi
    done
else
    echo "⚠️  Pomodoro config directory not found"
fi

echo ""
echo "🍅 Test Summary:"
echo "==============="
echo "✅ Basic pomodoro functionality works"
if [[ "$found_waybar_script" == true && "$found_waybar_config" == true ]]; then
    echo "✅ Waybar integration fully configured"
elif [[ "$found_waybar_script" == true ]]; then
    echo "⚠️  Waybar scripts available but config needs update"
else
    echo "⚠️  Waybar integration needs activation"
fi

if [[ "$found_waybar_style" == true ]]; then
    echo "✅ Waybar styling configured with transparent background"
else
    echo "⚠️  Waybar styling needs configuration"
fi

echo ""
echo "Next steps:"
echo "----------"
echo "1. Rebuild your NixOS configuration: sudo nixos-rebuild switch"
echo "2. Restart your shell to load aliases: exec $SHELL"
echo "3. Restart waybar to load the new module and styling: pkill waybar && waybar &"
echo "4. Verify transparent background and module appearance"
echo "5. Test the waybar integration by clicking the tomato icon"
echo ""
echo "Usage:"
echo "- Left click waybar tomato: Start/clear/status pomodoro"
echo "- Right click waybar tomato: Open context menu"
echo "- Terminal shortcuts: poms (start), pomt (status), pomc (clear)"
