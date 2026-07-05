{
  config,
  pkgs,
  dotfiles,
  ...
}:

let
  # Path to the dotfiles neovim config from flake input
  # Note: nvim is a git submodule (jellydn/tiny-nvim) in the dotfiles repo.
  # If fetched without submodules, this directory may be empty — nvim still works, just without custom config.
  dotfilesNvim = dotfiles + "/common/.config/nvim";
in
{
  # ── Neovim ──────────────────────────────────────────────────
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      # LSP servers (commonly used)
      nil # Nix
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted # HTML, CSS, JSON
      lua-language-server
      rust-analyzer
      gopls
      pyright
      # Formatters
      nodePackages.biome
      nodePackages.prettier
      nixfmt
      stylua
      # Tools
      ripgrep
      fd
      lazygit
    ];
  };

  # ── NeoVim config: symlink to dotfiles repo ─────────────────
  # Links ~/.config/nvim -> ~/Projects/dotfiles/common/.config/nvim
  # The dotfiles repo manages this as a git submodule (jellydn/tiny-nvim)
  xdg.configFile."nvim" = {
    source = dotfilesNvim;
    recursive = true;
    force = true; # Overrides existing directory to replace it with a symlink
    onChange = ''
      # After linking, install lazy.nvim and plugins
      if command -v nvim &>/dev/null; then
        nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
      fi
    '';
  };

  # ── Helix (also present in dotfiles) ─────────────────────────
  programs.helix = {
    enable = true;
  };
}
