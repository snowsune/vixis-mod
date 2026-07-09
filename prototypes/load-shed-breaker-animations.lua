local prefix = "__vixis-mod__/graphics/entity/load-shed-breaker/"
local frame_w = 400
local frame_h = 705
local scale = 0.5

local function anim(name, filename, frame_count, line_length)
  return {
    type = "animation",
    name = name,
    filename = prefix .. filename,
    width = frame_w,
    height = frame_h,
    frame_count = frame_count,
    line_length = line_length or frame_count,
    scale = scale,
  }
end

data:extend({
  anim("vixis-load-shed-on", "on-idle.png", 1),
  anim("vixis-load-shed-closed-hold", "closed-hold.png", 1),
  anim("vixis-load-shed-eject", "eject.png", 61, 20),
  anim("vixis-load-shed-tripped", "tripped.png", 1),
  anim("vixis-load-shed-reset", "reset.png", 20),
})
