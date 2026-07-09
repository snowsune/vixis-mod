local BREAKER = "vixis-load-shed-breaker"
local TICK = 10
local LOW_STREAK = 3
local RESET_SIGNAL = { type = "virtual", name = "signal-R" }
local OFFSET = { 0, -2 }

local VIS = {
  on = { "vixis-load-shed-on" },
  hold = { "vixis-load-shed-closed-hold" },
  open = { "vixis-load-shed-tripped" },
  tripped = { "vixis-load-shed-tripped" },
  eject = { "vixis-load-shed-eject", 0.5, 61 },
  reset = { "vixis-load-shed-reset", 0.5, 20 },
}

local COPPER = {
  defines.wire_connector_id.power_switch_left_copper,
  defines.wire_connector_id.power_switch_right_copper,
}

local CIRCUIT = {
  defines.wire_connector_id.circuit_red,
  defines.wire_connector_id.circuit_green,
}

local function each_breaker(fn)
  for _, surface in pairs(game.surfaces) do
    for _, entity in ipairs(surface.find_entities_filtered { name = BREAKER }) do
      fn(entity)
    end
  end
end

local function data_for(entity)
  storage.vixis_breakers = storage.vixis_breakers or {}
  local d = storage.vixis_breakers[entity.unit_number]
  if not d then
    d = { latched = false, low_streak = 0, phase = nil, anim_start = 0 }
    storage.vixis_breakers[entity.unit_number] = d
  end
  return d
end

local function threshold()
  local s = settings.global["vixis-load-shed-threshold"]
  return s and s.value / 100 or 0.5
end

local function kill_render(d)
  if d.render and d.render.valid then
    d.render.destroy()
  end
  d.render = nil
end

local function draw(entity, d, anim, speed, offset)
  kill_render(d)
  d.render = rendering.draw_animation({
    animation = anim,
    target = { entity = entity, offset = OFFSET },
    surface = entity.surface,
    render_layer = "object",
    animation_speed = speed,
    animation_offset = offset,
  })
end

local function set_phase(entity, d, phase)
  if d.phase == phase then
    return
  end
  local spec = VIS[phase]
  d.phase = phase
  if spec[2] then
    d.anim_start = game.tick
    draw(entity, d, spec[1], spec[2], 0)
  else
    draw(entity, d, spec[1], 0, 0)
  end
end

local function anim_frame(d, phase)
  local spec = VIS[phase]
  return (game.tick - d.anim_start) * spec[2]
end

local function finish_reset(entity, d)
  entity.power_switch_state = true
  local sat = satisfaction(entity)
  if sat and sat < threshold() then
    entity.power_switch_state = false
    d.latched = true
    d.low_streak = 0
    set_status(entity, true)
    set_phase(entity, d, "tripped")
    return
  end
  d.latched = false
  entity.custom_status = nil
  set_phase(entity, d, "hold")
end

local function step_anim(entity, d)
  local spec = VIS[d.phase]
  if not spec or not spec[2] then
    return
  end

  if not d.render or not d.render.valid then
    if d.phase == "eject" then
      set_phase(entity, d, "tripped")
    else
      finish_reset(entity, d)
    end
    return
  end

  local frame = anim_frame(d, d.phase)
  local last = spec[3] - 1

  if frame >= last then
    d.render.animation_speed = 0
    d.render.animation_offset = last
  end

  if frame < spec[3] then
    return
  end

  if d.phase == "eject" then
    d.phase = "tripped"
  else
    finish_reset(entity, d)
  end
end

local function set_status(entity, tripped)
  if tripped then
    entity.custom_status = {
      diode = defines.entity_status_diode.red,
      label = { "entity-status.vixis-load-shed-tripped" },
    }
  else
    entity.custom_status = nil
  end
end

local function satisfaction(entity, require_closed)
  if require_closed ~= false and not entity.power_switch_state then
    return nil
  end
  if not entity.get_wire_connector then
    return nil
  end
  for _, id in ipairs(COPPER) do
    local w = entity.get_wire_connector(id, false)
    if w and w.valid and w.real_connection_count > 0 then
      local net = w.electric_network and w.electric_network.valid and w.electric_network.parent_network
      if net and net.valid then
        local f = net.flow_last_tick
        if f and f.consumption_satisfaction and f.maximum_consumption > 0 then
          return f.consumption_satisfaction
        end
      end
    end
  end
  return nil
end

local function wants_reset(entity)
  for _, id in ipairs(CIRCUIT) do
    if entity.get_signal(RESET_SIGNAL, id) > 0 then
      return true
    end
  end
  return false
end

local function tick(entity)
  local d = data_for(entity)

  if d.phase == "eject" or d.phase == "reset" then
    step_anim(entity, d)
    return
  end

  if not d.render or not d.render.valid then
    local phase = d.phase or (d.latched and "tripped" or (entity.power_switch_state and "on" or "open"))
    d.phase = nil
    set_phase(entity, d, phase)
  end

  if d.latched then
    set_status(entity, true)
    if wants_reset(entity) or entity.power_switch_state then
      entity.power_switch_state = false
      set_phase(entity, d, "reset")
      return
    end
    entity.power_switch_state = false
    set_phase(entity, d, "tripped")
    return
  end

  set_status(entity, false)

  if not entity.power_switch_state then
    d.low_streak = 0
    set_phase(entity, d, "open")
    return
  end

  if d.phase ~= "on" and d.phase ~= "hold" then
    set_phase(entity, d, "on")
  end

  if game.tick % TICK ~= 0 then
    return
  end

  local sat = satisfaction(entity)
  if not sat then
    d.low_streak = 0
    return
  end

  if sat < threshold() then
    d.low_streak = d.low_streak + 1
    if d.low_streak >= LOW_STREAK then
      d.latched = true
      d.low_streak = 0
      entity.power_switch_state = false
      set_status(entity, true)
      set_phase(entity, d, "eject")
    end
  else
    d.low_streak = 0
  end
end

local function on_placed(entity)
  if not entity or not entity.valid or entity.name ~= BREAKER then
    return
  end
  local d = data_for(entity)
  kill_render(d)
  d.latched = false
  d.low_streak = 0
  d.phase = nil
  tick(entity)
end

script.on_init(function()
  storage.vixis_breakers = {}
end)

script.on_event({ defines.events.on_built_entity, defines.events.on_robot_built_entity }, function(e)
  on_placed(e.created_entity)
end)

script.on_event(defines.events.on_entity_cloned, function(e)
  on_placed(e.destination)
end)

script.on_event(defines.events.on_entity_died, function(e)
  if e.entity.name == BREAKER then
    storage.vixis_breakers[e.entity.unit_number] = nil
  end
end)

script.on_nth_tick(1, function()
  each_breaker(tick)
end)
