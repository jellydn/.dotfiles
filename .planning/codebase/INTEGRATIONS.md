# INTEGRATIONS.md — External Integrations

## Third-Party Services / Providers

### Nix Ecosystem (Flake Inputs)

| Input | URL | Type | Purpose |
|---|---|---|---|
| `nixpkgs` | `github:NixOS/nixpkgs/nixos-26.05` | Nixpkgs release | Stable package repository |
| `nixpkgs-unstable` | `github:NixOS/nixpkgs/nixos-unstable` | Nixpkgs unstable | Bleeding-edge packages |
| `home-manager` | `github:nix-community/home-manager/release-26.05` | HM release | User config management |
| `nix-darwin` | `github:LnL7/nix-darwin/nix-darwin-26.05` | nix-darwin release | macOS system config |
| `dotfiles` | `github:jellydn/dotfiles` | External repo (flake=false) | Config file symlink source |

### OrbStack

- **Service:** OrbStack (v2.2.1) — Docker Desktop alternative for macOS
- **Installation:** Managed via nix-darwin Homebrew cask in `darwin.nix`
- **Status:** Currently Stopped on this machine
- **CLI:** `orb` command available, Docker context set to `orbstack`

### GitHub

- **CI/CD:** GitHub Actions (workflow in `.github/workflows/ci.yml`)
- **Auto-updates:** Dependabot (`.github/dependabot.yml`) — weekly flake.lock updates
- **CLI:** `gh` (GitHub CLI) installed via Nixpkgs

## Homebrew (macOS)

- **Managed by:** nix-darwin `homebrew` module in `darwin.nix`
- **CLI tools:** 10 brews (awscli, azure-cli, kubernetes-cli, helm, terraform, fastlane, cocoapods, exercism, ast-grep, gitbutler)
- **GUI apps:** 4 casks (ghostty, cursor, orbstack, zed@preview)
- **Taps:** None — fonts handled via Nix `fonts.packages`

## External Config Dependencies

### jellydn/dotfiles Repo

- **URL:** `github:jellydn/dotfiles`
- **Type:** Non-flake source (`flake = false`)
- **Symlinked configs:**
  - `helix/config.toml`, `helix/languages.toml`
  - `ghostty/config` (macOS only)
  - `lazygit/config.yml`
  - `kitty/Kanagawa.conf`, `kitty/current-theme.conf` (Linux only)
  - `nvim/` full directory (via `tiny-nvim` submodule)

## No External APIs

This project does not use any external APIs, databases, auth providers, webhooks, or third-party SDKs. All configuration is declarative and local.
