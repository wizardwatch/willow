# MicroVM Setup

This directory contains the configuration for microvms running on the ivy host. The setup uses the [microvm.nix](https://github.com/astro/microvm.nix) project to create lightweight virtual machines.

## Architecture

```
Host (ivy)
├── Bridge Network (br0: 10.0.0.1/24)
├── Matrix VM (10.0.0.10)
│   ├── Matrix Synapse homeserver
│   └── PostgreSQL database
├── Element VM (10.0.0.11)
│   └── Element Web (served by Caddy)
└── Traefik (runs on host)
    ├── Traefik reverse proxy
    ├── Matrix routing (dynamic files)
    └── Well-known endpoints (served via Caddy on host)
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

### Element VM (10.0.0.11)
- **Purpose**: Serve Element Web static client
- **Resources**: 1 vCPU, 1.5GB RAM, 4GB storage
- **Services**:
  - Caddy (port 8082) serving Element Web
  - SSH (port 22)
- **Configuration**: `element/`

### Traefik (host)
- **Purpose**: Reverse proxy and load balancer running on the host
- **Services**:
  - Traefik (ports 80, 443, 8080)
  - Caddy (localhost:8081) for well-known endpoints
- **Configuration**: `vms/traefik.nix` and `vms/matrix/matrix-route.nix`

## Files

- `main.nix` - Main microvm host configuration
- `matrix/` - Matrix VM configuration
  - `default.nix` - VM system configuration
  - `matrix.nix` - Matrix Synapse configuration
- `traefik.nix` - Traefik proxy configuration (host)
- `matrix/matrix-route.nix` - Matrix routing rules + well-known service (host)
- `element/element-route.nix` - Element Web routing rules (host)

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
Internet → host:80/443 → Traefik (host)
Traefik (host) → matrix route → Matrix VM (10.0.0.10:8008)
Traefik (host) → element route → Element VM (10.0.0.11:8082)
```

## Storage

VMs use image files stored in `/home/microvms/`.

- Example: `/home/microvms/matrix/rootfs.img` (Matrix VM root filesystem)
- The Nix store is shared read-only from the host via virtiofs.

### Ownership and permissions

- A dedicated system user/group `vmm` manages the storage path:
  - Base dir: `/home/microvms` (0750 `vmm:vmm`)
  - Per-VM dirs: `/home/microvms/{matrix,element,foundry}` (0750 `vmm:vmm`)

### Persistence

- If your system uses an impermanent root, persist the storage path. With the
  impermanence module, add:

  ```nix
  environment.persistence."/persist".directories = [
    "/home/microvms"
  ];
  ```

- Alternatively, mount a dedicated dataset/partition at `/home/microvms`.

### Backups and monitoring

- Include `/home/microvms` in your backup plan and disk space monitoring.

### Migration from previous path

If you previously stored images under `/var/lib/microvms`, stop the VMs, move the files, and start them again:

```bash
sudo systemctl stop microvm@matrix microvm@element microvm@foundry
sudo mkdir -p /home/microvms/{matrix,element,foundry}
sudo rsync -avh --progress /var/lib/microvms/ /home/microvms/
sudo chown -R vmm:vmm /home/microvms
sudo systemctl start microvm@matrix microvm@element microvm@foundry
```

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
