{ config, pkgs, ... }:

{
  # ── Environment Variables ────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    LESS = "-R";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    PNPM_HOME = "$HOME/.local/share/pnpm";
  };

  # ── Session Path ─────────────────────────────────────────────
  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "$HOME/.local/bin"
    "$HOME/.bun/bin"
    "$HOME/.deno/bin"
    "$HOME/.local/share/pnpm"
  ];

  # ── Mise (Dev environment manager from dotfiles) ────────────
  home.packages = with pkgs; [
    mise
  ];

  programs.bash = {
    enable = true;
    initExtra = ''
      if command -v mise &>/dev/null; then
        eval "$(mise activate bash)"
      fi
    '';
  };

  # ── Direnv ───────────────────────────────────────────────────
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    nix-direnv = {
      enable = true;
    };
    config = {
      whitelist = {
        exact = [ ".envrc" ];
      };
    };
  };

  # ── FZF ──────────────────────────────────────────────────────
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };

  # ── Zoxide (Smarter cd) ─────────────────────────────────────
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    options = [
      "--cmd"
      "cd"
    ];
  };
}
