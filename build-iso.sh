#!/usr/bin/env bash
set -e

echo "Building minimal NixOS deployment ISO..."
cd "$(dirname "$0")"

# Build the ISO
nix build .#iso -o result-iso

ISO_PATH=$(readlink -f result-iso)/iso/nixos-*.iso
echo "ISO created at: $ISO_PATH"

# Check if user wants to copy to USB
if [ "$1" == "--usb" ] || [ "$1" == "-u" ]; then
  if [ -z "$2" ]; then
    echo "Error: No USB device specified."
    echo "Usage: $0 --usb /dev/sdX"
    exit 1
  fi
  
  USB_DEV="$2"
  if [ ! -b "$USB_DEV" ]; then
    echo "Error: $USB_DEV is not a valid block device."
    exit 1
  fi
  
  echo "WARNING: This will erase all data on $USB_DEV!"
  read -p "Are you sure you want to continue? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Writing ISO to $USB_DEV..."
    sudo dd bs=4M if="$ISO_PATH" of="$USB_DEV" conv=fsync status=progress
    echo "Done! USB drive is ready."
  else
    echo "Operation cancelled."
  fi
fi

echo "To deploy using this ISO:"
echo "1. Boot from the ISO"
echo "2. Connect to a network (use 'nmtui' or 'nmcli')"
echo "3. Use 'ip a' to find the IP address"
echo "4. Deploy from your machine with: deploy .#your-host --target-host root@<IP_ADDRESS>"
echo "   (The default root password is 'nixos')"