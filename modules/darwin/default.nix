{
  config,
  pkgs,
  lib,
  ...
}:

{
  # This module contains darwin-specific configurations that apply
  # only to macOS. System-level config lives in darwin.nix;
  # this is for shared darwin module options.

  # ── Touch ID for sudo ───────────────────────────────────────
  # Note: security.pam.enableSudoTouchIdAuth was deprecated in nix-darwin after 24.11
  security.pam.services.sudo_local.touchIdAuth = true;

  # ── Shell completion paths ─────────────────────────────────
  environment.pathsToLink = [
    "/share/zsh"
    "/share/fish"
  ];
}
