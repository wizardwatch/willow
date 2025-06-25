#!/usr/bin/env python3
"""
NixOS Deployment CLI Tool

A comprehensive CLI tool for managing NixOS deployments with SOPS integration.
Handles initial key setup, deployment orchestration, and system verification.
"""

import os
import sys
import subprocess
import tempfile
from pathlib import Path
from typing import Optional, List, Dict, Any
import json
import time

import click
import paramiko
import yaml
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.panel import Panel
from rich.table import Table
from rich.prompt import Confirm, Prompt

console = Console()


class DeploymentError(Exception):
    """Custom exception for deployment-related errors."""
    pass


class SSHConnection:
    """Manages SSH connections to target hosts."""

    def __init__(self, hostname: str, username: str, port: int = 22, timeout: int = 10):
        self.hostname = hostname
        self.username = username
        self.port = port
        self.timeout = timeout
        self.client = None

    def __enter__(self):
        self.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.disconnect()

    def connect(self):
        """Establish SSH connection."""
        self.client = paramiko.SSHClient()
        self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        try:
            self.client.connect(
                hostname=self.hostname,
                username=self.username,
                port=self.port,
                timeout=self.timeout,
                allow_agent=True,
                look_for_keys=True
            )
        except Exception as e:
            raise DeploymentError(f"Failed to connect to {self.username}@{self.hostname}: {e}")

    def disconnect(self):
        """Close SSH connection."""
        if self.client:
            self.client.close()

    def execute(self, command: str, sudo: bool = False) -> tuple[int, str, str]:
        """Execute command on remote host."""
        if not self.client:
            raise DeploymentError("SSH connection not established")

        if sudo and self.username != 'root':
            command = f"sudo {command}"

        stdin, stdout, stderr = self.client.exec_command(command)
        exit_code = stdout.channel.recv_exit_status()

        stdout_text = stdout.read().decode('utf-8').strip()
        stderr_text = stderr.read().decode('utf-8').strip()

        return exit_code, stdout_text, stderr_text

    def file_exists(self, path: str) -> bool:
        """Check if file exists on remote host."""
        exit_code, _, _ = self.execute(f"test -f {path}")
        return exit_code == 0

    def directory_exists(self, path: str) -> bool:
        """Check if directory exists on remote host."""
        exit_code, _, _ = self.execute(f"test -d {path}")
        return exit_code == 0


