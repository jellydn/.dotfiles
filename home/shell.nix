{ config, pkgs, ... }:

{
  # ── Zsh ─────────────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    history = {
      size = 100000;
      save = 100000;
      share = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      path = "$HOME/.zsh_history";
    };

    # initExtraFirst runs early in zsh startup
    initExtraFirst = ''
      # Initialize Pure prompt
      fpath+=("${pkgs.pure-prompt}/share/zsh/site-functions")
      autoload -U promptinit && promptinit && prompt pure
    '';

    initExtra = ''
      # Atuin shell history
      if command -v atuin &>/dev/null; then
        eval "$(atuin init zsh)"
      fi

      # FZF
      if command -v fzf &>/dev/null; then
        source <(fzf --zsh)
      fi

      # Finalize mise
      if command -v mise &>/dev/null; then
        eval "$(mise activate zsh)"
      fi

      # Locale
      export LANG="en_US.UTF-8"
      export LC_ALL="en_US.UTF-8"
    '';
  };

  # Zsh plugin packages
  home.packages = with pkgs; [
    pure-prompt # Pure prompt
    atuin # Shell history
    zoxide # Smarter cd
    direnv # Environment switcher
  ];

  # ── Fish ────────────────────────────────────────────────────
  programs.fish = {
    enable = true;

    # Interactive shell initialization
    interactiveShellInit = ''
      # Kanagawa theme for fish
      set -g fish_color_normal c8d3f5
      set -g fish_color_command 7e9cd8
      set -g fish_color_param 9ece6a
      set -g fish_color_error e26a7a
      set -g fish_color_quote b3f1c8
      set -g fish_color_redirection e6c384
      set -g fish_color_end 957fb8
      set -g fish_color_comment 545a6e
      set -g fish_color_selection --background=2d334a
      set -g fish_color_search_match --background=2d334a
      set -g fish_color_operator 9ece6a
      set -g fish_color_escape 7e9cd8
      set -g fish_color_autosuggestion 545a6e
      set -g fish_color_cwd 9ece6a
      set -g fish_color_user 7e9cd8
      set -g fish_color_host 9ece6a
      set -g fish_color_host_remote 9ece6a
      set -g fish_color_cancel e26a7a

      # Pager colors
      set -g fish_pager_color_progress 545a6e
      set -g fish_pager_color_prefix 7e9cd8
      set -g fish_pager_color_completion c8d3f5
      set -g fish_pager_color_description 545a6e
      set -g fish_pager_color_selected_background --background=2d334a

      # Mise integration
      if command -v mise &>/dev/null
        mise activate fish | source
      end

      # Zoxide lazy-load
      if command -v zoxide &>/dev/null
        zoxide init fish | source
      end

      # Source Cargo env
      if test -f ~/.cargo/env.fish
        source ~/.cargo/env.fish
      end

      # Source cmdk
      if test -f ~/.cmdk/cmdk.fish
        source ~/.cmdk/cmdk.fish
      end

      # Claude CLI alias
      if test -x ~/.claude/local/claude
        alias claude="~/.claude/local/claude"
      end

      # Optional tool paths
      if test -d "$HOME/.opencode/bin"
        fish_add_path "$HOME/.opencode/bin"
      end
      if test -d "$HOME/.grok/bin"
        fish_add_path "$HOME/.grok/bin"
      end
    '';

    # ── Custom functions (from dotfiles) ─────────────────────
    functions = {
      try = {
        description = "Run a command in a try environment";
        body = ''
          set -l out (~/.local/share/mise/installs/ruby/latest/bin/try exec --path ~/src/tries $argv 2>/dev/tty | string collect)
          if test $pipestatus[1] -eq 0
            eval $out
          else
            echo $out
          end
        '';
      };
      try-dev = {
        description = "Run a command in try-dev environment";
        body = ''
          set -l out (/usr/bin/env ruby ~/.local/bin/try-dev exec --path ~/src/tries $argv 2>/dev/tty | string collect)
          if test $pipestatus[1] -eq 0
            eval $out
          else
            echo $out
          end
        '';
      };
    };

    # Git abbreviations (from dotfiles)
    shellAbbrs = {
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gap = "git add --patch";
      gb = "git branch";
      gc = "git commit -v";
      gca = "git commit --amend";
      gcane = "git commit --amend --no-edit";
      gco = "git checkout";
      gcob = "git checkout -b";
      gcp = "git cherry-pick";
      gd = "git diff";
      gds = "git diff --staged";
      gf = "git fetch";
      gl = "git log --oneline --graph";
      glg = "git log --oneline --graph --all";
      gll = "git log --oneline";
      gm = "git merge";
      gp = "git push";
      gpf = "git push --force-with-lease";
      gpl = "git pull --rebase";
      gr = "git remote";
      grb = "git rebase";
      grbi = "git rebase --interactive";
      grv = "git remote -v";
      gs = "git status --short";
      gst = "git status";
      gsa = "git stash apply";
      gsl = "git stash list";
      gsp = "git stash pop";
      gss = "git stash save";
      gtags = "git tag --sort=-version:refname";
    };

    shellAliases = {
      cat = "bat";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      lg = "lazygit";
    };
  };
}
