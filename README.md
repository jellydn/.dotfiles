# jellydn Dotfiles — Nix Flake

Cross-platform Nix configuration supporting **NixOS** (aarch64-linux) and **macOS** (aarch64-darwin via nix-darwin + home-manager).

## Structure

```
.
├── flake.nix                    # Multi-platform flake entry
├── flake.lock
├── configuration.nix            # NixOS system config (aarch64-linux)
├── darwin.nix                   # nix-darwin system config (macOS)
├── hardware-configuration.nix   # Auto-generated NixOS hardware config
├── home/                        # Shared home-manager modules (both platforms)
│   ├── default.nix              # Module entry (imports all below)
│   ├── aliases.nix              # Shell aliases (editor, general, nix commands)
│   ├── dotfiles-links.nix       # Symlinks ~/.config/* -> dotfiles repo
│   ├── editors.nix              # Neovim (with LSPs) + Helix + nvim config symlink
│   ├── env.nix                  # Env vars, sessionPath, direnv, fzf, zoxide, mise
│   ├── ghostty.nix              # Ghostty placeholder (config in dotfiles-links)
│   ├── git.nix                  # Git config (user, delta, LFS, aliases), gh, lazygit
│   ├── packages.nix             # Dev tools, languages, CLI utilities
│   ├── shell.nix                # Zsh (Pure prompt, Atuin) + Fish (Kanagawa theme)
│   └── terminal.nix             # Kitty (Linux), Tmux (TPM, vim-aware), Zellij
├── modules/
│   ├── nixos/default.nix        # NixOS-specific (zram, polkit, firmware)
│   └── darwin/default.nix       # macOS-specific (Touch ID sudo, shell completions)
├── .github/
│   └── workflows/ci.yml         # GitHub Actions CI (check + build for both platforms)
└── README.md
```

## Usage

### NixOS (aarch64-linux machine)

```sh
sudo nixos-rebuild switch --flake .
```

### macOS (nix-darwin)

First install nix-darwin, then apply:

```sh
nix run nix-darwin -- switch --flake .
darwin-rebuild switch --flake .
```

### Safe testing (no system changes)

```sh
# Validate syntax (fast)
nix flake check

# Build without activating
nix build .#darwinConfigurations.dunghd.system          # macOS
nix build .#nixosConfigurations.nixos.config.system.build.toplevel  # Linux
```

## Flake inputs

| Input | Source | Purpose |
|---|---|---|
| `nixpkgs` | `nixos-24.05` | Stable Nixpkgs |
| `nixpkgs-unstable` | `nixos-unstable` | Bleeding-edge packages via `unstable`/`unstableDarwin` specialArgs |
| `home-manager` | `release-24.05` | User-level package/config management |
| `nix-darwin` | `master` | macOS system config (system defaults, homebrew, nix daemon) |
| `dotfiles` | `github:jellydn/dotfiles` | Source for symlinked config files (helix, ghostty, lazygit, kitty themes, neovim) |

## Home-manager modules

Config files for helix, ghostty, lazygit, and neovim are **symlinked** from the `dotfiles` flake input (`jellydn/dotfiles`) via `home/dotfiles-links.nix` and `home/editors.nix`, using `xdg.configFile` with `force = true` to replace the existing Nix-generated configs.

Tools where Nix generates the config directly (tmux, zellij, kitty, git, fish, zsh) use home-manager's `programs.*` options and are derived from the original dotfiles content.

## CI

On every push/PR to `main`, GitHub Actions:
- **check**: `nix flake check` for `x86_64-linux` and `aarch64-linux` (fast evaluation gate)
- **build-nixos**: Full system build via QEMU binfmt emulation on ubuntu
- **build-darwin**: Full system build on `macos-latest`

## Homebrew

On macOS, GUI applications (ghostty, cursor, orbstack, zed) and CLI tools (awscli, terraform, etc.) are managed via nix-darwin's `homebrew` module in `darwin.nix`. Fonts are installed via `fonts.packages`.

## Resources

- https://nixos.asia/en/nixos-install-flake
- https://github.com/LnL7/nix-darwin
- https://github.com/nix-community/home-manager

## Original dotfiles

The original GNU Stow-managed dotfiles repo is at [github.com/jellydn/dotfiles](https://github.com/jellydn/dotfiles) and cloned locally at `~/Projects/dotfiles`.
This Nix flake replaces the system-level and home-manager-level configurations.
The dotfiles repo is still the canonical source for editor configs (nvim, helix, Cursor, Zed, Claude) and window manager configs (aerospace, hyprland, i3).
