# STACK.md — Technology Stack

## Languages

- **Nix** — Primary configuration language (`.nix` files across the entire project)
- **Bash** — Shell hooks and CI scripts (inline in Nix strings and CI YAML)
- **YAML** — CI workflow (`.github/workflows/ci.yml`) and Dependabot config

## Runtime / Platform

| Platform | Architecture | Config File |
|---|---|---|
| **NixOS** | `aarch64-linux` | `configuration.nix` |
| **macOS** | `aarch64-darwin` | `darwin.nix` |

## Core Frameworks

| Framework | Version/Branch | Purpose |
|---|---|---|
| **Nixpkgs** | `nixos-26.05` | Package repository (stable) |
| **Nixpkgs-unstable** | `nixos-unstable` | Bleeding-edge packages |
| **Home Manager** | `release-26.05` | User-level declarative config |
| **nix-darwin** | `nix-darwin-26.05` | macOS system-level config |

## Key Dependencies (via Nixpkgs)

### CLI Essentials
`curl`, `wget`, `jq`, `unzip`, `zip`, `htop`, `ripgrep`, `fd`, `bat`, `eza`, `fzf`, `tree`, `du-dust`, `duf`, `procs`, `sd`

### Git / Dev Tools
`gh` (GitHub CLI), `lazygit`, `git-lfs`, `diff-so-fancy`, `delta`, `ghq`, `diffr`

### Shell / Terminal
`fish`, `zsh`, `tmux`, `direnv`, `zoxide`

### Development Languages
`nodejs_22`, `deno`, `bun`, `go`, `python3`, `rustup`, `gnumake`, `cmake`, `gcc`

### LSP / Formatting
`nil` (Nix LSP), `nixfmt` (formatter), `statix`, `deadnix`, `nodePackages.biome`, `nodePackages.prettier`, `typos`

### Misc
`mise` (dev environment), `just` (command runner), `jujutsu` (VCS), `yq` (YAML processor)

## Homebrew (macOS only, managed by nix-darwin)

**Brews:** `awscli`, `azure-cli`, `kubernetes-cli`, `helm`, `terraform`, `fastlane`, `cocoapods`, `exercism`, `ast-grep`, `gitbutler`

**Casks:** `ghostty`, `cursor`, `orbstack`, `zed@preview`

## Configuration Files

| File | Format | Purpose |
|---|---|---|
| `flake.nix` | Nix | Flake entry, inputs, outputs, dev shells |
| `configuration.nix` | Nix | NixOS system config |
| `darwin.nix` | Nix | macOS system config via nix-darwin |
| `home/*.nix` (9 files) | Nix | Home Manager user modules |
| `modules/nixos/default.nix` | Nix | NixOS-specific module additions |
| `modules/darwin/default.nix` | Nix | macOS-specific module additions |
| `shell.nix` | Nix | Legacy nix-shell compatibility shim |
| `.github/workflows/ci.yml` | YAML | CI pipeline (4 jobs) |
| `.github/dependabot.yml` | YAML | Weekly flake.lock updates |

## CI Infrastructure

- **GitHub Actions** — 4 jobs: `format-check`, `check` (x86_64 + aarch64), `build-nixos`, `build-darwin`
- **QEMU** — Used for aarch64-linux builds on ubuntu runners
- **DeterminateSystems/nix-installer-action@v14** — Nix installation on CI
- **DeterminateSystems/magic-nix-cache-action@v8** — Binary cache acceleration
