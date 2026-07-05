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
  security.pam.enableSudoTouchIdAuth = true;

  # ── Shell completion paths ─────────────────────────────────
  environment.pathsToLink = [
    "/share/zsh"
    "/share/fish"
  ];
}
