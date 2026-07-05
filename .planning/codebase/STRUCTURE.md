# STRUCTURE.md — Directory Layout & Organization

## Top-Level Structure

```
.
├── flake.nix                     # Multi-platform flake entry (179 lines)
├── flake.lock                    # Locked input revisions
├── configuration.nix             # NixOS system config (143 lines)
├── darwin.nix                    # nix-darwin macOS config (161 lines)
├── hardware-configuration.nix    # Auto-generated NixOS hardware (48 lines)
├── shell.nix                     # Legacy nix-shell compat shim (6 lines)
├── README.md                     # Project documentation
├── plan.md                       # PR review & CI status document
├── .github/
│   ├── dependabot.yml            # Weekly flake.lock update schedule
│   └── workflows/ci.yml          # GitHub Actions CI pipeline
├── home/                         # Shared home-manager modules (9 files)
│   ├── default.nix               # Module entry — imports all home modules
│   ├── aliases.nix               # Shell aliases (40 lines)
│   ├── dotfiles-links.nix        # xdg.configFile symlinks (52 lines)
│   ├── editors.nix               # Neovim + Helix config (62 lines)
│   ├── env.nix                   # Env vars, direnv, fzf, zoxide, mise (82 lines)
│   ├── ghostty.nix               # Ghostty terminal placeholder (13 lines)
│   ├── git.nix                   # Git, gh, lazygit config (111 lines)
│   ├── packages.nix              # User packages list (85 lines)
│   ├── shell.nix                 # Zsh + Fish shell config (195 lines)
│   └── terminal.nix              # Kitty, Tmux, Zellij config (254 lines)
├── modules/
│   ├── nixos/
│   │   └── default.nix           # ZRAM, polkit, systemd services (36 lines)
│   └── darwin/
│       └── default.nix           # Touch ID sudo, shell paths (21 lines)
└── .planning/
    └── codebase/                 # This codemap output
```

## File Size Distribution

| Size | Files | Notes |
|---|---|---|
| 200-260 lines | `home/terminal.nix` (254) | Tmux config is verbose |
| 150-200 lines | `home/shell.nix` (195), `flake.nix` (179), `darwin.nix` (161) | Core files |
| 100-150 lines | `configuration.nix` (143), `home/git.nix` (111) | System config + git |
| 50-100 lines | `home/packages.nix` (85), `home/env.nix` (82), `home/editors.nix` (62), `home/dotfiles-links.nix` (52) | Medium modules |
| <50 lines | `home/aliases.nix` (40), `modules/nixos/default.nix` (36), `modules/darwin/default.nix` (21), `home/ghostty.nix` (13), `home/default.nix` (13), `shell.nix` (6) | Small modules |

## Naming Conventions

- **Files:** `kebab-case.nix` throughout
- **Directories:** Lowercase, single words (`home/`, `modules/`)
- **Flake outputs:** `camelCase` or `kebab-case` (`darwinConfigurations`, `nixosConfigurations`, `devShells`)
- **Nix attributes:** `camelCase` for functions, `kebab-case` for package names
- **Section headers:** Emoji-prefixed (`# ── Section ──`)

## Key Locations

| Purpose | Location |
|---|---|
| Flake entry point | `flake.nix` |
| Home-manager module index | `home/default.nix` |
| All aliases (cross-shell) | `home/aliases.nix` |
| Dotfile symlink definitions | `home/dotfiles-links.nix` |
| CI pipeline | `.github/workflows/ci.yml` |
| Dependabot config | `.github/dependabot.yml` |
