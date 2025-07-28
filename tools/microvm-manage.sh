#!/usr/bin/env bash

# MicroVM Management Script for NixOS
# This script helps manage microvms on the ivy host

set -euo pipefail

# Configuration
MICROVM_BASE_DIR="/var/lib/microvms"
BRIDGE_NAME="br0"
BRIDGE_IP="10.0.0.1/24"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Help function
show_help() {
    cat << EOF
MicroVM Management Script

Usage: $0 <command> [options]

Commands:
    setup           - Initial setup for microvm host
    start <vm>      - Start a specific microvm
    stop <vm>       - Stop a specific microvm
    restart <vm>    - Restart a specific microvm
    status          - Show status of all microvms
    logs <vm>       - Show logs for a specific microvm
    console <vm>    - Connect to microvm console
    list            - List all available microvms
    build           - Rebuild NixOS configuration
    deploy          - Deploy configuration to ivy host
    cleanup         - Clean up stopped microvms
    network         - Show network configuration
    help            - Show this help message

Available VMs:
    matrix          - Matrix Synapse homeserver
    traefik         - Traefik reverse proxy

Examples:
    $0 setup                    # Initial host setup
    $0 start matrix            # Start matrix microvm
    $0 status                   # Show all VM status
    $0 logs traefik            # Show traefik logs
    $0 build                    # Rebuild configuration
    $0 deploy                   # Deploy to ivy host

EOF
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root"
        exit 1
    fi
}

# Setup host for microvms
setup_host() {
    log "Setting up host for microvms..."

    # Create bridge if it doesn't exist
    if ! ip link show "$BRIDGE_NAME" &>/dev/null; then
        log "Creating bridge $BRIDGE_NAME"
        sudo ip link add name "$BRIDGE_NAME" type bridge
        sudo ip addr add "$BRIDGE_IP" dev "$BRIDGE_NAME"
        sudo ip link set "$BRIDGE_NAME" up
    else
        log "Bridge $BRIDGE_NAME already exists"
    fi

    # Enable IP forwarding
    log "Enabling IP forwarding"
    echo 'net.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/99-microvm.conf
    sudo sysctl -p /etc/sysctl.d/99-microvm.conf

    # Create microvm directories
    log "Creating microvm directories"
    sudo mkdir -p "$MICROVM_BASE_DIR"/{matrix,traefik}
    sudo chown -R root:root "$MICROVM_BASE_DIR"

    # Create iptables rules for NAT
    log "Setting up NAT rules"
    sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 ! -d 10.0.0.0/24 -j MASQUERADE || true
    sudo iptables -A FORWARD -i "$BRIDGE_NAME" -o "$BRIDGE_NAME" -j ACCEPT || true

    log "Host setup completed"
}

# Start a microvm
start_vm() {
    local vm_name="$1"
    log "Starting microvm: $vm_name"
    sudo systemctl start "microvm@$vm_name.service"
    sudo systemctl enable "microvm@$vm_name.service"
}

# Stop a microvm
stop_vm() {
    local vm_name="$1"
    log "Stopping microvm: $vm_name"
    sudo systemctl stop "microvm@$vm_name.service"
}

# Restart a microvm
restart_vm() {
    local vm_name="$1"
    log "Restarting microvm: $vm_name"
    sudo systemctl restart "microvm@$vm_name.service"
}

# Show status of all microvms
show_status() {
    log "MicroVM Status:"
    echo

    for vm in matrix traefik; do
        if systemctl is-active --quiet "microvm@$vm.service" 2>/dev/null; then
            echo -e "  $vm: ${GREEN}running${NC}"

            # Try to ping the VM
            case $vm in
                matrix)
                    ip="10.0.0.10"
                    port="8008"
                    ;;
                traefik)
                    ip="10.0.0.20"
                    port="80"
                    ;;
            esac

            if ping -c 1 -W 1 "$ip" &>/dev/null; then
                echo -e "    Network: ${GREEN}reachable${NC} ($ip)"
            else
                echo -e "    Network: ${RED}unreachable${NC} ($ip)"
            fi

            if nc -z "$ip" "$port" 2>/dev/null; then
                echo -e "    Service: ${GREEN}listening${NC} (port $port)"
            else
                echo -e "    Service: ${RED}not listening${NC} (port $port)"
            fi
        else
            echo -e "  $vm: ${RED}stopped${NC}"
        fi
        echo
    done
}

# Show logs for a microvm
show_logs() {
    local vm_name="$1"
    log "Showing logs for microvm: $vm_name"
    sudo journalctl -u "microvm@$vm_name.service" -f
}

