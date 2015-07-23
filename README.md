# Luakit
My personal LuaKit config

# Features 
- Speeddial (like Opera-Speeddial), where you have no need to touch any files to add new entries
  - see `speeddial.lua`
- inline PDF viewer (realized with gview-api)
```lua
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
```
- many standard plugins like: noscript, useragent-fake...
