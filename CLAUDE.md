# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### System Configuration
```bash
# Rebuild NixOS system
sudo nixos-rebuild switch --flake .

# Build system configuration
sudo nixos-rebuild build --flake .

# Test system configuration generation
sudo nosos-rebuild dry-activate --flake .

# Upgrade system
sudo nixos-rebuild switch --upgrade --flake .
```

### Home Manager
```bash
# Rebuild home configuration
home-manager switch --flake .

# Build home configuration
home-manager build --flake .
```

### Development
```bash
# Enter development shell with all necessary tools
nix develop .

# Build the flake
nix build .

# Show flake information
nix flake show .
```

### Updates
```bash
# Update flake inputs
nix flake update .

# Update specific input
nix flake lock --update-input nixpkgs
```

## Architecture

This is a modular NixOS configuration repository using flakes, designed to manage multiple hosts (homelab, work-machine, home-server) with role-based inheritance.

### Core Structure
- **flake.nix**: Main entry point defining inputs and using custom `mkFlake` function to generate outputs
- **blueprint.nix**: Shared configuration with user definitions, system assertions, and default filesystem setup
- **lib/**: Custom utility functions for module loading, role inheritance, and NixOS helpers

### Host Management
- **hosts/**: Directory containing per-host configurations
- Each host can define profiles for platform, hardware, roles, and user settings
- Host configurations use the `modules.profiles` options system
- The system automatically discovers and loads hosts via `mapHosts` function

### Module System
The custom module system in `lib/modules.nix` provides:
- `mapModules`: Recursively load modules from directories
- `mapModulesRec'`: Load all modules including subdirectories (respects `.noload` files)
- Automatic module discovery and import based on file structure

### Role-based Configuration
- **lib/roles.nix**: Implements role inheritance system using `mkRoles` function
- Roles can inherit from other roles creating a hierarchy
- Expanded roles are used throughout the configuration system
- **modules/profiles/**: Contains role definitions (base, hypervisor, router, workstation) and hardware/platform/user profiles

### Key Configuration Areas
- **modules/devenv/**: Development environment configurations
- **modules/shell/**: Shell environment setup (zsh, git, direnv, claude)
- **modules/services/**: System services configuration
- **modules/themes/**: Visual customization
- **modules/home/**: Home directory and XDG configuration
- **overlays/**: Nixpkgs overlays for package customization
- **packages/**: Custom package definitions
- **config/**: User configuration files (git, zsh shell)

### Development Environment
- **overlays/claude-code/**: Custom overlay for Claude Code with wrapper script
- **modules/shell/claude.nix**: Shell integration for Claude Code
- Development shell can be activated with `nix develop .`