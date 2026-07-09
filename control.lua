local BREAKER_NAME = "vixis-load-shed-breaker"
local CHECK_EVERY = 10
local LOW_STREAK_REQUIRED = 3
local RESET_SIGNAL = { type = "virtual", name = "signal-R" }

local function is_breaker(entity)
  return entity and entity.valid and entity.name == BREAKER_NAME
end

local function ensure_breaker_storage()
  storage.vixis_breakers = storage.vixis_breakers or {}
end

local function ensure_breaker_data(entity)
  ensure_breaker_storage()
  local data = storage.vixis_breakers[entity.unit_number]
  if not data then
    data = { tripped = false, low_streak = 0 }
    storage.vixis_breakers[entity.unit_number] = data
  end
  return data
end

local function get_threshold()
  local setting = settings.global["vixis-load-shed-threshold"]
  if setting == nil then
    return 0.5
  end
  return setting.value / 100
end

local function set_tripped_status(entity)
  entity.custom_status = {
    diode = defines.entity_status_diode.red,
    label = { "entity-status.vixis-load-shed-tripped" },
  }
end

local function clear_tripped_status(entity)
  entity.custom_status = nil
end

local COPPER_CONNECTORS = {
  defines.wire_connector_id.power_switch_left_copper,
  defines.wire_connector_id.power_switch_right_copper,
}

local function get_parent_network(entity)
  if not entity.get_wire_connector then
    return nil
  end

  for _, connector_id in ipairs(COPPER_CONNECTORS) do
    local connector = entity.get_wire_connector(connector_id, false)
    if connector and connector.valid and connector.real_connection_count > 0 then
      local subnetwork = connector.electric_network
      if subnetwork and subnetwork.valid then
        local parent = subnetwork.parent_network
        if parent and parent.valid then
          return parent
        end
      end
    end
  end

  return nil
end

local function get_network_satisfaction(entity)
  if not entity.power_switch_state then
    return nil
  end

  local network = get_parent_network(entity)
  if not network then
    return nil
  end

  local flow = network.flow_last_tick
  if not flow or flow.consumption_satisfaction == nil then
    return nil
  end

  return flow.consumption_satisfaction
end

local function reset_signal_present(entity)
  local connectors = {
    defines.wire_connector_id.circuit_red,
    defines.wire_connector_id.circuit_green,
  }

  for _, connector in ipairs(connectors) do
    if entity.get_signal(RESET_SIGNAL, connector) > 0 then
      return true
    end
  end

  return false
end

local function trip_breaker(entity, data)
  data.tripped = true
  data.low_streak = 0
  entity.power_switch_state = false
  set_tripped_status(entity)
end

local function reset_breaker(entity, data)
  data.tripped = false
  data.low_streak = 0
  clear_tripped_status(entity)
end

local function update_breaker(entity)
  local data = ensure_breaker_data(entity)

  if data.tripped then
    if entity.power_switch_state or reset_signal_present(entity) then
      reset_breaker(entity, data)
      return
    end

    entity.power_switch_state = false
    set_tripped_status(entity)
    return
  end

  if not entity.power_switch_state then
    data.low_streak = 0
    clear_tripped_status(entity)
    return
  end

  local satisfaction = get_network_satisfaction(entity)
  if satisfaction == nil then
    data.low_streak = 0
    return
  end

  if satisfaction < get_threshold() then
    data.low_streak = data.low_streak + 1
    if data.low_streak >= LOW_STREAK_REQUIRED then
      trip_breaker(entity, data)
    end
  else
    data.low_streak = 0
  end
end

local function on_breaker_created(entity)
  if is_breaker(entity) then
    ensure_breaker_data(entity)
  end
end

script.on_init(function()
  ensure_breaker_storage()
end)

script.on_configuration_changed(function()
  ensure_breaker_storage()
end)

script.on_event(defines.events.on_built_entity, function(event)
  on_breaker_created(event.created_entity)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
  on_breaker_created(event.created_entity)
end)

script.on_event(defines.events.on_entity_cloned, function(event)
  on_breaker_created(event.destination)
end)

script.on_event(defines.events.on_entity_died, function(event)
  if is_breaker(event.entity) then
    ensure_breaker_storage()
    storage.vixis_breakers[event.entity.unit_number] = nil
  end
end)

script.on_nth_tick(CHECK_EVERY, function()
  for _, surface in pairs(game.surfaces) do
    for _, entity in ipairs(surface.find_entities_filtered { name = BREAKER_NAME }) do
      update_breaker(entity)
    end
  end
end)
