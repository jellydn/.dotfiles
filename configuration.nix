# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{
  config,
  pkgs,
  lib,
  unstable,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # ── Bootloader ─────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Networking ─────────────────────────────────────────────
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ── Time / Locale ──────────────────────────────────────────
  time.timeZone = "Asia/Singapore";
  i18n.defaultLocale = "en_SG.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_SG.UTF-8";
    LC_IDENTIFICATION = "en_SG.UTF-8";
    LC_MEASUREMENT = "en_SG.UTF-8";
    LC_MONETARY = "en_SG.UTF-8";
    LC_NAME = "en_SG.UTF-8";
    LC_NUMERIC = "en_SG.UTF-8";
    LC_PAPER = "en_SG.UTF-8";
    LC_TELEPHONE = "en_SG.UTF-8";
    LC_TIME = "en_SG.UTF-8";
  };

  # ── Display / Desktop ──────────────────────────────────────
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ── Printing ───────────────────────────────────────────────
  services.printing.enable = true;

  # ── Sound (PipeWire) ───────────────────────────────────────
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── User Account ───────────────────────────────────────────
  users.users.dunghd = {
    isNormalUser = true;
    description = "Dung Huynh Duc";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "docker"
    ];
    shell = pkgs.fish;
  };

  # ── Security ───────────────────────────────────────────────
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # ── Services ───────────────────────────────────────────────
  services.openssh.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  # ── Fonts ──────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.inconsolata      nerd-fonts.terminess-ttf
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ];

  # ── Programs ───────────────────────────────────────────────
  programs.fish.enable = true;
  programs.firefox.enable = true;
  programs.dconf.enable = true;
  programs.nix-ld.enable = true;

  # ── Nix Settings ───────────────────────────────────────────
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "dunghd"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # ── Allow Unfree ───────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  # ── System Packages (minimal — most are in home-manager) ──
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    jq
    unzip
  ];

  # ── State Version ──────────────────────────────────────────
  system.stateVersion = "26.05";
}
