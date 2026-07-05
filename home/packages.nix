{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs;
    [
      # ── Essential CLI ──────────────────────────────────────
      curl
      wget
      jq
      unzip
      zip
      htop
      ripgrep
      fd
      bat
      eza
      fzf
      tree
      du-dust
      duf
      procs
      sd

      # ── Git / Dev Tools ────────────────────────────────────
      gh        # GitHub CLI
      lazygit
      git-lfs
      diff-so-fancy
      delta     # Git diff tool
      ghq       # Repository manager
      diffr     # Diff highlighting

      # ── Shell / Terminal ───────────────────────────────────
      fish
      zsh
      tmux
      direnv
      zoxide

      # ── Development Languages ──────────────────────────────
      nodejs_22
      deno
      bun
      go
      python3
      rustup
      gnumake
      cmake
      gcc

      # ── LSP / Formatting ───────────────────────────────────
      nil       # Nix LSP
      nixfmt-rfc-style
      statix
      deadnix
      nodePackages.biome
      nodePackages.prettier
      typos      # Spell checker

      # ── Misc Utilities ─────────────────────────────────────
      mise      # Dev environment manager
      just      # Command runner
      jj        # Jujutsu VCS (was jujutsu)
      yq        # YAML processor
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      # ── Linux-only ──────────────────────────────────────────
      xclip
      xsel
      wl-clipboard
      kitty
      playerctl
      mpc_cli
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      # ── macOS-only ──────────────────────────────────────────
      m-cli     # macOS CLI tools
    ];
}
