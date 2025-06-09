{...}: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require('wezterm')
      local config = wezterm.config_builder()

      -- Color scheme (Catppuccin Mocha)
      config.color_scheme = 'Catppuccin Mocha'

      -- Font configuration (using system default Iosevka)
      config.font_size = 12.0
      config.line_height = 1.1

      -- Tab bar customization - completely hidden
      config.use_fancy_tab_bar = false
      config.hide_tab_bar_if_only_one_tab = true
      config.tab_bar_at_bottom = false
      config.show_tab_index_in_tab_bar = false
      config.show_tabs_in_tab_bar = false

      -- Window appearance
      config.window_padding = {
        left = 10,
        right = 10,
        top = 10,
        bottom = 10,
      }
      config.window_background_opacity = 0.95
            config.window_close_confirmation = 'AlwaysPrompt'
      config.scrollback_lines = 10000

      -- Cursor appearance
      config.cursor_blink_rate = 800
      config.default_cursor_style = 'SteadyBar'
      config.cursor_thickness = 2

      -- Custom key bindings
      config.keys = {
        -- Split panes
        { key = '|', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
        { key = '_', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }) },

        -- Navigate panes
        { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection('Left') },
        { key = 'RightArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection('Right') },
        { key = 'UpArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection('Up') },
        { key = 'DownArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection('Down') },

        -- Resize panes
        { key = 'LeftArrow', mods = 'CTRL|SHIFT|ALT', action = wezterm.action.AdjustPaneSize({ 'Left', 5 }) },
        { key = 'RightArrow', mods = 'CTRL|SHIFT|ALT', action = wezterm.action.AdjustPaneSize({ 'Right', 5 }) },
        { key = 'UpArrow', mods = 'CTRL|SHIFT|ALT', action = wezterm.action.AdjustPaneSize({ 'Up', 3 }) },
        { key = 'DownArrow', mods = 'CTRL|SHIFT|ALT', action = wezterm.action.AdjustPaneSize({ 'Down', 3 }) },

        -- Tab management
        { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab('CurrentPaneDomain') },
        { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab({ confirm = true }) },

        -- Font size
        { key = '=', mods = 'CTRL', action = wezterm.action.IncreaseFontSize },
        { key = '-', mods = 'CTRL', action = wezterm.action.DecreaseFontSize },
        { key = '0', mods = 'CTRL', action = wezterm.action.ResetFontSize },
      }

      -- URL handling
      config.hyperlink_rules = wezterm.default_hyperlink_rules()
      table.insert(config.hyperlink_rules, {
        regex = [[(https?://[a-zA-Z0-9.-]+\.[a-zA-Z0-9]{2,}[a-zA-Z0-9/%.?=_-]*)]],
        format = '$0',
      })

      -- Additional visuals
      config.inactive_pane_hsb = {
        saturation = 0.8,
        brightness = 0.7,
      }

      -- No status bar

      return config
    '';
  };
}