# Connect to microvm console
connect_console() {
    local vm_name="$1"
    log "Connecting to console for microvm: $vm_name"
    warn "Use Ctrl+A, X to exit QEMU monitor"
    sudo microvm console "$vm_name"
}

# List available microvms
list_vms() {
    log "Available microvms:"
    echo "  - matrix  (Matrix Synapse homeserver - 10.0.0.10:8008)"
    echo "  - traefik (Traefik reverse proxy - 10.0.0.20:80)"
}

# Build NixOS configuration
build_config() {
    log "Building NixOS configuration..."
    cd "$(dirname "$0")/.."
    sudo nixos-rebuild build --flake .#ivy
    log "Build completed"
}

# Deploy configuration
deploy_config() {
    log "Deploying configuration to ivy host..."
    cd "$(dirname "$0")/.."

    # Check if we're already on ivy
    if [[ "$(hostname)" == "ivy" ]]; then
        log "Running on ivy host, switching configuration..."
        sudo nixos-rebuild switch --flake .#ivy
    else
        log "Deploying from remote host..."
        deploy .#ivy-custom --hostname ivy.local --ssh-user willow
    fi

    log "Deployment completed"
}

# Cleanup stopped microvms
cleanup() {
    log "Cleaning up stopped microvms..."

    for vm in matrix traefik; do
        if ! systemctl is-active --quiet "microvm@$vm.service" 2>/dev/null; then
            log "Cleaning up $vm..."
            sudo rm -rf "$MICROVM_BASE_DIR/$vm"/*.pid 2>/dev/null || true
            sudo rm -rf "$MICROVM_BASE_DIR/$vm"/*.sock 2>/dev/null || true
        fi
    done

    log "Cleanup completed"
}

# Show network configuration
show_network() {
    log "Network Configuration:"
    echo

    # Show bridge information
    echo "Bridge Information:"
    ip addr show "$BRIDGE_NAME" 2>/dev/null || echo "Bridge $BRIDGE_NAME not found"
    echo

    # Show IP forwarding status
    echo "IP Forwarding:"
    sysctl net.ipv4.ip_forward
    echo

    # Show NAT rules
    echo "NAT Rules:"
    sudo iptables -t nat -L POSTROUTING -n | grep "10.0.0.0/24" || echo "No NAT rules found"
    echo

    # Show microvm network connectivity
    echo "VM Network Test:"
    for vm in matrix traefik; do
        case $vm in
            matrix) ip="10.0.0.10" ;;
            traefik) ip="10.0.0.20" ;;
        esac

        if ping -c 1 -W 1 "$ip" &>/dev/null; then
            echo -e "  $vm ($ip): ${GREEN}reachable${NC}"
        else
            echo -e "  $vm ($ip): ${RED}unreachable${NC}"
        fi
    done
}

# Validate VM name
validate_vm() {
    local vm_name="$1"
    case "$vm_name" in
        matrix|traefik)
            return 0
            ;;
        *)
            error "Invalid VM name: $vm_name"
            error "Valid VMs: matrix, traefik"
            exit 1
            ;;
    esac
}

# Main function
main() {
    check_root

    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi

    case "$1" in
        setup)
            setup_host
            ;;
        start)
            if [[ $# -ne 2 ]]; then
                error "Usage: $0 start <vm_name>"
                exit 1
            fi
            validate_vm "$2"
            start_vm "$2"
            ;;
        stop)
            if [[ $# -ne 2 ]]; then
                error "Usage: $0 stop <vm_name>"
                exit 1
            fi
            validate_vm "$2"
            stop_vm "$2"
            ;;
        restart)
            if [[ $# -ne 2 ]]; then
                error "Usage: $0 restart <vm_name>"
                exit 1
            fi
            validate_vm "$2"
            restart_vm "$2"
            ;;
        status)
            show_status
            ;;
        logs)
            if [[ $# -ne 2 ]]; then
                error "Usage: $0 logs <vm_name>"
                exit 1
            fi
            validate_vm "$2"
            show_logs "$2"
            ;;
        console)
            if [[ $# -ne 2 ]]; then
                error "Usage: $0 console <vm_name>"
                exit 1
            fi
            validate_vm "$2"
            connect_console "$2"
            ;;
        list)
            list_vms
            ;;
        build)
            build_config
            ;;
        deploy)
            deploy_config
            ;;
        cleanup)
            cleanup
            ;;
        network)
            show_network
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
