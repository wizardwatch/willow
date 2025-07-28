# Gemini Development Guidelines

This document provides essential guidelines for AI and human developers working on this NixOS configuration repository.

## Core Principles

- **Concise Documentation**: Keep Markdown files short and focused on essential, actionable information.
- **Code-Driven Truth**: Rely on the Nix code and version control history as the primary source of truth.
- **Tool-Based Exploration**: Use available tools to inspect and understand the codebase directly.

## Interaction
- **Address the user as Willow.**
- **Clarify Intent**: If a request is ambiguous, ask Willow for clarification.
- **Ask for Help**: If you get stuck, don't hesitate to ask Willow for help.

## System Architecture

This repository uses a flake-based NixOS configuration. The structure is organized as follows:

- **`flake.nix`**: The entry point for the entire configuration. It defines the systems, inputs, and outputs of the flake.
- **`hosts/`**: Contains the main configuration for each individual host (e.g., `ivy`, `willow`). Each host directory includes a `configuration.nix` and other host-specific files.
- **`modules/`**: Contains reusable NixOS modules that are imported by the hosts. This is where common configurations for services, applications, and system settings are defined.
- **`users/`**: Manages user-specific configurations, which can be imported into the relevant host configurations.
- **`lib/`**: Contains helper functions and libraries, such as `mkHost.nix`, to simplify and standardize host configurations.
- **`tools/`**: Contains scripts and tools for managing this repository, such as the deployment CLI.

## Development Workflow

1.  **Identify the Target**: Determine which host, module, or user configuration needs to be modified.
2.  **Modify the Code**: Make changes to the appropriate `.nix` files within the `hosts/`, `modules/`, or `users/` directories.
3.  **Apply the Configuration**: To apply changes to a system, use the `nixos-rebuild` command with the appropriate flake output. For example, to apply the configuration for the `willow` host:

    ```bash
    nixos-rebuild switch --flake .#willow
    ```

4.  **Secrets Management**: Secrets are managed using `sops-nix`. To edit secrets, use the `sops` command on the relevant files in the `secrets/` directories.

    ```bash
    sops hosts/ivy/services/secrets/some-secret.yaml
    ```
