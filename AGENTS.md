# Repository Guidelines

## Project Structure & Module Organization
- Root flake: `flake.nix` defines inputs, hosts, and deploy targets.
- Hosts: `hosts/<name>/{default.nix,configuration.nix,hardware.nix}` (e.g., `hosts/willow`).
- Modules: `modules/{common,desktop,services,virtualization}` and top-level `modules/*.nix`.
- Users: `users/{system,willow}` aggregated via `users/default.nix`.
- Library: `lib/mkHost.nix` for host wiring.
- Tools: `tools/deploy_cli.py` (+ `tools/README.md`) and `build-iso.sh`.
- VMs: `vms/` contains service-specific VM configs and docs.

## VM Storage & Persistence
- Current state: VM images are stored in a non‑persistent location and may be lost on reboot.
- Action item: move VM images to a persistent path (e.g., `/var/lib/vms` or a service account home) and update modules/docs accordingly.
- Considerations: ensure correct ownership/permissions, sufficient disk space/quota, and include the path in backups/monitoring.

## Build, Test, and Development Commands
- Build + switch locally: `sudo nixos-rebuild switch --flake .#<host>` (e.g., `.#willow`).
- Dry build system: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
- Flake checks: `nix flake check` (includes deploy-rs checks).
- Build minimal ISO: `./build-iso.sh` (or `./build-iso.sh --usb /dev/sdX`).
- Deploy helper: `python tools/deploy_cli.py workflow <ip>` (see `tools/README.md`).

## Coding Style & Naming Conventions
- Nix formatting: 2-space indent, trailing commas on attributes; keep attr sets sorted.
- Run a formatter: `nix fmt` if configured, or use `alejandra`/`nixpkgs-fmt` locally.
- File layout: new hosts under `hosts/<name>/`; new modules under `modules/<area>.nix`.
- Names: use lowercase-kebab for files (`services/matrix.nix`), snake_case for attrs.

## Testing Guidelines
- Validate builds per host: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
- Run `nix flake check` before opening a PR; fix lint/format issues.
- VM scenarios: see `vms/README.md` for how to run service VMs.

## Commit & Pull Request Guidelines
- Messages: short, imperative subject; optional scope (e.g., `hosts/ivy: enable sops`).
- History favors concise messages over strict Conventional Commits—use types when helpful.
- PRs must include: purpose, affected hosts/modules, test notes (`nix flake check` output), and any screenshots/logs for services.
- Link related issues and call out secrets or deploy steps if relevant.

## Security & Configuration Tips
- SOPS: `.sops.yaml` is enforced. Edit secrets with `sops <file>`; never commit plaintext secrets.
- Deploy: prefer the helper (`deploy_cli.py`) or deploy-rs targets defined in the flake.
