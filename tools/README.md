# NixOS Deployment CLI Tool

A comprehensive Python CLI tool for managing NixOS deployments with SOPS integration. This tool handles the chicken-and-egg problem of deploying SOPS-encrypted secrets to fresh NixOS installations.

## Features

- **Smart SOPS Detection**: Automatically detects whether SOPS should be enabled based on system state
- **Key Management**: Sets up SSH host keys and SOPS age keys automatically
- **Automatic Prerequisites**: Ensures SSH keys and SOPS directories exist before deployment
- **Rich CLI Interface**: Beautiful terminal output with progress indicators and status tables
- **Flexible Connection**: Auto-detects SSH user (root or willow) for connection
- **System Status Monitoring**: Comprehensive system health checks

## Installation

### Using NixOS Configuration (Recommended)

The CLI tool is automatically installed as part of the common system packages. After deploying your NixOS configuration, the tool will be available system-wide:

```bash
# Available on all systems after NixOS rebuild
deploy-cli --help
```

### Using the Shell Wrapper

For easier usage with additional environment setup:

```bash
# Use the wrapper (automatically executable)
./deploy-ivy-cli.sh status 192.168.1.100
```

### Python Development Setup

For development or if you prefer Python directly:

```bash
cd tools/
# Use nix-shell for dependencies
nix-shell -p python3Packages.click python3Packages.paramiko python3Packages.rich python3Packages.cryptography python3Packages.pyyaml python3Packages.colorama
python deploy_cli.py --help
```

## Usage

### Quick Start

The easiest way to deploy a fresh NixOS system:

```bash
# Using the shell wrapper
./deploy-ivy-cli.sh workflow 192.168.1.100

# Or directly (if installed via NixOS configuration)
deploy-cli workflow 192.168.1.100
```

This runs the complete workflow:
1. Check system status
2. Set up keys
3. Deploy without SOPS
4. Deploy with SOPS enabled

### Individual Commands

#### Check System Status

```bash
./deploy-ivy-cli.sh status 192.168.1.100
```

Shows:
- Systemd status
- Disk space and memory
- SSH host key presence
- SOPS key status
- Deployment readiness

#### Set Up Keys

```bash
./deploy-ivy-cli.sh setup 192.168.1.100
```

This command:
- Generates SSH host key if missing
- Creates SOPS directories
- Converts SSH key to age key for SOPS
- Shows the age key for .sops.yaml configuration

#### Deploy Configuration

```bash
# Deploy with automatic prerequisite handling
deploy-cli deploy 192.168.1.100
# or: ./deploy-ivy-cli.sh deploy 192.168.1.100

# Custom target
deploy-cli deploy 192.168.1.100 ivy-custom
# or: ./deploy-ivy-cli.sh deploy 192.168.1.100 ivy-custom
```

### Direct CLI Usage

```bash
# Check status
deploy-cli status 192.168.1.100

# Set up keys
deploy-cli setup 192.168.1.100

# Deploy with options
deploy-cli deploy 192.168.1.100 ivy-custom --enable-sops

# Complete workflow
deploy-cli workflow 192.168.1.100
```

## Command Reference

### Global Options

- `--verbose, -v`: Enable verbose output
- `--help`: Show help message

### Commands

#### `status <hostname>`

Check deployment status and system readiness.

**Options:**
- `--ssh-user TEXT`: SSH user to connect as
- `--flake-path TEXT`: Path to Nix flake (default: '.')

#### `setup <hostname>`

Set up keys and directories for SOPS deployment.

**Options:**
- `--ssh-user TEXT`: SSH user to connect as
- `--flake-path TEXT`: Path to Nix flake (default: '.')
- `--force`: Force key regeneration

#### `deploy <hostname> [target]`

Deploy NixOS configuration to target host.

**Arguments:**
- `hostname`: Target hostname or IP address
- `target`: Flake target (default: 'ivy-custom')

**Options:**
- `--ssh-user TEXT`: SSH user to connect as
- `--flake-path TEXT`: Path to Nix flake (default: '.')

#### `workflow <hostname>`

Run complete deployment workflow (setup + deploy).

**Options:**
- `--flake-path TEXT`: Path to Nix flake (default: '.')

## Environment Variables

No special environment variables are needed - SOPS is always enabled and prerequisites are handled automatically by the CLI tool.

## Dependencies

### Required

- Python 3.8+
- SSH access to target host
- Nix with flakes enabled

### Python Packages (Handled by Nix)

- `click`: CLI framework
- `paramiko`: SSH client
- `cryptography`: Cryptographic operations
- `pyyaml`: YAML parsing
- `colorama`: Cross-platform colored terminal text
- `rich`: Rich text and beautiful formatting

All dependencies are automatically managed by the Nix derivation.

### External Tools

- `deploy-rs`: NixOS deployment tool
- `ssh-to-age`: Convert SSH keys to age keys (optional)

## Troubleshooting

### Connection Issues

If you can't connect to the target host:

1. Verify the IP address is correct
2. Check that SSH is running on the target
3. Ensure your SSH key is authorized
4. Try connecting manually: `ssh user@hostname`

### SOPS Issues

If SOPS secrets fail to decrypt:

1. Run `setup` command to ensure keys are present
2. Check that the age key is in your `.sops.yaml`
3. Re-encrypt secrets with the new key: `sops updatekeys secret.yaml`
4. Verify the SSH host key exists: `/etc/ssh/ssh_host_ed25519_key`

### Deployment Failures

If deployment fails:

1. Check the error message from deploy-rs
2. Verify your configuration builds locally: `nix build .#nixosConfigurations.ivy`
3. Try deploying without SOPS first: `--disable-sops`
4. Check system logs on target: `journalctl -f`

### Python Dependencies

If developing outside of NixOS:

```bash
# Use nix-shell for development
nix-shell -p python3Packages.click python3Packages.paramiko python3Packages.rich python3Packages.cryptography python3Packages.pyyaml python3Packages.colorama
```

## Development

### Adding New Features

1. Modify `deploy_cli.py`
2. Update requirements if needed
3. Test with the shell wrapper
4. Update this README

### Testing

```bash
# Test with a local VM
./deploy-ivy-cli.sh status localhost

# Test individual functions
python -c "from deploy_cli import DeploymentManager; print('Import successful')"
```

### Building

The tool is built automatically as part of the NixOS system packages. To test the derivation:

```bash
# Test building the derivation
nix-build -E 'with import <nixpkgs> {}; callPackage ./tools {}'
```

## Architecture

The CLI tool consists of several components:

- **SSHConnection**: Manages SSH connections and command execution
- **DeploymentManager**: Orchestrates deployment operations
- **CLI Commands**: Click-based command interface
- **Shell Wrapper**: Provides easy access with Nix environment setup

The tool follows a prerequisite-first deployment process:

1. **Prerequisite Setup**: Ensure SSH host keys and SOPS directories exist
2. **SOPS Deployment**: Deploy with SOPS always enabled (prerequisites guaranteed)

This solves the chicken-and-egg problem by ensuring all required keys and directories exist before running deploy-rs.

## Contributing

1. Follow Python best practices
2. Use type hints where possible
3. Add docstrings to new functions
4. Test with real deployments
5. Update documentation

## License

MIT License - see the main project LICENSE file.