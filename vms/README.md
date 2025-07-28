# MicroVM Setup

This directory contains the configuration for microvms running on the ivy host. The setup uses the [microvm.nix](https://github.com/astro/microvm.nix) project to create lightweight virtual machines.

## Architecture

```
Host (ivy)
├── Bridge Network (br0: 10.0.0.1/24)
├── Matrix VM (10.0.0.10)
│   ├── Matrix Synapse homeserver
│   └── PostgreSQL database
└── Traefik VM (10.0.0.20)
    ├── Traefik reverse proxy
    ├── Matrix routing
    └── Well-known endpoints
```

## VMs

### Matrix VM (10.0.0.10)
- **Purpose**: Matrix Synapse homeserver
- **Resources**: 2 vCPU, 2GB RAM, 8GB storage
- **Services**: 
  - Matrix Synapse (port 8008)
  - PostgreSQL database
  - SSH (port 22)
- **Configuration**: `matrix/`

### Traefik VM (10.0.0.20)
- **Purpose**: Reverse proxy and load balancer
- **Resources**: 1 vCPU, 1GB RAM, 4GB storage
- **Services**:
  - Traefik (ports 80, 443, 8080)
  - Matrix well-known endpoints
  - SSH (port 22)
- **Configuration**: `traefik/`

## Files

- `main.nix` - Main microvm host configuration
- `matrix/` - Matrix VM configuration
  - `default.nix` - VM system configuration
  - `matrix.nix` - Matrix Synapse configuration
- `traefik/` - Traefik VM configuration
  - `default.nix` - VM system configuration
  - `traefik.nix` - Traefik proxy configuration
  - `matrix-route.nix` - Matrix routing rules

## Management

Use the management script for common operations:

```bash
# Initial setup
./tools/microvm-manage.sh setup

# Start VMs
./tools/microvm-manage.sh start matrix
./tools/microvm-manage.sh start traefik

# Check status
./tools/microvm-manage.sh status

# View logs
./tools/microvm-manage.sh logs matrix

# Deploy configuration
./tools/microvm-manage.sh deploy
```

## Manual Commands

### Start VMs
```bash
sudo systemctl start microvm@matrix.service
sudo systemctl start microvm@traefik.service
```

### Stop VMs
```bash
sudo systemctl stop microvm@matrix.service
sudo systemctl stop microvm@traefik.service
```

### Check VM status
```bash
systemctl status microvm@matrix.service
systemctl status microvm@traefik.service
```

### View logs
```bash
journalctl -u microvm@matrix.service -f
journalctl -u microvm@traefik.service -f
```

## Network Configuration

The VMs communicate over a bridge network:

- **Host**: 10.0.0.1/24 (bridge br0)
- **Matrix**: 10.0.0.10/24
- **Traefik**: 10.0.0.20/24

### Access URLs

- **Traefik Dashboard**: http://ivy.local:8080/dashboard/
- **Matrix API**: http://matrix.ivy.local/_matrix/client/versions
- **Matrix Well-known**: http://ivy.local/.well-known/matrix/server

### Port Forwarding

Traffic flow:
```
Internet → ivy.local:80 → Traefik VM (10.0.0.20:80)
Traefik VM → matrix.ivy.local → Matrix VM (10.0.0.10:8008)
```

## Storage

VMs use image files stored in `/var/lib/microvms/`:

- `/var/lib/microvms/matrix/rootfs.img` - Matrix VM root filesystem
- `/var/lib/microvms/traefik/rootfs.img` - Traefik VM root filesystem

The Nix store is shared read-only from the host via virtiofs.

## Building and Deployment

### Local Build
```bash
cd /etc/nixos
sudo nixos-rebuild build --flake .#ivy
```

### Deploy to ivy
```bash
# From remote host
deploy .#ivy-custom --hostname ivy.local --ssh-user willow

# Or using management script
./tools/microvm-manage.sh deploy
```

### Rebuild VMs
After configuration changes, rebuild and restart:

```bash
sudo nixos-rebuild switch --flake .#ivy
sudo systemctl restart microvm@matrix.service
sudo systemctl restart microvm@traefik.service
```

## Troubleshooting

### VM won't start
1. Check host bridge network: `ip addr show br0`
2. Check systemd service: `systemctl status microvm@matrix.service`
3. Check logs: `journalctl -u microvm@matrix.service`

### Network issues
1. Test VM connectivity: `ping 10.0.0.10`
2. Check bridge configuration: `./tools/microvm-manage.sh network`
3. Verify IP forwarding: `sysctl net.ipv4.ip_forward`

### Service not responding
1. Check if VM is running: `./tools/microvm-manage.sh status`
2. Test service port: `nc -z 10.0.0.10 8008`
3. Check VM logs: `./tools/microvm-manage.sh logs matrix`

### Clean restart
```bash
# Stop all VMs
sudo systemctl stop microvm@*.service

# Clean up
./tools/microvm-manage.sh cleanup

# Restart
sudo systemctl start microvm@matrix.service
sudo systemctl start microvm@traefik.service
```

## Security Notes

- VMs run in isolated network (10.0.0.0/24)
- No direct internet access (NAT through host)
- SSH access available but password auth disabled
- Services only accessible through Traefik proxy

## Performance

- Matrix VM: Optimized for Matrix Synapse workload
- Traefik VM: Lightweight proxy with minimal resources
- Shared Nix store reduces storage overhead
- Bridge networking provides good performance

## Future Improvements

- Add SSL/TLS termination in Traefik
- Implement backup scripts for VM data
- Add monitoring and alerting
- Consider adding more VMs (e.g., database, monitoring)
- Implement automated VM provisioning