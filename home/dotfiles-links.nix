{ config, pkgs, lib, dotfiles, ... }:

let
  dotfilesCfg = "${dotfiles}/common/.config";
in
{
  # ── Helix Config ─────────────────────────────────────────────
  # Symlink the rich helix config.toml and languages.toml from dotfiles
  # (programs.helix only enables the package, no config file conflict)
  xdg.configFile."helix/config.toml" = {
    source = "${dotfilesCfg}/helix/config.toml";
    force = true;
  };
  xdg.configFile."helix/languages.toml" = {
    source = "${dotfiles}/helix/languages.toml";
    force = true;
  };

  # ── Ghostty Config ──────────────────────────────────────────
  # Symlink from dotfiles repo instead of generating inline config
  # (ghostty config is managed as a single file in the dotfiles repo)
  xdg.configFile."ghostty/config" = lib.mkIf pkgs.stdenv.isDarwin {
    source = "${dotfilesCfg}/ghostty/config";
    force = true;
  };

  # ── LazyGit Config ──────────────────────────────────────────
  # Symlink the Kanagawa-themed config.yml from dotfiles
  # Note: programs.lazygit.settings in git.nix is kept minimal
  xdg.configFile."lazygit/config.yml" = {
    source = "${dotfilesCfg}/lazygit/config.yml";
    force = true;
  };

  # ── Kitty Theme Files ───────────────────────────────────────
  # Symlink the Kanagawa theme and extras for kitty (Linux)
  # programs.kitty generates the main kitty.conf, these are extras
  xdg.configFile."kitty/Kanagawa.conf" = lib.mkIf pkgs.stdenv.isLinux {
    source = "${dotfilesCfg}/kitty/Kanagawa.conf";
    force = true;
  };
  xdg.configFile."kitty/current-theme.conf" = lib.mkIf pkgs.stdenv.isLinux {
    source = "${dotfilesCfg}/kitty/current-theme.conf";
    force = true;
  };
}
