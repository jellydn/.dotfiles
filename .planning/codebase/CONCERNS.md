# CONCERNS.md — Technical Debt, Bugs, & Issues

## Known CI Failures (Open)

### 1. build-darwin — nix-darwin/nixpkgs version mismatch
- **Status:** Was fixed (pinned to `nix-darwin-24.05`), then upgraded to 26.05
- **Current state:** Upgraded to `nix-darwin-26.05`, needs CI re-run to verify
- **Risk:** Low — matching release branches should resolve

### 2. format-check — Nix fmt may fail on 26.05
- **Status:** Was caused by zellij `extraConfig` parse error, now removed
- **Current state:** Fixed in code, but `nixfmt` (26.05) may format differently from `nixfmt-rfc-style` (24.05)
- **Risk:** Medium — formatting could drift between versions
- **Note:** `nixfmt-rfc-style` renamed to `nixfmt` in 26.05

## CodeRabbit Issues (Unresolved)

### Medium Priority

| # | File | Issue |
|---|---|---|
| 1 | `home/editors.nix:42` | `force = true` on `xdg.configFile."nvim"` silently deletes existing `~/.config/nvim` if it's a real directory |
| 2 | `home/editors.nix:43-48` | `nvim --headless "+Lazy! sync"` failures silenced with `2>/dev/null || true` — users won't see errors |

### Low Priority

| # | File | Issue |
|---|---|---|
| 4 | `home/env.nix:26-37` | Hand-rolled bash-only Mise activation; should use `programs.mise` with `enableZshIntegration`/`enableFishIntegration` |
| 5 | `home/packages.nix:61` | `mise` duplicated in both `packages.nix` and `env.nix` |
| 6 | `home/shell.nix:21-47` | `initExtraFirst`/`initExtra` deprecated — use `initContent` + `lib.mkOrder` |
| 7 | `flake.nix:36-44` | Duplicate `nixpkgs-unstable` import blocks (`unstable` + `unstableDarwin`) — extract helper |
| 8 | plan.md | Standalone Home Manager example references `homeConfigurations` which doesn't exist in this flake |

## Known Issues (Beyond CodeRabbit)

### 1. Stale `nixfmt-rfc-style` in packages.nix
- **File:** `home/packages.nix`
- **Issue:** Still references `nixfmt-rfc-style` instead of `nixfmt`
- **Impact:** Builds may fail or show deprecation warnings on 26.05
- **Fix:** Rename to `nixfmt` to match `editors.nix` and `flake.nix`

### 2. Legacy `shell.nix` Shim
- **File:** `shell.nix`
- **Issue:** Uses `builtins.currentSystem` which evaluates at parse time, not build time
- **Impact:** May behave unexpectedly on cross-platform evaluations
- **Priority:** Low — it's a compatibility shim

### 3. Missing macOS Keyboard Options
- **File:** `darwin.nix` (commented out)
- **Issue:** `keyRepeat` and `initialKeyRepeat` options commented out — require newer nix-darwin options
- **Impact:** Users who want faster key repeat must set manually

### 4. GitHub Actions Node 20 Deprecation
- **Files:** `.github/workflows/ci.yml`
- **Issue:** `checkout@v4`, `nix-installer-action@v14`, `magic-nix-cache-action@v8` use deprecated Node 20
- **Impact:** Non-blocking but generates warnings

### 5. Duplicate Format Check Step
- **File:** `.github/workflows/ci.yml`
- **Issue:** The `check` job has a `Check Nix formatting` step that duplicates the `format-check` job
- **Impact:** Redundant CPU time on every CI run

## Security Concerns

- **None identified.** This is a local configuration flake with no secrets, no network-exposed services, and no user input handling.
- All packages come from Nixpkgs (pinned via flake.lock, updated weekly by Dependabot)
- GitHub credentials handled by `gh auth git-credential` helper

## Performance Concerns

- **Total package count:** ~50+ packages installed via home-manager + system packages
- **CI build time:** Building NixOS + darwin configs can take 10-30 minutes due to package compilation
- **Aarch64 QEMU:** Emulated builds on CI are significantly slower than native

## Fragile Areas

1. **dotfiles repo dependency** — If `jellydn/dotfiles` changes structure, symlinks break silently
2. **Neovim submodule** — The `tiny-nvim` submodule in dotfiles must be fetched for config to work; `xdg.configFile` source may be empty if not cloned with `--recurse-submodules`
3. **Homebrew tap removal** — `homebrew/cask-fonts` was removed (fonts now via Nix), but if `fonts.packages` has resolution issues, fonts could break on macOS
4. **Platform gating** — `lib.mkIf pkgs.stdenv.isDarwin/Linux` gating is fragile if stdenv changes between platforms
