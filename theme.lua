--------------------------
-- Default luakit theme --
--------------------------

local theme = {}

-- Default settings
theme.font = "Clean 10"
theme.fg   = "#fff"
theme.bg   = "#000"

-- Genaral colours
theme.success_fg = "#0f0"
theme.loaded_fg  = "#33AADD"
theme.error_fg = "#FFF"
theme.error_bg = "#F00"

-- Warning colours
theme.warning_fg = "#F00"
theme.warning_bg = "#FFF"

-- Notification colours
theme.notif_fg = "#CCC"
theme.notif_bg = "#000"

-- Menu colours
theme.menu_fg                   = "#fff"
theme.menu_bg                   = "#000"
theme.menu_selected_fg          = "#fff"
theme.menu_selected_bg          = "#00F"
theme.menu_title_bg             = "#000"
theme.menu_primary_title_fg     = "#00f"
theme.menu_secondary_title_fg   = "#666"

-- Proxy manager
theme.proxy_active_menu_fg      = '#FFF'
theme.proxy_active_menu_bg      = '#000'
theme.proxy_inactive_menu_fg    = '#FFF'
theme.proxy_inactive_menu_bg    = '#888'

-- Statusbar specific
theme.sbar_fg         = "#fff"
theme.sbar_bg         = "#000"

-- Downloadbar specific
theme.dbar_fg         = "#fff"
theme.dbar_bg         = "#000"
theme.dbar_error_fg   = "#F00"

-- Input bar specific
theme.ibar_fg           = "#fff"
theme.ibar_bg           = "#000"

-- Tab label
theme.tab_fg            = "#888"
theme.tab_bg            = "#222"
theme.tab_ntheme        = "#ddd"
theme.selected_fg       = "#fff"
theme.selected_bg       = "#000"
theme.selected_ntheme   = "#ddd"
theme.loading_fg        = "#33AADD"
theme.loading_bg        = "#000"

-- Trusted/untrusted ssl colours
theme.trust_fg          = "#0F0"
theme.notrust_fg        = "#F00"

return theme
-- vim: et:sw=4:ts=8:sts=4:tw=80
