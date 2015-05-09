require "lfs"

if unique then
    unique.new("org.luakit")
    -- Check for a running luakit instance
    if unique.is_running() then
        if uris[1] then
            for _, uri in ipairs(uris) do
                if lfs.attributes(uri) then uri = os.abspath(uri) end
                unique.send_message("tabopen " .. uri)
            end
        else
            unique.send_message("winopen")
        end
        luakit.quit()
    end
end

-- Load library of useful functions for luakit
require "lousy"

-- Small util functions to print output (info prints only when luakit.verbose is true)
function warn(...) io.stderr:write(string.format(...) .. "\n") end
function info(...) if luakit.verbose then io.stdout:write(string.format(...) .. "\n") end end

-- Load users global config
-- ("$XDG_CONFIG_HOME/luakit/globals.lua" or "/etc/xdg/luakit/globals.lua")
require "globals"

-- Load users theme
-- ("$XDG_CONFIG_HOME/luakit/theme.lua" or "/etc/xdg/luakit/theme.lua")
lousy.theme.init(lousy.util.find_config("theme.lua"))
theme = assert(lousy.theme.get(), "failed to load theme")

-- Load users window class
-- ("$XDG_CONFIG_HOME/luakit/window.lua" or "/etc/xdg/luakit/window.lua")
require "window"

-- Load users webview class
-- ("$XDG_CONFIG_HOME/luakit/webview.lua" or "/etc/xdg/luakit/webview.lua")
require "webview"

-- Load users mode configuration
-- ("$XDG_CONFIG_HOME/luakit/modes.lua" or "/etc/xdg/luakit/modes.lua")
require "modes"

-- Load users keybindings
-- ("$XDG_CONFIG_HOME/luakit/binds.lua" or "/etc/xdg/luakit/binds.lua")
require "binds"


----------------------------------
-- Optional user script loading --
----------------------------------

require "webinspector"

require "useragent"

-- Add sqlite3 cookiejar
require "cookies"

-- Cookie blocking by domain (extends cookies module)
-- Add domains to the whitelist at "$XDG_CONFIG_HOME/luakit/cookie.whitelist"
-- and blacklist at "$XDG_CONFIG_HOME/luakit/cookie.blacklist".
-- Each domain must be on it's own line and you may use "*" as a
-- wildcard character (I.e. "*google.com")
require "cookie_blocking"

-- Block all cookies by default (unless whitelisted)
cookies.default_allow = false

-- Add uzbl-like form filling
require "formfiller"

-- Add proxy support & manager
require "proxy"

-- Add quickmarks support & manager
require "quickmarks"

-- Add session saving/loading support
require "session"

-- Add command to list closed tabs & bind to open closed tabs
require "undoclose"

-- Add command to list tab history items
require "tabhistory"

-- Add greasemonkey-like javascript userscript support
require "userscripts"

-- Add bookmarks support
require "bookmarks"
require "bookmarks_chrome"

-- Add download support
require "downloads"
require "downloads_chrome"


-- Set download location                                                                                                                                               
downloads.default_dir = os.getenv("HOME") .. "/Downloads"


--Use of xdg-open for opening downloads
downloads.add_signal("open-file", function (file, mime)
    luakit.spawn(string.format("xdg-open %q", file))
    return true
end)

--Automatic view PDF files
webview.init_funcs.pdfview = function (view, w)
    view:add_signal("navigation-request", function (v, uri)
        if string.sub(string.lower(uri), -4) == ".pdf" then
            local url ="http://docs.google.com/gview?url="
            url = url .. uri
            url = url .. "&embedded=false"
            w:navigate(w:search_open(url))
        end
    end)
end



-- Add vimperator-like link hinting & following
require "follow"

-- Use a custom charater set for hint labels
local s = follow.label_styles
follow.label_maker = s.sort(s.reverse(s.charset("asdfqwerzy")))

-- Match only hint labels
--follow.pattern_maker = follow.pattern_styles.match_label

-- Add command history
require "cmdhist"

-- Add search mode & binds
require "search"

-- Add ordering of new tabs
require "taborder"

-- Save web history
require "history"
require "history_chrome"

require "introspector"

-- Add command completion
require "completion"

-- NoScript plugin, toggle scripts and or plugins on a per-domain basis.
-- `,ts` to toggle scripts, `,tp` to toggle plugins, `,tr` to reset.
-- Remove all "enable_scripts" & "enable_plugins" lines from your
-- domain_props table (in config/globals.lua) as this module will conflict.
require "noscript"
noscript.enable_scripts = false
noscript.enable_plugins = false 

require "follow_selected"
require "go_input"
require "go_next_prev"
require "go_up"


--enable scrollbars
webview.init_funcs.show_scrollbars = function(view) 
    view.show_scrollbars = true 
end


--browsing history (parched dmenu needed)
webview.methods.browse_hist_dmenu = function( view, w )
    local scripts_dir = luakit.data_dir .. "/scripts" 
    local hist_file = luakit.data_dir .. "/history.db" 
    local query = "select uri, title, datetime(last_visit,'unixepoch') from history order by last_visit DESC;" 
    local dmenu = "dmenu -b -l 10 -nf '#888888' -nb '#222222' -sf '#ffffff' -sb '#285577'" 
    -- AFAIK, luakit will urlencode spaces in uri's so this crude cut call should work fine.
    local fh = io.popen( "sh -c \"echo \\\"" .. query .. "\\\" | sqlite3 " .. hist_file .. " | sed 's#|#  #' | " .. dmenu .. " | cut -d' ' -f1\"" , "r" )
    local selection = fh:read( "*a" )
    fh:close()
    if selection ~= "" then w:navigate( selection ) end
