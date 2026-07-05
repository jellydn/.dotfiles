# ARCHITECTURE.md — System Architecture

## Overview

This is a **cross-platform Nix flake** that manages system configuration for two machines:

1. **NixOS** (aarch64-linux) — Primary Linux machine
2. **macOS** (aarch64-darwin) — Development Mac

The flake uses Home Manager as a **shared user-config layer** across both platforms, with platform-specific system config in separate files.

## Architecture Pattern

```
                    ┌─────────────────────────────────┐
                    │           flake.nix              │
                    │   (Entry point, inputs, wiring)  │
                    └──────────┬──────────────────────┘
                               │
            ┌──────────────────┼──────────────────┐
            ▼                  ▼                   ▼
   ┌────────────────┐  ┌──────────────┐  ┌────────────────┐
   │ NixOS System   │  │ Formatter(s) │  │ nix-darwin Sys │
   │ (aarch64-linux)│  │ (nixfmt ×3)  │  │ (aarch64-derwin)│
   └───────┬────────┘  └──────────────┘  └───────┬────────┘
           │                                     │
           ▼                                     ▼
   ┌────────────────┐                   ┌─────────────────┐
   │configuration.nix│                   │   darwin.nix     │
   │+ modules/nixos  │                   │ + modules/darwin │
   │+ home-manager   │                   │ + home-manager   │
   └───────┬────────┘                   └───────┬──────────┘
           │                                     │
           └──────────────┬──────────────────────┘
                          ▼
             ┌────────────────────────┐
             │  Shared home-manager   │
             │  modules (home/*.nix)  │
             │  9 modules total      │
             └────────────────────────┘
```

## Key Architectural Decisions

### 1. Single Shared Home Config

Both NixOS and macOS use the **same `homeConfig` function** defined in `flake.nix`:

```nix
homeConfig = { username, homeDirectory, ... }: {
  imports = [ ./home ];
  home = { inherit username homeDirectory; stateVersion = "26.05"; };
};
```

The only differences are:
- **NixOS:** User `dunghd`, home `/home/dunghd`
- **macOS:** User `huynhdung`, home `/Users/huynhdung`

### 2. Unstable Package Access

Two separate `nixpkgs-unstable` imports are maintained:
- `unstable` — packages for `aarch64-linux` (NixOS)
- `unstableDarwin` — packages for `aarch64-darwin` (macOS)

Passed via `specialArgs` to the respective system config.

### 3. Dev Shell (Shared)

A single `devPackages` function generates a common dev shell for both platforms, with cross-platform CLI tools. No platform-specific dev shells.

### 4. Dotfiles via Symlinks

External editor configs (helix, ghostty, lazygit, kitty, neovim) are **symlinked** from the `jellydn/dotfiles` flake input using `xdg.configFile` with `force = true`.

Tools where Nix generates config directly (tmux, zellij, kitty, git, fish, zsh) use home-manager's `programs.*` options.

## Layer Separation

| Layer | NixOS | macOS |
|---|---|---|
| **System config** | `configuration.nix` | `darwin.nix` |
| **System extras** | `modules/nixos/` | `modules/darwin/` |
| **User config** | `home/*.nix` (shared) | `home/*.nix` (shared) |

## Data Flow

1. User runs `darwin-rebuild switch --flake .` or `nixos-rebuild switch --flake .`
2. `flake.nix` resolves the appropriate configuration (`nixosConfigurations` or `darwinConfigurations`)
3. The configuration imports the system config file + platform module + home-manager module
4. Home Manager evaluates `homeConfig` which imports all `home/*.nix` modules
5. `xdg.configFile` entries create symlinks to external dotfiles
6. `systemd`/launchd activates the resulting system profile

## Entry Points

| Entry Point | Command |
|---|---|
| NixOS rebuild | `sudo nixos-rebuild switch --flake .` |
| Darwin rebuild | `darwin-rebuild switch --flake .` |
| Dev shell | `nix develop` |
| Format check | `nix fmt` |
| Flake check | `nix flake check` |
| Legacy shell | `nix-shell` (via `shell.nix` compat shim) |