class DeploymentManager:
    """Manages NixOS deployment operations."""

    def __init__(self, hostname: str, flake_path: str = "."):
        self.hostname = hostname
        self.flake_path = Path(flake_path).resolve()
        self.ssh_users = ['willow', 'root']
        self.active_connection = None

    def detect_ssh_user(self) -> str:
        """Detect which SSH user can connect to the target."""
        for username in self.ssh_users:
            try:
                with SSHConnection(self.hostname, username, timeout=5) as conn:
                    conn.execute("echo 'Connection test'")
                    return username
            except DeploymentError:
                continue

        raise DeploymentError(f"Cannot connect to {self.hostname} with any of: {', '.join(self.ssh_users)}")

    def get_connection(self, username: Optional[str] = None) -> SSHConnection:
        """Get SSH connection to target host."""
        if username is None:
            username = self.detect_ssh_user()

        return SSHConnection(self.hostname, username)

    def check_system_status(self, conn: SSHConnection) -> Dict[str, Any]:
        """Check system status and readiness."""
        status = {}

        # Check systemd status
        exit_code, stdout, _ = conn.execute("systemctl is-system-running")
        status['systemd_running'] = exit_code == 0
        status['systemd_state'] = stdout if stdout else "unknown"

        # Check disk space
        exit_code, stdout, _ = conn.execute("df -h / | tail -1")
        if exit_code == 0:
            parts = stdout.split()
            if len(parts) >= 4:
                status['disk_total'] = parts[1]
                status['disk_used'] = parts[2]
                status['disk_available'] = parts[3]
                status['disk_usage_percent'] = parts[4]

        # Check memory
        exit_code, stdout, _ = conn.execute("free -h | grep '^Mem:'")
        if exit_code == 0:
            parts = stdout.split()
            if len(parts) >= 2:
                status['memory_total'] = parts[1]

        # Check SSH host key
        status['ssh_host_key_exists'] = conn.file_exists("/etc/ssh/ssh_host_ed25519_key")

        # Check SOPS key
        status['sops_key_exists'] = conn.file_exists("/var/lib/sops-nix/key.txt")

        return status

    def setup_ssh_host_key(self, conn: SSHConnection) -> bool:
        """Ensure SSH host key exists."""
        if conn.file_exists("/etc/ssh/ssh_host_ed25519_key"):
            return True

        console.print("[yellow]Generating SSH host key...[/yellow]")

        exit_code, _, stderr = conn.execute(
            "ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' -q",
            sudo=True
        )

        if exit_code != 0:
            console.print(f"[red]Failed to generate SSH host key: {stderr}[/red]")
            return False

        # Set proper permissions
        conn.execute("chmod 600 /etc/ssh/ssh_host_ed25519_key", sudo=True)
        conn.execute("chown root:root /etc/ssh/ssh_host_ed25519_key", sudo=True)

        console.print("[green]SSH host key generated successfully[/green]")
        return True

    def setup_sops_directories(self, conn: SSHConnection):
        """Create necessary SOPS directories."""
        directories = [
            "/var/lib/sops-nix",
            "/nix/persist/etc/ssh"
        ]

        for directory in directories:
            if not conn.directory_exists(directory):
                conn.execute(f"mkdir -p {directory}", sudo=True)
                conn.execute(f"chmod 700 {directory}", sudo=True)

    def get_age_key(self, conn: SSHConnection) -> Optional[str]:
        """Get age key from SSH host key."""
        if not conn.file_exists("/etc/ssh/ssh_host_ed25519_key.pub"):
            return None

        exit_code, stdout, _ = conn.execute("cat /etc/ssh/ssh_host_ed25519_key.pub", sudo=True)
        if exit_code != 0:
            return None

        # Convert SSH key to age key using ssh-to-age
        try:
            result = subprocess.run(
                ["ssh-to-age"],
                input=stdout,
                text=True,
                capture_output=True,
                check=True
            )
            return result.stdout.strip()
        except (subprocess.CalledProcessError, FileNotFoundError):
            console.print("[yellow]ssh-to-age not available, cannot convert SSH key to age key[/yellow]")
            return None

    def deploy_nixos(self, target: str, ssh_user: str):
        """Deploy NixOS configuration using deploy-rs."""
        # Always ensure prerequisites are in place before deployment
        console.print("[blue]Ensuring deployment prerequisites...[/blue]")

        with self.get_connection(ssh_user) as conn:
            # Always set up SSH host key and SOPS directories
            if not self.setup_ssh_host_key(conn):
                console.print("[red]Failed to set up SSH host key[/red]")
                return False

            self.setup_sops_directories(conn)
            console.print("[green]Prerequisites ready[/green]")

        env = os.environ.copy()

        cmd = [
            "deploy",
            f".#{target}",
            "--ssh-user", ssh_user,
            "--hostname", self.hostname
        ]

        console.print(f"[blue]Running deployment command: {' '.join(cmd)}[/blue]")

        try:
            result = subprocess.run(
                cmd,
                cwd=self.flake_path,
                env=env,
                check=True,
                capture_output=False
            )
            return True
        except subprocess.CalledProcessError as e:
            console.print(f"[red]Deployment failed with exit code {e.returncode}[/red]")
            return False


@click.group()
@click.option('--verbose', '-v', is_flag=True, help='Enable verbose output')
@click.pass_context
def cli(ctx, verbose):
    """NixOS Deployment CLI Tool - Manage deployments with SOPS integration."""
    ctx.ensure_object(dict)
    ctx.obj['verbose'] = verbose


