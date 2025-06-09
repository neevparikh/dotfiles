log = hs.logger.new('init', 'debug')

block_menu_bars = hs.eventtap.new({ hs.eventtap.event.types.mouseMoved }, function(e)
  local sf = hs.screen.mainScreen():fullFrame()
  local loc = e:location()
  local within_top = loc.y < (sf.y + 4) and loc.y > (sf.y - 4)
  local within_bottom = loc.y < (sf.y + sf.h + 4) and loc.y > (sf.y + sf.h - 4)

  if within_top or within_bottom then
    return true
  else
    return false
  end
end):start()
