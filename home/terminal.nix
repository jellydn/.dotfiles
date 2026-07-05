{ config, pkgs, lib, ... }:

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
      bind r source-file ~/.config/tmux/tmux.conf \\; display "Config reloaded!"

      # Edit config
      bind e new-window -n "tmux.conf" "nvim ~/.config/tmux/tmux.conf && tmux source-file ~/.config/tmux/tmux.conf && tmux display-message 'Config reloaded!'"

      # Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Window navigation
      bind-key Tab next-window
      bind-key BTab previous-window

      # Vim-style copy mode
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Smart pane switching with Vim awareness
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \\\n        | grep -iqE '^[^TXZ ]+ +(\\\\S+\\\\/)?g?(view|l?n?vim?x?|fzf|lazygit)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \\
        "bind-key -n 'C-\\' if-shell \\\"$is_vim\\\" 'send-keys C-\\' 'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \\
        "bind-key -n 'C-\\' if-shell \\\"$is_vim\\\" 'send-keys C-\\\\\\' 'select-pane -l'"

      # Copy mode vim-aware navigation
      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R

      # Smart scrolling
      bind-key -n PageUp if-shell "$is_vim" 'send-keys PageUp' 'copy-mode -u'
      bind-key -n PageDown if-shell "$is_vim" 'send-keys PageDown' 'send-keys PageDown'

      # URL handling - extract and open
      bind-key u capture-pane \\; save-buffer /tmp/tmux-buffer \\; new-window -n urls '$SHELL -c "grep -oE \\\"https?://[a-zA-Z0-9./?=_%:-]*\\\" /tmp/tmux-buffer | sort -u | fzf --prompt=\\\"Open URL: \\\" --bind=\\\"enter:execute(open {})\\\""'
      bind-key C-u capture-pane \\; save-buffer /tmp/tmux-buffer \\; run-shell 'grep -oE "https?://[a-zA-Z0-9./?=_%:-]*" /tmp/tmux-buffer | head -1 | pbcopy' \\; display-message "URL copied to clipboard"

      # OSC52 clipboard
      set -g @copy_use_osc52_fallback on

      # Machine-specific overrides
      if-shell "test -f $HOME/.config/tmux/local.conf" "source-file $HOME/.config/tmux/local.conf"
    '';

    # TPM plugins
    # TPM is initialized automatically by home-manager
    plugins = with pkgs.tmuxPlugins; [
      tpm
      vim-tmux-navigator
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
    ];
  };

  # ── Zellij ──────────────────────────────────────────────────
  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      ui.pane_frames.hide_session_name = true;
    };
    # Complex keybindings as raw KDL via extraConfig (avoids attrset→KDL conversion issues)
    extraConfig = ''
      keybinds {
        normal {
          unbind "Ctrl p"
          unbind "Ctrl t"
          unbind "Ctrl n"
          unbind "Ctrl s"
          unbind "Ctrl o"
          unbind "Ctrl h"
          unbind "Ctrl b"
          unbind "Ctrl g"
        }
        locked {
          bind "Ctrl a" "g" { SwitchToMode "Normal"; }
        }
        resize {
          bind "h" "Left" { Resize "Increase Left"; }
          bind "j" "Down" { Resize "Increase Down"; }
          bind "k" "Up" { Resize "Increase Up"; }
          bind "l" "Right" { Resize "Increase Right"; }
          bind "H" { Resize "Decrease Left"; }
          bind "J" { Resize "Decrease Down"; }
          bind "K" { Resize "Decrease Up"; }
          bind "L" { Resize "Decrease Right"; }
          bind "=" "+" { Resize "Increase"; }
          bind "-" { Resize "Decrease"; }
        }
        pane {
          bind "h" "Left" { MoveFocus "Left"; }
          bind "l" "Right" { MoveFocus "Right"; }
          bind "j" "Down" { MoveFocus "Down"; }
          bind "k" "Up" { MoveFocus "Up"; }
          bind "o" { SwitchFocus; }
          bind "n" { NewPane; SwitchToMode "Normal"; }
          bind "d" { NewPane "Down"; SwitchToMode "Normal"; }
          bind "v" { NewPane "Right"; SwitchToMode "Normal"; }
          bind "x" { CloseFocus; SwitchToMode "Normal"; }
          bind "f" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
          bind "z" { TogglePaneFrames; SwitchToMode "Normal"; }
          bind "w" { ToggleFloatingPanes; SwitchToMode "Normal"; }
          bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
          bind "c" { SwitchToMode "RenamePane"; PaneNameInput 0; }
        }
        move {
          bind "n" "Tab" { MovePane; }
          bind "p" { MovePaneBackwards; }
          bind "h" "Left" { MovePane "Left"; }
          bind "j" "Down" { MovePane "Down"; }
          bind "k" "Up" { MovePane "Up"; }
          bind "l" "Right" { MovePane "Right"; }
        }
        tab {
          bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
          bind "h" "Left" "Up" "k" { GoToPreviousTab; }
          bind "l" "Right" "Down" "j" { GoToNextTab; }
          bind "n" { NewTab; SwitchToMode "Normal"; }
          bind "x" { CloseTab; SwitchToMode "Normal"; }
          bind "s" { ToggleActiveSyncTab; SwitchToMode "Normal"; }
          bind "b" { BreakPane; SwitchToMode "Normal"; }
          bind "]" { BreakPaneRight; SwitchToMode "Normal"; }
          bind "[" { BreakPaneLeft; SwitchToMode "Normal"; }
          bind "1" { GoToTab 1; SwitchToMode "Normal"; }
          bind "2" { GoToTab 2; SwitchToMode "Normal"; }
          bind "3" { GoToTab 3; SwitchToMode "Normal"; }
          bind "4" { GoToTab 4; SwitchToMode "Normal"; }
          bind "5" { GoToTab 5; SwitchToMode "Normal"; }
          bind "6" { GoToTab 6; SwitchToMode "Normal"; }
          bind "7" { GoToTab 7; SwitchToMode "Normal"; }
          bind "8" { GoToTab 8; SwitchToMode "Normal"; }
          bind "9" { GoToTab 9; SwitchToMode "Normal"; }
          bind "Tab" { ToggleTab; }
        }
        scroll {
          bind "e" { EditScrollback; SwitchToMode "Normal"; }
          bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
          bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
          bind "j" "Down" { ScrollDown; }
          bind "k" "Up" { ScrollUp; }
          bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
          bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
          bind "d" { HalfPageScrollDown; }
          bind "u" { HalfPageScrollUp; }
        }
        search {
          bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
          bind "j" "Down" { ScrollDown; }
          bind "k" "Up" { ScrollUp; }
          bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
          bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
          bind "d" { HalfPageScrollDown; }
          bind "u" { HalfPageScrollUp; }
          bind "n" { Search "down"; }
          bind "p" { Search "up"; }
          bind "c" { SearchToggleOption "CaseSensitivity"; }
          bind "w" { SearchToggleOption "Wrap"; }
          bind "o" { SearchToggleOption "WholeWord"; }
        }
        entersearch {
          bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
          bind "Enter" { SwitchToMode "Search"; }
        }
        renametab {
          bind "Ctrl c" { SwitchToMode "Normal"; }
          bind "Esc" { UndoRenameTab; SwitchToMode "Tab"; }
        }
        renamepane {
          bind "Ctrl c" { SwitchToMode "Normal"; }
          bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
        }
        session {
          bind "s" { SwitchToMode "Scroll"; }
          bind "d" { Detach; }
          bind "w" {
            LaunchOrFocusPlugin "session-manager" {
              floating true
              move_to_focused_tab true
            };
            SwitchToMode "Normal"
          }
        }
        tmux {
          bind "Ctrl a" { Write 1; SwitchToMode "Normal"; }
          bind "g" { SwitchToMode "Locked"; }
          bind "p" { SwitchToMode "Pane"; }
          bind "t" { SwitchToMode "Tab"; }
          bind "r" { SwitchToMode "Resize"; }
          bind "m" { SwitchToMode "Move"; }
          bind "s" { SwitchToMode "Scroll"; }
          bind "o" { SwitchToMode "Session"; }
          bind "[" { SwitchToMode "Scroll"; }
          bind "\"" { NewPane "Down"; SwitchToMode "Normal"; }
          bind "%" { NewPane "Right"; SwitchToMode "Normal"; }
          bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
          bind "c" { NewTab; SwitchToMode "Normal"; }
          bind "," { SwitchToMode "RenameTab"; }
          bind "n" { GoToNextTab; SwitchToMode "Normal"; }
          bind "h" "Left" { MoveFocus "Left"; SwitchToMode "Normal"; }
          bind "l" "Right" { MoveFocus "Right"; SwitchToMode "Normal"; }
          bind "j" "Down" { MoveFocus "Down"; SwitchToMode "Normal"; }
          bind "k" "Up" { MoveFocus "Up"; SwitchToMode "Normal"; }
          bind "d" { Detach; }
        }
      }
    '';
  };
}