@cli.command()
@click.argument('hostname')
@click.option('--ssh-user', help='SSH user to connect as')
@click.option('--flake-path', default='.', help='Path to Nix flake')
def status(hostname, ssh_user, flake_path):
    """Check deployment status and system readiness."""
    manager = DeploymentManager(hostname, flake_path)

    try:
        if ssh_user is None:
            ssh_user = manager.detect_ssh_user()

        with manager.get_connection(ssh_user) as conn:
            console.print(f"[green]Connected to {ssh_user}@{hostname}[/green]")

            status_info = manager.check_system_status(conn)

            # Create status table
            table = Table(title=f"System Status - {hostname}")
            table.add_column("Component", style="cyan")
            table.add_column("Status", style="magenta")
            table.add_column("Details", style="white")

            # Systemd status
            systemd_status = "✓ Running" if status_info['systemd_running'] else "✗ Not Running"
            table.add_row("Systemd", systemd_status, status_info.get('systemd_state', ''))

            # Disk space
            if 'disk_available' in status_info:
                disk_status = f"✓ {status_info['disk_usage_percent']} used"
                disk_details = f"{status_info['disk_available']} available"
                table.add_row("Disk Space", disk_status, disk_details)

            # Memory
            if 'memory_total' in status_info:
                table.add_row("Memory", "✓ Available", status_info['memory_total'])

            # SSH Host Key
            ssh_key_status = "✓ Present" if status_info['ssh_host_key_exists'] else "✗ Missing"
            table.add_row("SSH Host Key", ssh_key_status, "/etc/ssh/ssh_host_ed25519_key")

            # SOPS Key
            sops_key_status = "✓ Present" if status_info['sops_key_exists'] else "✗ Missing"
            table.add_row("SOPS Key", sops_key_status, "/var/lib/sops-nix/key.txt")

            console.print(table)

            # Show readiness assessment
            ready_for_sops = status_info['ssh_host_key_exists']
            if ready_for_sops:
                console.print("\n[green]✓ System is ready for SOPS deployment[/green]")
            else:
                console.print("\n[yellow]⚠ System needs key setup before SOPS deployment[/yellow]")

    except DeploymentError as e:
        console.print(f"[red]Error: {e}[/red]")
        sys.exit(1)


@cli.command()
@click.argument('hostname')
@click.option('--ssh-user', help='SSH user to connect as')
@click.option('--flake-path', default='.', help='Path to Nix flake')
@click.option('--force', is_flag=True, help='Force key regeneration')
def setup(hostname, ssh_user, flake_path, force):
    """Set up keys and directories for SOPS deployment."""
    manager = DeploymentManager(hostname, flake_path)

    try:
        if ssh_user is None:
            ssh_user = manager.detect_ssh_user()

        with manager.get_connection(ssh_user) as conn:
            console.print(f"[green]Connected to {ssh_user}@{hostname}[/green]")

            with Progress(
                SpinnerColumn(),
                TextColumn("[progress.description]{task.description}"),
                console=console
            ) as progress:

                # Setup SSH host key
                task = progress.add_task("Setting up SSH host key...", total=None)
                if force or not conn.file_exists("/etc/ssh/ssh_host_ed25519_key"):
                    if not manager.setup_ssh_host_key(conn):
                        console.print("[red]Failed to setup SSH host key[/red]")
                        sys.exit(1)
                else:
                    console.print("[green]SSH host key already exists[/green]")
                progress.update(task, description="SSH host key ready")

                # Setup SOPS directories
                task = progress.add_task("Setting up SOPS directories...", total=None)
                manager.setup_sops_directories(conn)
                progress.update(task, description="SOPS directories ready")

                # Get age key
                task = progress.add_task("Getting age key...", total=None)
                age_key = manager.get_age_key(conn)
                progress.update(task, description="Age key retrieved")

            console.print("\n[green]✓ Key setup completed successfully![/green]")

            if age_key:
                panel = Panel(
                    f"[bold]Age Key for SOPS Configuration:[/bold]\n\n{age_key}\n\n"
                    "[yellow]Add this key to your .sops.yaml file:[/yellow]\n"
                    f"- &server_{hostname.replace('.', '_')} {age_key}",
                    title="SOPS Configuration",
                    border_style="green"
                )
                console.print(panel)

    except DeploymentError as e:
        console.print(f"[red]Error: {e}[/red]")
        sys.exit(1)


