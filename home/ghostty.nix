{ config, pkgs, lib, ... }:

{
  # ── Ghostty Terminal (macOS only) ───────────────────────────
  # Config file managed via xdg.configFile to match dotfiles layout
  xdg.configFile."ghostty/config" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      # Ghostty configuration - managed by home-manager
      # Reload: macOS: cmd+shift+,
      # Refer to https://ghostty.org/docs

      # Theme
      theme = kanagawa-wave

      # Font family
      font-family = "Maple Mono NF"
      font-family-bold = "Maple Mono NF Medium"
      font-family-italic = "Maple Mono NF Book Italic"
      font-family-bold-italic = "Maple Mono NF Medium Italic"

      # Font size (18 on large screen, adjust as needed)
      font-size = 18

      # Background
      background-opacity = 0.98

      # Window padding
      window-padding-x = 5
      window-padding-y = 5
      unfocused-split-opacity = 0.85

      # Hide title
      title = " "

      # macOS titlebar style: tabs, native, transparent, or hidden
      macos-titlebar-style = tabs

      # Hide cursor while typing
      mouse-hide-while-typing = true

      # No need to confirm close
      confirm-close-surface = false

      # Shell integration
      shell-integration = fish

      # Copy on select
      copy-on-select = true

      # URL detection
      link-url = true

      # Make Alt/Option key work with Zellij on macOS
      keybind = alt+left=unbind
      keybind = alt+right=unbind
      macos-option-as-alt = true

      # Quick terminal toggle
      keybind = global:cmd+grave_accent=toggle_quick_terminal

      # Ctrl+minus for neovim
      keybind = ctrl+minus=text:\x1f

      # Cmd+L for cmdk
      keybind = cmd+l=text:cmdk -s\r
    '';
  };

  # Ghostty GUI app is installed via Homebrew casks (darwin.nix),
  # not via Nix packages, to avoid duplication.
  # The config file above is still managed here.
}
