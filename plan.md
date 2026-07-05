# PR #2 Review: Modular Nix Flake Migration

> **PR:** [feat: migrate dotfiles to modular Nix flake (nixos + nix-darwin + home-manager)](https://github.com/jellydn/.dotfiles/pull/2)
> **Branch:** `feat/modular-nix-flake` → `main`
> **Author:** @jellydn
> **Stats:** +1,657 / −126, 19 files
> **Reviewed:** 2026-07-05 (upgraded to 26.05)

---

## 📋 Overview

This PR migrates the existing NixOS-only flake to a **multi-platform modular structure** supporting:

| Platform | Config | Host |
|---|---|---|
| **NixOS** (aarch64-linux) | `configuration.nix` | `nixos` |
| **macOS** (aarch64-darwin) | `darwin.nix` | `dunghd` |

Shared home-manager modules live in `home/` (9 modules): git, shell, packages, editors, terminal, env, aliases, ghostty, dotfiles-links.

### Key Architecture

```
.
├── flake.nix                     # Multi-platform flake entry
├── configuration.nix             # NixOS system config
├── darwin.nix                    # nix-darwin system config (macOS)
├── hardware-configuration.nix    # Auto-generated NixOS hardware
├── shell.nix                     # Compatibility shim
├── home/                         # Shared home-manager modules (×9)
├── modules/
│   ├── nixos/                    # ZRAM, polkit
│   └── darwin/                   # Touch ID sudo, shell completions
└── .github/
    ├── workflows/ci.yml          # Flake validation + build CI
    └── dependabot.yml            # Weekly flake.lock updates
```

---

## 🖥️ OrbStack in This Setup

[OrbStack](https://orbstack.dev) is a **fast, lightweight Docker Desktop alternative for macOS** — installed on this Mac (v2.2.1) and referenced in `darwin.nix` as a Homebrew cask:

```nix
casks = [
  "ghostty"
  "cursor"
  "orbstack"       # ← Installed & maintained via nix-darwin
  "zed@preview"
];
```

**Current state:** OrbStack is installed (`orb` CLI available), Docker context set to `orbstack`, but the service is **Stopped**.

### How OrbStack Relates

- **nix-darwin manages Homebrew** — running `darwin-rebuild switch` ensures OrbStack stays installed and up-to-date
- OrbStack is the Docker runtime for macOS; the flake's `devPackages` include Docker tooling (`gh`, `lazygit`, etc.) but Docker itself is provided by OrbStack, not Nix
- No special Nix integration needed — OrbStack is purely a macOS Homebrew dependency

---

## ✅ Upgraded to Nixpkgs 26.05

All inputs upgraded to 26.05:
- `nixpkgs` → `nixos-26.05`
- `home-manager` → `release-26.05`
- `nix-darwin` → `nix-darwin-26.05`
- `nixfmt-rfc-style` → `nixfmt` (deprecated rename)
- `stateVersion` bumped across all configs

---

## ❌ CI Failures (originally 4 issues, mostly resolved)

### 🔴 build-darwin — nix-darwin/nixpkgs version mismatch

```
error: nix-darwin now uses release branches that correspond to Nixpkgs releases.
The nix-darwin and Nixpkgs branches in use must match, but you are currently
using nix-darwin 26.11 with Nixpkgs 24.05.
```

**File:** `flake.nix` (lines 13-16)

**Cause:** `nix-darwin` tracks `master` (resolves to 26.11) but `nixpkgs` is pinned to `release-24.05`.

**Fix:** Pin nix-darwin to matching release branch:

```diff
 nix-darwin = {
-  url = "github:LnL7/nix-darwin";
+  url = "github:LnL7/nix-darwin/nix-darwin-24.05";
   inputs.nixpkgs.follows = "nixpkgs";
 };
```

---

### 🔴 build-nixos — `programs.zellij.extraConfig` doesn't exist

```
error: The option `home-manager.users.dunghd.programs.zellij.extraConfig' does not exist.
```

**File:** `home/terminal.nix` (lines ~240-380)

**Cause:** The `programs.zellij` module in Home Manager 24.05 does not have an `extraConfig` attribute. It uses a `settings` attrset that gets converted to KDL.

**Fix:** Either:
- **Option A:** Convert the KDL keybindings into the `settings` attrset format
- **Option B:** Drop `extraConfig` and use `xdg.configFile."zellij/config.kdl"` instead

---

### 🔴 check (x86_64-linux) / format-check — Nix fmt parse error

```
expecting expression
```

**Cause:** The formatter (`nixfmt-rfc-style`) chokes on `programs.zellij.extraConfig = ''...''` because the parser doesn't associate it with a valid Nix option path. Fixing the Zellij config (#2) resolves this too.

---

### ⚠️ GitHub Actions — Node 20 deprecation warnings

All three actions (`checkout@v4`, `nix-installer-action@v14`, `magic-nix-cache-action@v8`) run Node 20, which is deprecated on GitHub Actions runners running Node 24. Non-blocking but noisy.

---

## ✅ Passing Checks

| Check | Status | Notes |
|---|---|---|
| CodeRabbit | ✅ Pass | 11 actionable comments (see below) |
| Code Review Doctor | ✅ Pass | |
| GitGuardian | ✅ Pass | No secrets leaked |
| Socket Security | ✅ Pass | No dependency issues |
| Mergify Queue | ⏭️ Skipping | Waiting on CI |
| gitStream.cm | ⏭️ Skipping | |
| check (aarch64-linux) | ⏳ Pending | Never ran due to other failures |

---

## 📝 CodeRabbit Review Items

### Critical / Should Fix

| # | File | Issue | Priority |
|---|---|---|---|
| 1 | `home/editors.nix:42` | `force = true` silently deletes existing `~/.config/nvim` if it's a real directory | 🟡 Medium |
| 2 | `home/editors.nix:43-48` | `nvim --headless "+Lazy! sync"` failures silenced with `2>/dev/null \|\| true` | 🟡 Medium |
| 4 | `home/env.nix:26-37` | Hand-rolled bash-only Mise activation; use `programs.mise` with `enableZshIntegration`/`enableFishIntegration` | 🟢 Low |
| 5 | `home/packages.nix:61` | `mise` duplicated in both `packages.nix` and `env.nix` | 🟢 Low |
| 6 | `home/shell.nix:21-47` | `initExtraFirst`/`initExtra` deprecated — use `initContent` + `lib.mkOrder` | 🟢 Low |
| 7 | `flake.nix:36-44` | Duplicate `nixpkgs-unstable` import blocks — extract helper | 🟢 Low |
| 8 | `morereadme` | Standalone Home Manager example references `homeConfigurations` which doesn't exist in this flake | 🟢 Low |

### Already Fixed (in later commits)

| # | Issue | Fixed In |
|---|---|---|
| 3 | Invalid package names: `jj` → `jujutsu`, `mpc_cli` → `mpc-cli` | `27c498b` |
| 9 | Deprecated `homebrew/cask-fonts` tap | `27c498b` |
| 10 | User mismatch: `dunghd` vs `huynhdung` | Handled by separate `homeConfig` calls |
| 11 | `recursiveHash` not a valid option | Still present — needs `recursive = true` |

---

## 🧪 How to Test Locally

### Pre-requisites

```bash
# Confirm tools available
which nix          # Nix installed
which orb          # OrbStack CLI (v2.2.1)
which docker       # Docker CLI
orb status         # Should show Stopped — fine for building
```

### Build Checks (safe — no system changes)

```bash
# Validate syntax (fast)
nix flake check

# Build darwin config (macOS) — dry run
nix build .#darwinConfigurations.dunghd.system

# Build NixOS config (via QEMU)
nix build .#nixosConfigurations.nixos.config.system.build.toplevel \
  --eval-system x86_64-linux \
  --system aarch64-linux

# Enter dev shell with all tools
nix develop

# Check formatting
nix fmt && git diff --exit-code
```

### Full Activation (on this Mac)

```bash
# WARNING: This changes system config
darwin-rebuild switch --flake .

# Verify OrbStack is managed
brew list --cask orbstack
```

---

## ✅ Fixes Applied So Far

1. **Pinned nix-darwin** to `nix-darwin-24.05` ✓
2. **Fixed Zellij config** — removed `extraConfig` ✓
3. **Fixed `recursiveHash` → `recursive = true`** ✓
4. **Upgraded to 26.05** — all inputs, stateVersion, nixfmt rename ✓

## ⏳ Remaining / Optional

1. **Address CodeRabbit medium/low items** — `force = true`, silenced errors, deprecated init options
2. **Update GitHub Actions** to Node 24-compatible versions (optional)
3. **Verify nix fmt passes** on 26.05 nixfmt (may differ from 24.05 nixfmt-rfc-style)

---

## 🔗 Resources

- [OrbStack Website](https://orbstack.dev)
- [OrbStack Docs](https://docs.orbstack.dev)
- [nix-darwin Release Branches](https://github.com/LnL7/nix-darwin)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
