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

--register parsed htmlfile as chrome page
--maybe this could be done in a better way
chrome.add("favs", function (view, uri)
    local favs = favs()
    local html = string.gsub(html_template, "{favs}", favs)
    view:load_string(html, "file://favs")
--    view:load_string(html, "luakit://favs")
end )


--adding new keybindings

local buf = lousy.bind.buf
add_binds("normal", {

    buf("^ga", "Add  current Page to Speeddial",
         function (w) w:add_speeddial(w) end),

    buf("^gS$", "Open Speeddial in new Tab.",
        function (w) w:new_tab("luakit://favs/") end),

    buf("^gs$", "Open Speeddial.",
        function (w) w:navigate("luakit://favs/") end),
})