end


--Opera-Speed-Dial
--you've to create 
--~/.local/luakit/speeddial/speed 
--writeable!
--"import" from imagemagick is also needed

local images_dir = luakit.data_dir .. "/speeddial"
local dial_file = luakit.data_dir .. "/speeddial/speed"

--add to Speeddial (add to binds.lua)
webview.methods.add_speeddial = function( w ) 
    local tsp = os.time() .. ".png"
    local fh = io.popen( "import -frame ".. images_dir .."/" .. tsp, "w")
    fh:close()

    local fd = io.open(dial_file, "a+")
    fd:write(string.format("%s %s\n", tsp, w.uri))
    fd:close()
end

--delete from Speeddial (using hooked uri) 
webview.init_funcs.deldial_hook = function (view, w)
    view:add_signal("navigation-request", function (v, uri)
        if string.match(string.lower(uri), "^deldial:") then

     fh = io.open(dial_file,"r")
        local new_lines = ""
	local del_line = nil
        local id = string.sub(uri, "9") -- cut the "deldial:"-hook from uri
        
        while true do
        
    	    line = fh.read(fh)
    	    if not line then break end
    	    local image, url = line:match("(%S+)%s(%S+)")
	    if image == id then
		del_line = "ok"
		local frm = io.popen( "rm ".. images_dir .."/" .. id, "w") -- delete screenshot
		frm:close()
	    else
		new_lines = new_lines .. string.format("%s %s\n", image, url) 
	    end

        end
        
        fh:close()
        
        if del_line == "ok" then
    	    fd = io.open(dial_file, "w")
    	    fd:write(new_lines)
    	    fd:close()
	    w:navigate("luakit://favs")
    	    w:set_prompt("Thumb has been deleted!")
        else
	    w:navigate("luakit://favs")
	    w:set_prompt("nothing to delete!")
        end

        end
    end)
end


--Speeddial Template
local html_template = [==[
<html>
<head>
    <title>Speed Dial</title>
    <style type="text/css">
    body {
        background: #000000;
        text-align: center;
    }
    
    a:link {text-decoration: none; font-color:#000000;}
    a:hover {text-decoration: none; font-color:#ffffff;}
        
        
	div.images {
	width:187px;
	height:100px;
	overflow:hidden;
	border: 2px solid #ffffff;
	float:left;
	position:relative;
	margin-left:8px;
	margin-top:8px;
	text-align: center;
	backround-color: #222222;
	cursor:pointer;
	}

	div.images:hover  {
	border: 4px solid #222222;
	backround-color: #000000;
	margin-left:4px;
	margin-top:4px;
	}
	
	div.close {
	width:9px;
	height:9px;
	background-color:#ffffff;
	position:absolute;
	text-align-center;
	font-size:7px;
	font-color:#000000;
	}
	
	div.close:hover {
	border:1px solid #222222;
	background-color:#222222;
	font-color:#ffffff;
	}

	div.pagename {
    width:100%
	height:11px;
    font-size:9pt;
    font-family:clean;
    background-color:#222222;
	}
	
    </style>
</head>
<body>
<div id="pagenames" class="pagename">-</div>
<div>{favs}</div>
</body>
</html>
]==]

-- readout "speed"-file
local function favs()
	local dial_temp = {}
	local dial_url = ""
	local dial_image = ""
	local string = ""

        fh = io.open(dial_file,"r")
        while true do
    	    line = fh.read(fh)
    	    if not line then break end
    	    local dial_image, dial_url = line:match("(%S+)%s(%S+)")
    	    string = string .. "<div class='images'><div class='close'><a href='deldial:" .. dial_image .. "'>x</a></div><div OnClick=\"location.href='" .. dial_url .. "'\" onmouseover=\"document.getElementById('pagenames').innerHTML='" .. dial_url .. "'\"><img width='188' height='100' src='file://" .. images_dir .. "/" .. dial_image .. "'></div></div>\n"    
        end
        fh:close()

    return string
end

chrome.add("favs", function (view, uri)
    local favs = favs()
    local html = string.gsub(html_template, "{favs}", favs)
    view:load_string(html, "file://favs")
--    view:load_string(html, "luakit://favs")
end )




-----------------------------
-- End user script loading --
-----------------------------

-- Restore last saved session
local w = (session and session.restore())
if w then
    for i, uri in ipairs(uris) do
        w:new_tab(uri, i == 1)
    end
else
    -- Or open new window
    window.new(uris)
end

-------------------------------------------
-- Open URIs from other luakit instances --
-------------------------------------------

if unique then
    unique.add_signal("message", function (msg, screen)
        local cmd, arg = string.match(msg, "^(%S+)%s*(.*)")
        local w = lousy.util.table.values(window.bywidget)[1]
        if cmd == "tabopen" then
            w:new_tab(arg)
        elseif cmd == "winopen" then
            w = window.new((arg ~= "") and { arg } or {})
        end
        w.win.screen = screen
        w.win.urgency_hint = true
    end)
end

-- vim: et:sw=4:ts=8:sts=4:tw=80
