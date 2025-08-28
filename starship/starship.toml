local wezterm = require('wezterm')
local mux = wezterm.mux
local config = wezterm.config_builder()

wezterm.on("update-right-status", function(window, pane)
  local cells = {}

  -- Figure out the cwd and host of the current pane.
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    local cwd = ''
    local hostname = ''

    if type(cwd_uri) == 'userdata' then
      -- New version support
      cwd = cwd_uri.file_path
      hostname = cwd_uri.host or wezterm.hostname()
    else
      -- Wezterm old version (20230712-072601-f4abf8fd or earlier)
      cwd_uri = cwd_uri:sub(8)
      local slash = cwd_uri:sub(8)
      if slash then
        hostname = cwd_uri:find '/'
        cwd = cwd_uri:sub(slash);gsub('%%(%x%x)', function(hex)
          return string.char(tonumber(hex, 16))
        end)
      end
    end

    -- Remove the domain name portion of the hostname
    local dot = hostname:find '[.]'
    if dot then
      hostname = hostname:sub(1, dot -1)
    end
    if hostname == '' then
      hostname = wezterm.hostname()
    end

    table.insert(cells, cwd)
    table.insert(cells, hostname)
  end

  -- date/time
  local date = wezterm.strftime '%b %-d %H:%M'
  table.insert(cells, date)

  -- An entry for each battery (typically 0 or 1 battery)
  for _, b in ipairs(wezterm.battery_info()) do
    table.insert(cells, string.format('%.0f%%', b.state_of_charge * 100))
  end

  -- The powerline < symbol
  local LEFT_ARROW = utf8.char(0xe0b3)
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

  -- Color paletter for the backgrounds of each cell
  local colors = {
    '#d65d0e',
    '#d79921',
    '#689d6a',
    '#458588',
    '#cc241d',
    '#3c3836',
    '#665c54',
    '#458588',
    '#689d6a',
    '#98971a',
    '#d65d0e',
    '#b16286',
  }

  -- Foreground color for the text across the fade
  local text_fg = '#fbf1c7'

  -- The elements to be formatted
  local elements = {}

  -- How many cells have been formatted
  local num_cells = 0

  -- Translate a cell into elements
  function push(text, is_last)
    local cell_no = num_cells + 1
    if num_cells == 0 then
      table.insert(elements, { Foreground = { Color = colors[cell_no] } })
      table.insert(elements, { Background = { Color = "none" } })
      table.insert(elements, { Text = SOLID_LEFT_ARROW })
    end
    table.insert(elements, { Foreground = { Color = text_fg } })
    table.insert(elements, { Background = { Color = colors[cell_no] } })
    table.insert(elements, { Text = ' ' .. text .. ' '})
    if not is_last then
      table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
      table.insert(elements, { Text = SOLID_LEFT_ARROW })
    end
    num_cells = num_cells +1
  end

  while #cells > 0 do
    local cell = table.remove(cells, 1)
    push(cell, #cells == 0)
  end

  window:set_right_status(wezterm.format(elements))
end)

  -- 讓他有斜體跟底線(italic and underlined)
--   window:set_right_status(wezterm.format {
--     {Attribute = { Underline = 'Single' }},
--     {Attribute = { Italic = true }},
--     { Text = '我無奈 ' .. date },
--   })
-- end)

-- Tab bar 標籤樣式更改
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = '#5c6d74'
  local foreground = '#FFFFFF'
  local edge_background = 'none'
  if tab.is_active then
    background = '#B491C8'
    foreground = '#FFFFFF'
  end
  local edge_foreground = background
  local title = "  " .. wezterm.truncate_right(tab.active_pane.title, max_width -1) .. "  "
  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)
-- ==================
-- Basic Set
-- ==================
config.automatically_reload_config = true

-- ==================
-- Style set
-- ==================
-- color_scheme = 'Dracula'
config.color_scheme = 'Tokyo Night'
-- 隱藏視窗標題
config.window_decorations = 'RESIZE'  --"NONE", "RESIZE"

