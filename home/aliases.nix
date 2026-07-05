{ config, pkgs, ... }:

{
  home.shellAliases = {
    # Editor aliases
    v = "nvim";
    vi = "nvim";
    vim = "nvim";
    nv = "nvim";
    lvim = "nvim";

    # General
    cat = "bat";
    ls = "eza --icons=always";
    ll = "eza -la --icons=always";
    la = "eza -a --icons=always";
    lt = "eza --tree --icons=always";
    l = "eza -l --icons=always";
    lg = "lazygit";
    grep = "rg";
    find = "fd";
    ps = "procs";
    du = "dust";
    df = "duf";
    top = "htop";
    tree = "tree -C";

    # Nix (platform-specific rebuild aliases)
    ndev = "nix develop";
    nsh = "nix shell";
    nix-search = "nix search nixpkgs";

    # Misc
    cls = "clear";
    reload = "exec $SHELL -l";
    dots = "cd ~/Projects/dotfiles";
    mine = "cd ~/src";
    try = "~/.local/bin/try";
  };
}
