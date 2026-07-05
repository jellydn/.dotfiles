{ config, pkgs, lib, ... }:

{
  # This module contains NixOS-specific configurations that apply
  # only to the aarch64-linux NixOS machine.
  # System-level config lives in configuration.nix;
  # this is for shared NixOS module options.

  # ── Hardware tweaks ─────────────────────────────────────────
  hardware.enableRedistributableFirmware = true;

  # ── Zram (swap compression) ─────────────────────────────────
  zramSwap.enable = true;

  # ── Systemd services ───────────────────────────────────────
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
