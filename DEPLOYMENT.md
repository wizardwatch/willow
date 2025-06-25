# NixOS Deployment Guide

This document explains how to deploy your NixOS configurations to different machines using deploy-rs and our custom deployment CLI tool.

## Quick Start with CLI Tool

For the easiest deployment experience, use our Python CLI tool (automatically installed with the NixOS configuration):

```bash
# Complete deployment workflow (recommended for initial deployments)
deploy-cli workflow 192.168.1.100
# Or using the shell wrapper: ./deploy-ivy-cli.sh workflow 192.168.1.100

# Or step by step:
deploy-cli status 192.168.1.100   # Check system readiness
deploy-cli setup 192.168.1.100    # Set up keys
deploy-cli deploy 192.168.1.100   # Deploy configuration
```

See [tools/README.md](tools/README.md) for complete CLI documentation and [CLI-QUICK-REFERENCE.md](CLI-QUICK-REFERENCE.md) for common commands.

## Prerequisites

- A working NixOS installation on your local machine with this configuration deployed
- SSH access to the target machine
- The deployment CLI tool (`deploy-cli`) is automatically installed with the NixOS configuration
- Additional tools are included: `deploy-rs`, `ssh-to-age`, `age`, `sops`

## Deployment Targets

### Ivy Server

The Ivy server can be deployed in several ways:

#### Initial Deployment

For a fresh installation, you have two options:

**Option 1: Using the CLI Tool (Recommended)**

```bash
# Complete automated workflow
deploy-cli workflow TARGET_IP

# Or step by step  
deploy-cli setup TARGET_IP
deploy-cli deploy TARGET_IP

# Alternative: Use shell wrapper for additional environment setup
./deploy-ivy-cli.sh workflow TARGET_IP
```

**Option 2: Manual Process**

1. Boot the target machine with the NixOS ISO:
   ```
   ./build-iso.sh
   ```

2. Copy the ISO to a USB drive and boot from it on the target machine.

3. On the target machine, connect to a network:
   ```
   nmtui
   ```

4. Find the target machine's IP address:
   ```
   ip a
   ```

5. Deploy from your local machine:
   ```
   deploy-cli workflow TARGET_IP
   ```
   
   This automatically handles key setup and deployment with the correct syntax.

#### Regular Deployment

For subsequent deployments after the initial setup:

```
deploy-cli deploy TARGET_IP
```

This automatically handles prerequisites and runs the deployment.

#### Custom Deployment

You can also use deploy-rs commands directly if needed:

```
deploy ".#ivy-custom" --hostname "192.168.1.100" --ssh-user "willow"
```

However, the CLI tool is recommended as it handles prerequisites automatically.

## Deployment Architecture

The deployment system uses several components:

1. **deploy-rs**: Handles the actual deployment process
2. **sops-nix**: Manages encrypted secrets
3. **mkHost function**: Creates standardized NixOS configurations with deployment support

## Troubleshooting

### Using the CLI Tool for Diagnostics

The CLI tool provides excellent diagnostic capabilities:

```bash
# Check system status and identify issues
deploy-cli status TARGET_IP

# Verify key setup  
deploy-cli setup TARGET_IP --force

# Alternative: Use shell wrapper
./deploy-ivy-cli.sh status TARGET_IP
```

### SSH Connection Issues

If you're having trouble connecting via SSH:

1. Verify the target machine's IP address
2. Check that SSH is running on the target machine: `systemctl status sshd`
3. Ensure your SSH key is available to deploy-rs
4. Check the command syntax: deploy-rs expects `--hostname` and `--ssh-user` parameters
5. Make sure your user has the appropriate SSH keys and sudo permissions

### SOPS-Related Issues

If you encounter SOPS decryption errors:

1. Use the CLI to check key status: `deploy-cli status TARGET_IP`
2. Set up keys properly: `deploy-cli setup TARGET_IP`
3. Deploy (keys are handled automatically): `deploy-cli deploy TARGET_IP`

### Deployment Failures

If the deployment fails:

1. Check the error messages from deploy-rs
2. Verify your NixOS configuration builds locally: `nix build .#nixosConfigurations.ivy.config.system.build.toplevel`
3. Try a manual deployment by copying the configuration to the target and running `nixos-rebuild switch`
4. Use the CLI tool's verbose mode: `deploy-cli deploy TARGET_IP --verbose`

## Security Considerations

- After the initial deployment, root login via SSH is prohibited by password
- Deploy-rs uses SSH keys for authentication
- Secrets are managed using sops-nix and age encryption
- The CLI tool solves the SOPS chicken-and-egg problem by ensuring prerequisites before deployment
- SSH host keys are automatically generated and converted to age keys for SOPS
- All secret operations are performed with proper file permissions (600/700)
- SOPS is always enabled - no conditional configuration needed

## Adding New Hosts

To add a new deployment target:

1. Create a host configuration in `hosts/`
2. Add the host to the `hosts` definition in `flake.nix`
3. The CLI tool will automatically work with any host defined in your flake

For example, to deploy to a new host:
```bash
deploy-cli workflow NEW_HOST_IP
deploy-cli deploy NEW_HOST_IP new-host-target

# Or using the shell wrapper:
./deploy-ivy-cli.sh workflow NEW_HOST_IP
```

## Customizing Deployments

The `mkHost` function in `lib/mkHost.nix` accepts a `deployHostname` parameter to override the default hostname for deployment.

## CLI Tool Features

The deployment CLI tool (`deploy-cli`) provides:

- **Automatic Prerequisites**: Ensures SSH keys and SOPS directories exist before deployment
- **Key Management**: Sets up SSH host keys and converts them to age keys
- **System Monitoring**: Comprehensive status checks and health monitoring  
- **Always-On SOPS**: SOPS is always enabled, prerequisites handled automatically
- **Rich Interface**: Beautiful terminal output with progress indicators
- **Flexible Authentication**: Auto-detects whether to use root or user SSH access

See [tools/README.md](tools/README.md) for complete documentation and [CLI-QUICK-REFERENCE.md](CLI-QUICK-REFERENCE.md) for common commands and examples.