{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ── Kitty Terminal (Linux only) ─────────────────────────────
  programs.kitty = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;

    settings = {
      # Font
      font_family = "JetBrainsMono Nerd Font";
      font_size = 13;
      adjust_line_height = 0;
      adjust_column_width = 0;

      # Cursor
      cursor_shape = "block";
      cursor_blink_interval = 0;

      # Scrollback
      scrollback_lines = 10000;
      scrollback_pager_history_size = 100;

      # Tab bar
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_title_template = "{title}{' : '}{fmt.fg.red}{bell_symbol}{fmt.fg.tab}{activity_symbol}";

      # Performance
      enabled_layouts = "tall:bias=50;full_size=1;mirror=false";

      # Shell
      shell = "${pkgs.fish}/bin/fish";
    };

    # Kanagawa theme colors
    extraConfig = ''
      # Kanagawa color scheme
      foreground #c8d3f5
      background #1f1f28
      selection_foreground #c8d3f5
      selection_background #2d334a
      url_color #7e9cd8
      cursor #c8d3f5
      cursor_text_color #1f1f28

      # Black
      color0 #1f1f28
      color8 #545a6e

      # Red
      color1 #e26a7a
      color9 #e26a7a

      # Green
      color2 #98bb6c
      color10 #98bb6c

      # Yellow
      color3 #e6c384
      color11 #e6c384

      # Blue
      color4 #7e9cd8
      color12 #7e9cd8

      # Magenta
      color5 #957fb8
      color13 #957fb8

      # Cyan
      color6 #6a9589
      color14 #6a9589

      # White
      color7 #c8d3f5
      color15 #dcd7ba

      # Mark
      mark1_background #2d334a
    '';
  };

  # ── Tmux ────────────────────────────────────────────────────
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    disableConfirmationPrompt = true;
    escapeTime = 10;
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";
    sensibleOnTop = true;
    shortcut = "a";
    terminal = "tmux-256color";
    newSession = true;
    reverseSplit = true;
    secureSocket = false;

    # In Nix indented strings (''...''), backslash is literal — no escaping needed.
    # Only '' becomes ' and ''${ starts interpolation. All other chars are literal.
    extraConfig = ''
      # Extended keys for modern terminals
      set -g extended-keys on

      # Start windows and panes at 1
      setw -g pane-base-index 1

      # Renumber windows when closed
      set -g renumber-windows on

      # Pane borders
      set -g pane-border-style "fg=#2A2A37"
      set -g pane-active-border-style "fg=#7fb4ca"
      set -g pane-border-lines "single"

      # Pane indicators
      set -g display-panes-colour "#7fb4ca"
      set -g display-panes-active-colour "#7fb4ca"

      # Message style
      set -g message-style "fg=#16161D,bg=#e6c384,bold"
      set -g message-command-style "fg=#e6c384,bg=#16161D,bold"

      # Mode style (copy mode)
      set -g mode-style "fg=#16161D,bg=#e6c384,bold"

      # Window status
      setw -g window-status-style "fg=#727169,bg=#16161D"
      setw -g window-status-format " #I #W#{?#{||:#{window_bell_flag},#{window_zoomed_flag}}, ,}#{?window_bell_flag,!,}#{?window_zoomed_flag,Z,} "
      setw -g window-status-current-style "fg=#16161D,bg=#7fb4ca,bold"
      setw -g window-status-current-format " #I #W#{?#{||:#{window_bell_flag},#{window_zoomed_flag}}, ,}#{?window_bell_flag,!,}#{?window_zoomed_flag,Z,} "

      # Window activity and bell
      setw -g window-status-activity-style "fg=default,bg=default,underscore"
      setw -g window-status-bell-style "fg=#e6c384,bg=default,blink,bold"

      # Status bar
      set -g status-left " ❐ #S "
      set -g status-right " #{?client_prefix,⌨ ,}#{?mouse,↗ ,}#{?synchronize-panes,⚏ ,}| #h "
      set -g status-left-style "fg=#16161D,bg=#e6c384,bold"
      set -g status-right-style "fg=#727169,bg=#16161D"
      set -g status-style "fg=#727169,bg=#16161D"

      # Clock mode
      set -g clock-mode-colour "#7fb4ca"
      set -g clock-mode-style 24

      # Terminal title
      set -g set-titles on
      set -g set-titles-string "#h ❐ #S ● #I #W"

      # New window/pane in current directory
      bind c new-window -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind _ split-window -h -c "#{pane_current_path}"

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

      # is_vim helper — single line, no escaping needed in Nix '' strings
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\S+/)?g?(view|l?n?vim?x?|fzf|lazygit)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\' 'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\' 'select-pane -l'"

      # Copy mode vim-aware navigation
      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R

      # Smart scrolling
      bind-key -n PageUp if-shell "$is_vim" 'send-keys PageUp' 'copy-mode -u'
      bind-key -n PageDown if-shell "$is_vim" 'send-keys PageDown' 'send-keys PageDown'

      # URL handling — open on macOS, xdg-open on Linux
      bind-key u capture-pane \; save-buffer /tmp/tmux-buffer \; new-window -n urls '$SHELL -c "grep -oE \"https?://[a-zA-Z0-9./?=_%:-]*\" /tmp/tmux-buffer | sort -u | fzf --prompt=\"Open URL: \" --bind=\"enter:execute(open {})\""'
      bind-key C-u capture-pane \; save-buffer /tmp/tmux-buffer \; run-shell '$SHELL -c "grep -oE \"https?://[a-zA-Z0-9./?=_%:-]*\" /tmp/tmux-buffer | head -1 | if command -v pbcopy &>/dev/null; then pbcopy; elif command -v wl-copy &>/dev/null; then wl-copy; elif command -v xclip &>/dev/null; then xclip -selection clipboard; else cat; fi"' \; display-message "URL copied to clipboard"

      # OSC52 clipboard
      set -g @copy_use_osc52_fallback on

      # Machine-specific overrides
      if-shell "test -f $HOME/.config/tmux/local.conf" "source-file $HOME/.config/tmux/local.conf"
    '';

    # TPM plugins
    # TPM is initialized automatically by home-manager
    # TPM is not packaged in Nixpkgs (incompatible with Nix's declarative model).
    # Home-manager handles plugin initialization automatically.
    plugins = [
      pkgs.tmuxPlugins.vim-tmux-navigator
      {
        plugin = pkgs.tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
    ];
  };

  # ── Zellij ──────────────────────────────────────────────────
  # Note: extraConfig for keybindings is not available in home-manager 26.05.
  # Keybindings use the default tmux mode (Ctrl+g) and can be customized
  # via ~/.config/zellij/config.kdl directly.
  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      ui.pane_frames.hide_session_name = true;
    };
  };
}
