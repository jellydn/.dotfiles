{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Huynh Duc Dung";
    userEmail = "dunghd.it@gmail.com";

    extraConfig = {
      core = {
        editor = "nvim";
        excludesfile = "~/.gitignore_global";
      };
      init = {
        defaultBranch = "main";
      };
      credential = {
        helper = "!gh auth git-credential";
      };
    };

    # Git LFS
    lfs = {
      enable = true;
    };

    # Global gitignore patterns
    ignores = [
      "*~"
      ".DS_Store"
      "**/.claude/settings.local.json"
    ];

    # Delta as diff/pager tool (auto-sets interactive.diffFilter)
    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = false;
        dark = true;
      };
    };

    # Aliases (from dotfiles)
    aliases = {
      # Basic
      a = "add";
      aa = "add --all";
      ap = "add --patch";
      c = "commit -v";
      ca = "commit --amend";
      cane = "commit --amend --no-edit";
      d = "diff";
      ds = "diff --staged";
      l = "log --oneline --graph";
      lg = "log --oneline --graph --all";
      ll = "log --oneline";
      s = "status --short";
      st = "status";
      p = "push";
      pf = "push --force-with-lease";
      pl = "pull --rebase";
      f = "fetch";
      b = "branch";
      co = "checkout";
      cob = "checkout -b";
      m = "merge";
      rb = "rebase";
      rbi = "rebase --interactive";
      cp = "cherry-pick";
      # Stash
      sa = "stash apply";
      sl = "stash list";
      sp = "stash pop";
      ss = "stash save";
      # Remote
      rv = "remote -v";
      rs = "remote show";
      # Fixup
      fu = "commit --fixup";
      squash = "rebase --interactive --autosquash";
      # Misc
      amend = "commit --amend --no-edit";
      clean = "clean -fd";
      prune = "remote prune origin";
      tags = "tag --sort=-version:refname";
      undo = "reset HEAD~1 --mixed";
      wip = "add --all && git commit -m 'wip'";
    };
  };

  # ── gh (GitHub CLI) ─────────────────────────────────────────
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
        prs = "pr list --state=open --limit=20";
      };
    };
  };

  # ── LazyGit ─────────────────────────────────────────────────
  # Config is symlinked from dotfiles repo via home/dotfiles-links.nix
  programs.lazygit = {
    enable = true;
  };
}
