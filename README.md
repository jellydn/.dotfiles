# jellydn Dotfiles — Nix Flake

Cross-platform Nix configuration supporting **NixOS** (aarch64-linux) and **macOS** (aarch64-darwin via nix-darwin + home-manager).

## Structure

```
.
├── flake.nix                 # Multi-platform flake entry
├── configuration.nix         # NixOS system config (aarch64-linux)
├── darwin.nix                # nix-darwin system config (macOS)
├── hardware-configuration.nix # Auto-generated NixOS hardware config
├── home/                     # Shared home-manager modules
│   ├── default.nix           # Module entry (imports all below)
│   ├── aliases.nix           # Shell aliases
│   ├── editors.nix           # Neovim, Helix
│   ├── env.nix               # Environment variables, paths, direnv, zoxide, fzf
│   ├── git.nix               # Git config, delta, lazygit, gh
│   ├── packages.nix          # Dev tools, languages, CLIs
│   ├── shell.nix             # Zsh + Fish shell configs
│   └── terminal.nix          # Kitty, Tmux, Zellij
└── modules/
    ├── nixos/                # NixOS-specific shared module
    └── darwin/               # Darwin-specific shared module
```

## Usage

### NixOS (aarch64-linux machine)

```sh
sudo nixos-rebuild switch --flake .
```

### macOS (nix-darwin)

First, install nix-darwin:

```sh
nix run nix-darwin -- switch --flake .
```

Then apply:

```sh
darwin-rebuild switch --flake .
```

### Home-manager standalone (either platform)

```sh
nix run home-manager -- switch --flake .
```

## Resources

- https://nixos.asia/en/nixos-install-flake
- https://github.com/LnL7/nix-darwin
- https://github.com/nix-community/home-manager

## Original dotfiles

The original GNU Stow-managed dotfiles are at `~/Projects/dotfiles`.
This Nix flake replaces the system-level and user-level configurations
that were previously managed by `install.sh` and symlinks.
