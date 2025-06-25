# NixOS Deployment CLI - Quick Reference

A quick reference for the `deploy-cli` tool that handles NixOS deployments with SOPS integration.

## Installation

The CLI tool is automatically installed with this NixOS configuration. After deploying your system:

```bash
deploy-cli --help
```

## Common Commands

### Complete Deployment Workflow (Recommended)
```bash
# One-command deployment for fresh systems
deploy-cli workflow 192.168.1.100

# Using shell wrapper (includes additional environment checks)
./deploy-ivy-cli.sh workflow 192.168.1.100
```

### Step-by-Step Deployment

```bash
# 1. Check system status
deploy-cli status 192.168.1.100

# 2. Set up keys (if needed - or let deploy handle it automatically)
deploy-cli setup 192.168.1.100

# 3. Deploy configuration (SOPS always enabled, prerequisites handled automatically)
deploy-cli deploy 192.168.1.100
```

### Quick Deployment Commands

```bash
# Deploy with SOPS (prerequisites handled automatically)
deploy-cli deploy 192.168.1.100

# Custom target
deploy-cli deploy 192.168.1.100 ivy-custom
```

## Troubleshooting

### Check System Status
```bash
# Comprehensive system health check
deploy-cli status 192.168.1.100
```

Shows:
- ✓ Systemd status
- ✓ Disk space and memory
- ✓ SSH host key presence
- ✓ SOPS key status
- ✓ Deployment readiness

### Fix Key Issues
```bash
# Set up missing keys
deploy-cli setup 192.168.1.100

# Force regenerate all keys
deploy-cli setup 192.168.1.100 --force
```

### SOPS Troubleshooting
```bash
# Ensure keys are set up properly
deploy-cli setup 192.168.1.100

# Deploy (SOPS always enabled, keys handled automatically)
deploy-cli deploy 192.168.1.100
```

## Environment Variables

No special environment variables needed - SOPS is always enabled and prerequisites are handled automatically.

## Shell Wrapper

The shell wrapper (`./deploy-ivy-cli.sh`) provides:
- Environment validation
- Dependency checks
- Enhanced error messages
- Fallback to development mode

```bash
# Use wrapper for additional checks
./deploy-ivy-cli.sh status 192.168.1.100
./deploy-ivy-cli.sh workflow 192.168.1.100
```

## Common Scenarios

### Fresh NixOS Installation
```bash
# Boot target from NixOS ISO, then:
deploy-cli workflow 192.168.1.100
```

### Existing System Update
```bash
# Regular updates (auto-detects SOPS)
deploy-cli deploy 192.168.1.100
```

### SOPS Setup on Existing System
```bash
deploy-cli setup 192.168.1.100
# Copy the displayed age key to .sops.yaml
deploy-cli deploy 192.168.1.100
```

### Debugging Deployment Issues
```bash
deploy-cli status 192.168.1.100         # Check system health
deploy-cli deploy 192.168.1.100 -v      # Verbose output
deploy-cli setup 192.168.1.100 --force  # Force key regeneration
```

## Getting Help

```bash
deploy-cli --help                    # General help
deploy-cli status --help             # Command-specific help
deploy-cli deploy --help             # Deployment options
```

For detailed documentation, see [tools/README.md](tools/README.md).

## Legacy Scripts

Legacy bash scripts have been removed. Use `deploy-cli` for all deployment operations.

## Tips

1. **Always check status first**: `deploy-cli status <host>`
2. **Use workflow for fresh systems**: `deploy-cli workflow <host>`
3. **Simple deployment**: Just use `deploy-cli deploy <host>` - prerequisites handled automatically
4. **SOPS issues? Check keys**: `deploy-cli setup <host>`
5. **Shell wrapper for dev environments**: `./deploy-ivy-cli.sh`
