# nix-darwin configuration for macOS (itman / dunghd)
{
  config,
  pkgs,
  lib,
  unstableDarwin,
  ...
}:

{
  # ── System ─────────────────────────────────────────────────
  # Identify the primary user for user-level settings (dock, finder, homebrew)
  system.primaryUser = "huynhdung";

  system.defaults = {
    # Finder
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXPreferredViewStyle = "Nlsv";
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    # Dock
    dock = {
      autohide = true;
      show-recents = false;
      tilesize = 48;
      orientation = "bottom";
      minimize-to-application = true;
      persistent-apps = [
        "/Applications/Ghostty.app"
        "/Applications/Cursor.app"
        "/Applications/Zed Preview.app"
      ];
    };

    # Trackpad
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
    };      # Keyboard — keyRepeat/initialKeyRepeat require newer nix-darwin
      # (locked revision doesn't support these yet)

    # Security
    screensaver.askForPasswordDelay = 5;
  };

  # ── Networking ─────────────────────────────────────────────
  networking = {
    computerName = "itman";
    hostName = "dunghd";
    localHostName = "itman-2";
  };

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
        "huynhdung"
      ];
    };
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      };
      options = "--delete-older-than 7d";
    };
    # Extra nix.conf settings
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };

  # ── System Packages (macOS-specific) ───────────────────────
  environment.systemPackages = with pkgs; [
    # Core utilities not available via home-manager
    coreutils
    findutils
    gnutar
    gnused
    gnugrep
    gawk

    # macOS-specific tools
    m-cli # macOS command-line tools
    mas # Mac App Store CLI
    htop
    btop
  ];

  # ── Fonts ──────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.inconsolata
    maple-mono.Normal-NF
  ];

  # ── Shell ──────────────────────────────────────────────────
  programs.fish.enable = true;
  programs.zsh.enable = true;

  # ── Services ───────────────────────────────────────────────
  # services.nix-daemon.enable has been removed in nix-darwin 26.x — nix.enable manages the daemon automatically.

  # ── Allow Unfree ───────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  # ── Homebrew (managed by nix-darwin) ───────────────────────
  # Note: Homebrew itself must be installed manually first.
  # nix-darwin will then keep it in sync with this config.
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall"; # Remove packages not in the list
      upgrade = true;
    };

    # Taps (fonts are installed via Nix in fonts.packages above)
    taps = [ ];

    # Brews (CLI tools — complements Nix packages)
    brews = [
      # Already installed on this Mac
      "awscli"
      "azure-cli"
      "kubernetes-cli"
      "helm"
      "terraform"
      "fastlane"
      "cocoapods"
      "exercism"
      "ast-grep"
      "gitbutler"
    ];

    # Casks (GUI applications — the ones you asked for)
    casks = [
      "ghostty"
      "cursor"
      "orbstack"
      "zed@preview"
    ];
  };

  # ── State Version ──────────────────────────────────────────
  system.stateVersion = 7;
}