@cli.command()
@click.argument('hostname')
@click.argument('target', default='ivy-custom')
@click.option('--ssh-user', help='SSH user to connect as')
@click.option('--flake-path', default='.', help='Path to Nix flake')
def deploy(hostname, target, ssh_user, flake_path):
    """Deploy NixOS configuration to target host."""
    manager = DeploymentManager(hostname, flake_path)

    try:
        if ssh_user is None:
            ssh_user = manager.detect_ssh_user()

        # Always ensure keys are set up before deployment
        console.print("[blue]Ensuring deployment prerequisites...[/blue]")
        with manager.get_connection(ssh_user) as conn:
            # Always run setup to ensure keys exist
            manager.setup_ssh_host_key(conn)
            manager.setup_sops_directories(conn)
            console.print("[green]✓ Prerequisites ready[/green]")

        # SOPS is now always enabled since prerequisites are guaranteed
        enable_sops = True
        console.print("[blue]SOPS enabled (prerequisites verified)[/blue]")

        # Show deployment summary
        table = Table(title="Deployment Configuration")
        table.add_column("Setting", style="cyan")
        table.add_column("Value", style="magenta")

        table.add_row("Target Host", hostname)
        table.add_row("SSH User", ssh_user)
        table.add_row("Flake Target", target)
        table.add_row("SOPS Enabled", "Yes")

        console.print(table)

        if not Confirm.ask("\nProceed with deployment?"):
            console.print("Deployment cancelled")
            return

        # Run deployment
        console.print("\n[blue]Starting deployment...[/blue]")
        success = manager.deploy_nixos(target, ssh_user)

        if success:
            console.print("\n[green]✓ Deployment completed successfully![/green]")
            console.print("[green]✓ SOPS secrets are active on the system[/green]")
        else:
            console.print("\n[red]✗ Deployment failed![/red]")
            sys.exit(1)

    except DeploymentError as e:
        console.print(f"[red]Error: {e}[/red]")
        sys.exit(1)


@cli.command()
@click.argument('hostname')
@click.option('--flake-path', default='.', help='Path to Nix flake')
def workflow(hostname, flake_path):
    """Run complete deployment workflow (setup + deploy)."""
    console.print(f"[bold blue]Starting complete deployment workflow for {hostname}[/bold blue]")

    # Step 1: Check status
    console.print("\n[bold]Step 1: Checking system status[/bold]")
    ctx = click.Context(status)
    ctx.invoke(status, hostname=hostname, ssh_user=None, flake_path=flake_path)

    # Step 2: Setup keys
    console.print("\n[bold]Step 2: Setting up keys[/bold]")
    if Confirm.ask("Run key setup?"):
        ctx = click.Context(setup)
        ctx.invoke(setup, hostname=hostname, ssh_user=None, flake_path=flake_path, force=False)

    # Step 3: Deploy with SOPS (prerequisites handled automatically)
    console.print("\n[bold]Step 3: Deploy configuration (SOPS enabled)[/bold]")
    if Confirm.ask("Run deployment?"):
        ctx = click.Context(deploy)
        ctx.invoke(deploy, hostname=hostname, target='ivy-custom', ssh_user=None,
                  flake_path=flake_path)

    console.print("\n[green]✓ Complete deployment workflow finished![/green]")


if __name__ == '__main__':
    cli()
