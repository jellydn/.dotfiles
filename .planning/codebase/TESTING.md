# TESTING.md — Testing Strategy

## No Formal Test Framework

This project is a **declarative Nix configuration** — there are no unit tests, integration tests, or test frameworks. Testing relies entirely on:

1. **Nix evaluation** — `nix flake check` validates syntax and option types
2. **Build validation** — Building configurations confirms all packages resolve
3. **CI pipeline** — GitHub Actions runs all checks automatically

## CI Pipeline (4 Jobs)

### 1. format-check
- **Runner:** ubuntu-latest
- **Command:** `nix fmt && git diff --exit-code`
- **What it tests:** All `.nix` files are properly formatted by `nixfmt`

### 2. check (matrix: x86_64-linux, aarch64-linux)
- **Runner:** ubuntu-latest (with QEMU for aarch64)
- **Command:** `nix flake check --system ${{ matrix.target }}`
- **What it tests:** Flake evaluation and option validation
- **Also runs:** Format check (`nix fmt && git diff --exit-code`)

### 3. build-nixos
- **Runner:** ubuntu-latest + QEMU
- **Commands:**
  - `nix build .#nixosConfigurations.nixos.config.system.build.toplevel` (system build)
  - `nix build .#devShells.aarch64-linux.default` (dev shell)
- **What it tests:** Full NixOS system + integrated home-manager builds

### 4. build-darwin
- **Runner:** macos-latest
- **Commands:**
  - `nix build .#darwinConfigurations.dunghd.system` (darwin system)
  - `nix build .#devShells.aarch64-darwin.default` (dev shell)
- **What it tests:** Full macOS system + integrated home-manager builds

## What's NOT Tested

- **Runtime behavior** — No tests verify that configs actually work at runtime
- **Package version compatibility** — If a package breaks at runtime (e.g., LSP server crashes), no test catches it
- **macOS activation** — The darwin build is built but not activated on CI (CI has no macOS hardware)
- **Cross-platform logic** — No test verifies that `lib.mkIf` gating is correct
- **Dotfile symlinks** — No test confirms symlinks resolve to valid paths

## Testing Locally (From plan.md)

```bash
# Syntax validation
nix flake check

# Build (no activation)
nix build .#darwinConfigurations.dunghd.system
nix build .#nixosConfigurations.nixos.config.system.build.toplevel

# Dev shell
nix develop

# Format check
nix fmt && git diff --exit-code
```

## Known CI Gaps

1. **Node 20 deprecation warnings** — All GitHub Actions (`checkout@v4`, `nix-installer-action@v14`, `magic-nix-cache-action@v8`) run Node 20, which is deprecated on runners running Node 24. Non-blocking.
2. **QEMU emulation** — aarch64-linux builds on ubuntu use QEMU, which is slower than native and may mask platform-specific issues.
3. **macOS-only** — `build-darwin` only runs on `macos-latest`; Linux-only issues with darwin configs aren't caught.
