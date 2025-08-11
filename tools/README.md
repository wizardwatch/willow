# NixOS Deployment Guide & CLI Tool

A comprehensive NixOS deployment solution that includes a Python CLI tool for managing deployments with SOPS integration. Uses deploy-rs under the hood.

- **Single CLI Tool**: `deploy-cli` handles all deployment operations
- **Automatic SOPS Setup**: No conditional configuration needed - SOPS is always enabled
- **Prerequisite Management**: SSH keys and directories are ensured before deployment

## Quick Start

### Complete Deployment

For the easiest deployment experience, use the complete workflow:

```bash
# Complete automated workflow
deploy-cli workflow 192.168.1.100
```

### Step-by-Step Deployment

```bash
# 1. Check system status and readiness
deploy-cli status 192.168.1.100

# 2. Set up keys and prerequisites (if needed)
deploy-cli setup 192.168.1.100

# 3. Deploy configuration (SOPS always enabled)
deploy-cli deploy 192.168.1.100
```

### Fresh NixOS Installation

For a completely fresh installation:

1. Boot the target machine with a NixOS ISO:
   ```bash
   ./build-iso.sh  # Build the ISO if needed
   ```

2. Copy the ISO to a USB drive and boot from it on the target machine

3. On the target machine, connect to a network:
   ```bash
   nmtui
   ```

4. Find the target machine's IP address:
   ```bash
   ip a
   ```

5. Deploy from your local machine:
   ```bash
   deploy-cli workflow TARGET_IP
   ```

## Installation

### Prerequisites

- A working NixOS installation on your local machine with this configuration deployed
- SSH access to the target machine
- `deploy-rs`, `ssh-to-age`, `age`, `sops`

## Commands

### `status <hostname>`

Check deployment status and system readiness.

```bash
deploy-cli status 192.168.1.100
```

Shows:
- ✓ Systemd status
- ✓ Disk space and memory
- ✓ SSH host key presence
- ✓ SOPS key status
- ✓ Deployment readiness

**Options:**
- `--ssh-user TEXT`: SSH user to connect as
- `--flake-path TEXT`: Path to Nix flake (default: '.')

### `setup <hostname>`

Set up keys and directories for SOPS deployment.

```bash
deploy-cli setup 192.168.1.100
```

This command:
- Generates SSH host key if missing
- Creates SOPS directories with proper permissions
- Converts SSH key to age key for SOPS
- Shows the age key for .sops.yaml configuration

**Options:**
- `--ssh-user TEXT`: SSH user to connect as
- `--flake-path TEXT`: Path to Nix flake (default: '.')
- `--force`: Force key regeneration

### `deploy <hostname> [target]`

Deploy NixOS configuration to target host.

```bash
# Deploy with automatic prerequisite handling
deploy-cli deploy 192.168.1.100

# Custom target
deploy-cli deploy 192.168.1.100 ivy-custom
```

**Arguments:**
- `hostname`: Target hostname or IP address
- `target`: Flake target (default: 'ivy-custom')

**Options:**
- `--ssh-user TEXT`: SSH user to connect as
- `--flake-path TEXT`: Path to Nix flake (default: '.')

### `workflow <hostname>`

Run complete deployment workflow (setup + deploy).

```bash
deploy-cli workflow 192.168.1.100
```

**Options:**
- `--flake-path TEXT`: Path to Nix flake (default: '.')

## Matrix Helpers

### Synapse registration tokens

Use this helper to manage invite-only registration tokens when `registration_requires_token = true`.

```bash
# List tokens
bash tools/synapse_tokens.sh --host http://10.0.0.10:8008 --token <ADMIN_ACCESS_TOKEN> list

# Create a one-time token, 16 chars, valid 7 days
bash tools/synapse_tokens.sh --host http://10.0.0.10:8008 --token <ADMIN_ACCESS_TOKEN> \
  create --uses 1 --length 16 --valid-days 7

# Inspect/delete a token
bash tools/synapse_tokens.sh --host http://10.0.0.10:8008 --token <ADMIN_ACCESS_TOKEN> get <TOKEN>
bash tools/synapse_tokens.sh --host http://10.0.0.10:8008 --token <ADMIN_ACCESS_TOKEN> delete <TOKEN>
```

Notes:
- You need an admin access token. Log in as an admin user and copy the token from the client, or obtain it via the client login API.
- Pretty printing requires `jq`; otherwise raw JSON is printed.
