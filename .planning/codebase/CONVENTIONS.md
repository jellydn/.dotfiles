# CONVENTIONS.md — Code Style & Patterns

## Nix Language Conventions

### Formatting
- Formatter: `nixfmt` (from Nixpkgs 26.05, formerly `nixfmt-rfc-style`)
- Enforced via CI: `nix fmt && git diff --exit-code`
- Run manually: `nix fmt`

### Module Structure
Every Nix module follows this pattern:

```nix
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # imports (if applicable)
  # options (if defining options)
  # config (the actual configuration)
}
```

### Section Headers
Sections are separated with emoji-prefixed comments:

```nix
  # ── Section Title ─────────────────────────────────────────
```

### Platform Gating
Platform-specific config uses `lib.mkIf`:

```nix
programs.kitty = lib.mkIf pkgs.stdenv.isLinux { ... };
xdg.configFile.\"ghostty/config\" = lib.mkIf pkgs.stdenv.isDarwin { ... };
```

Linux-only packages use `lib.optionals`:

```nix
home.packages = with pkgs; [ ... ]
  ++ lib.optionals pkgs.stdenv.isLinux [ ... ]
  ++ lib.optionals pkgs.stdenv.isDarwin [ ... ];
```

### String Interpolation
- Uses Nix indented strings (`''...''`) for multi-line content (tmux config, shell hooks)
- Knows that in `''...''`, `\` is literal, `''` becomes `'`, and `''${` starts interpolation
- Regular strings (`"..."`) for simple values

### Flake Patterns
- `inputs` destructured at the top using `inputs@{ ... }` pattern
- `specialArgs` used to pass extra args (like `dotfiles`, `unstable`, `unstableDarwin`)
- Home Manager integrated as a NixOS/darwin module (not standalone)
- Shared `homeConfig` function avoids duplication

### Nix Idioms Used
- `inherit` — for attribute extraction
- `with pkgs;` — for package access (used consistently but sparingly in package lists)
- `lib.mkIf` — for conditional config
- `lib.optionals` — for conditional package lists
- `lib.mkDefault` — for default values that can be overridden (e.g., `hardware-configuration.nix`)
- `let ... in` — for local bindings

## Module Organization

### home/default.nix (Module Index)
Imports all home modules in a flat list. No sub-imports beyond this file.

### Module Responsibilities
Each module has a single responsibility:

| Module | Responsibility |
|---|---|
| `aliases.nix` | Cross-shell aliases only |
| `dotfiles-links.nix` | xdg.configFile symlinks only |
| `editors.nix` | Neovim + Helix (no other editors) |
| `env.nix` | Environment, PATH, direnv, fzf, zoxide, mise |
| `ghostty.nix` | Empty placeholder (config in dotfiles) |
| `git.nix` | Git, gh, lazygit (no other VCS tools) |
| `packages.nix` | All user packages list |
| `shell.nix` | Zsh + Fish (full shell config) |
| `terminal.nix` | Kitty, Tmux, Zellij (all terminals) |

## Error Handling

- Silenced errors pattern (e.g., `2>/dev/null || true`) — acknowledged as potentially hiding issues (CodeRabbit item #2)
- `force = true` pattern — acknowledged as potentially destructive (CodeRabbit item #1)

## Deprecated/Suboptimal Patterns (Known)

These patterns are present but identified as suboptimal (from CodeRabbit review):

1. `force = true` on `xdg.configFile."nvim"` — silently deletes existing directory
2. `nvim --headless` failures silenced with `2>/dev/null || true`
3. Hand-rolled Mise activation instead of `programs.mise`
4. `mise` duplicated in `packages.nix` and `env.nix`
5. `initExtraFirst`/`initExtra` deprecated — should use `initContent` + `lib.mkOrder`
6. Duplicate `nixpkgs-unstable` import blocks in `flake.nix`
