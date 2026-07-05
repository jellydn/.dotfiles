<div align="center">
  <h1>🍎 jellydn Dotfiles</h1>
  <p>
    <strong>Cross-platform Nix flake for NixOS + macOS (nix-darwin + home-manager)</strong>
  </p>

  <p>
    <a href="https://github.com/jellydn/.dotfiles/actions/workflows/ci.yml">
      <img src="https://github.com/jellydn/.dotfiles/actions/workflows/ci.yml/badge.svg" alt="CI">
    </a>
    <a href="https://nixos.org">
      <img src="https://img.shields.io/badge/NixOS-26.05-5277C3?logo=nixos&logoColor=white" alt="NixOS">
    </a>
    <a href="https://github.com/LnL7/nix-darwin">
      <img src="https://img.shields.io/badge/macOS-nix--darwin-26.05-999999?logo=apple&logoColor=white" alt="macOS">
    </a>
    <a href="https://github.com/nix-community/home-manager">
      <img src="https://img.shields.io/badge/home--manager-26.05-3E863A?logo=nixos&logoColor=white" alt="home-manager">
    </a>
  </p>
</div>

---

## ✨ Features

- **Cross-platform** — Single flake for both **NixOS** (aarch64-linux) and **macOS** (aarch64-darwin)
- **Shared home-manager** — User-level configs reuse the same modules on both platforms
- **Dotfiles symlinks** — Editor/terminal configs symlinked directly from [jellydn/dotfiles](https://github.com/jellydn/dotfiles) via `xdg.configFile`
- **Formatted & CI'd** — `nix fmt` enforced, flake checked, and everything built on every push
- **Auto-updates** — Dependabot keeps `flake.lock` inputs fresh weekly

## 🚀 Quick start

### NixOS

```sh
sudo nixos-rebuild switch --flake .
```

### macOS (nix-darwin)

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

# Enter a dev shell with all tools
nix develop
```

## 📁 Structure

```
├── flake.nix                     # Multi-platform flake entry
├── flake.lock
├── configuration.nix             # NixOS system config (aarch64-linux)
├── darwin.nix                    # nix-darwin system config (macOS)
├── hardware-configuration.nix    # Auto-generated NixOS hardware config
├── shell.nix                     # Compatibility shim for nix-shell
├── home/                         # Shared home-manager modules
│   ├── default.nix               # Module entry
│   ├── aliases.nix               # Shell aliases
│   ├── dotfiles-links.nix        # Symlinks ~/.config/* → dotfiles repo
│   ├── editors.nix               # Neovim (LSPs) + Helix
│   ├── env.nix                   # Env vars, direnv, fzf, zoxide, mise
│   ├── ghostty.nix               # Ghostty (config in dotfiles symlinks)
│   ├── git.nix                   # Git, gh, lazygit
│   ├── packages.nix              # Dev tools, languages, CLI utilities
│   ├── shell.nix                 # Zsh (Pure + Atuin), Fish (Kanagawa)
│   └── terminal.nix              # Kitty (Linux), Tmux, Zellij
├── modules/
│   ├── nixos/default.nix         # NixOS-specific (zram, polkit, firmware)
│   └── darwin/default.nix        # macOS-specific (Touch ID sudo, completions)
├── .github/
│   ├── dependabot.yml            # Weekly flake.lock updates
│   └── workflows/ci.yml          # CI: format check + build (NixOS & darwin)
└── README.md
```

## 📦 Flake inputs

| Input | Source | Purpose |
|---|---|---|
| `nixpkgs` | `nixos-26.05` | Stable Nixpkgs |
| `nixpkgs-unstable` | `nixos-unstable` | Bleeding-edge packages via `unstable`/`unstableDarwin` |
| `home-manager` | `release-26.05` | User-level package/config management |
| `nix-darwin` | `nix-darwin-26.05` | macOS system config (defaults, homebrew, nix daemon) |
| `dotfiles` | `github:jellydn/dotfiles` | Source for symlinked configs (helix, ghostty, lazygit, kitty, neovim) |

## 🔗 Dotfiles symlinks

Editor and terminal configs are **symlinked** from the [jellydn/dotfiles](https://github.com/jellydn/dotfiles) flake input via `xdg.configFile` with `force = true`:

| Tool | Symlinked files |
|---|---|
| **Helix** | `config.toml`, `languages.toml` |
| **Ghostty** | `config` (macOS only) |
| **LazyGit** | `config.yml` |
| **Kitty** | `Kanagawa.conf`, `current-theme.conf` (Linux only) |
| **Neovim** | Full nvim config directory (via `tiny-nvim` submodule) |

Tools where Nix generates the config directly (tmux, zellij, kitty, git, fish, zsh) use home-manager's `programs.*` options with settings derived from the original dotfiles.

## 🧪 CI

On every push/PR to `main`, GitHub Actions runs:

| Job | Runner | What it does |
|---|---|---|
| `format-check` | ubuntu | `nix fmt --check` (fast formatting gate) |
| `check` | ubuntu (x2) | `nix flake check` for x86_64-linux + aarch64-linux |
| `build-nixos` | ubuntu + QEMU | Full NixOS system + dev shell build |
| `build-darwin` | macos-latest | Full darwin system + dev shell build |

## 🍺 Homebrew

On macOS, GUI apps (ghostty, cursor, orbstack, zed) and CLI tools (awscli, terraform, etc.) are managed via nix-darwin's `homebrew` module in `darwin.nix`. Fonts are installed via `fonts.packages`.

## 🧑‍💻 Development

```sh
# Enter a shell with all dev tools
nix develop

# Check formatting
nix fmt --check

# Format all .nix files
nix fmt
```

## 📚 Resources

- [NixOS Asia — Flake install guide](https://nixos.asia/en/nixos-install-flake)
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [home-manager](https://github.com/nix-community/home-manager)

## 📎 Original dotfiles

The original GNU Stow-managed [dotfiles repo](https://github.com/jellydn/dotfiles) is still the canonical source for editor configs (nvim, helix, cursor, zed, claude) and window manager configs (aerospace, hyprland, i3). This Nix flake replaces the system-level and home-manager-level wiring.