-- ==================
-- Tab and window
-- ==================
-- 背景設置
-- config.background = {
--   {
--     source = {
--       -- 圖片路徑(建議使用絕對路徑)
--       File = '$HOME\\img\\background',
--     },
--     resize = "NoScale",  -- 圖片縮放樣式
--     opacity = 0.4,  -- 圖片背景透明度
--   },
--   -- 終端背景顏色, 可以跟圖片一起混搭
--   {
--     source = { Color = 'rgba(30, 30, 30, 0.7)'},
--     height = '100%',
--     width = '100%',
--   }
-- }

config.window_background_opacity = 0.85  -- 透明度
-- config.macos_window_background_blur = 100  -- 模糊效果(macOS system)-- 圖片縮放樣式
-- config.win32_system_backdrop = 'Acrylic'  -- Windows system

-- 分割視窗邊框顏色
config.window_frame = {
  active_titlebar_bg = 'none',
  inactive_titlebar_bg = 'none',
}

-- 視窗背景顏色
config.window_background_gradient = {
  colors = {"#050505"},
}


config.tab_bar_at_bottom = true  -- 分頁欄位設置在視窗底部
config.colors = {
  selection_bg = '#2E2E2E',
  selection_fg = '#9F9F9F',
  tab_bar = {
    active_tab = {
      bg_color = '#2E2E2E',
      fg_color = '#FFFFFF',
    },
    inactive_tab = {
      bg_color = '#1E1E1E',
      fg_color = '#B0B0B0',
    },
  },
}

config.use_fancy_tab_bar = true  -- 分頁支援圖標
config.enable_tab_bar = true  -- 啟動分頁欄位
-- config.hide_tab_bar_if_only_one_tab = true  -- 只有一個分頁時隱藏
config.show_new_tab_button_in_tab_bar = false  -- 隱藏新增分頁按鈕

-- ==================
-- Lunch menu
-- ==================
-- 透過 LEADER + s 開啟
launch_menu = {
  {
    label = 'SSH felix_199',
    args = { 'ssh', 'fanice@felix_199'},
  },
}

-- ==================
-- Key map
-- ==================
config.leader = {key = 'a', mods = 'CTRL'}  -- LEADER 鍵
config.keys = {
    -- 視窗分割
    { key = '\\', mods = 'LEADER', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = '-', mods = 'LEADER', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },

    -- 退出當前視窗分割
    -- 按下 LEADER 後再按 q
    { key = 'q', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = true } },

    -- 在分割視窗中移動焦點
    -- Vim 風格
    { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Left') },
    { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Right') },
    { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Up') },
    { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Down') },

    -- 分頁切換
    { key = 'Tab', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1) },
    { key = 'Tab', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },

    -- 關閉分頁
    { key = 'w', mods = 'LEADER', action = wezterm.action.CloseCurrentTab { confirm = true } },

    -- 建立新分頁
    { key = 't', mods = 'LEADER', action = wezterm.action.SpawnTab('CurrentPaneDomain') },

    -- 開啟 launch_menu
    -- LEADER + s
    { key = 's', mods = 'LEADER', action = wezterm.action.ShowLauncher },

    -- 重新載入設定檔，方便調整
    { key = 'r', mods = 'LEADER', action = wezterm.action.ReloadConfiguration },

    -- 常用快捷鍵設定
    -- 複製
    -- { key = 'c', mods = 'LEADER', action = wezterm.action.CopyTo 'Clipboard' },
    -- 貼上
    -- { key = 'v', mods = 'LEADER', action = wezterm.action.PasteFrom 'Clipboard' },
  }

-- ==================
-- Other set
-- ==================
config.enable_kitty_graphics = true  -- 自動最大化視窗
config.enable_scroll_bar = false  -- 啟用滑鼠滾動
-- config.default_prog = {'powershell', '-NoLogo'}  -- 沒有 fish 的 windows
config.default_prog = {'C:\\Users\\felixhuang\\scoop\\apps\\msys2\\current\\usr\\bin\\fish.exe'}  -- 有 fish 的 windows
-- config.default_prog = {'/opt/homebrew/bin/fish'}  -- mac fish
config.use_ime = true  -- 啟用輸入法支援(適合中文輸入)
-- 設定 SSH 後端為 'Pty'
config.ssh_backend = 'LibSsh'

return config
