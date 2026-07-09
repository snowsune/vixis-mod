local purple_tint = { r = 0.55, g = 0.25, b = 0.85, a = 1.0 }

data:extend({
  {
    type = "power-switch",
    name = "vixis-load-shed-breaker",
    icon = "__vixis-mod__/graphics/icons/load-shed-breaker.png",
    icon_size = 64,
    flags = { "placeable-neutral", "player-creation" },
    minable = { mining_time = 0.2, result = "vixis-load-shed-breaker" },
    fast_replaceable_group = "vixis-load-shed-breaker",
    max_health = 200,
    corpse = "power-switch-remnants",
    dying_explosion = "power-switch-explosion",
    tile_width = 3,
    tile_height = 2,
    collision_box = { { -1.4, -0.9 }, { 1.4, 0.9 } },
    selection_box = { { -1.5, -1.0 }, { 1.5, 1.0 } },
    power_on_animation = {
      filename = "__vixis-mod__/graphics/load-shed-breaker.png",
      width = 192,
      height = 128,
      frame_count = 1,
      line_length = 1,
      scale = 0.5,
      tint = purple_tint,
    },
    overlay_start_delay = 0,
    led_on = {
      filename = "__base__/graphics/entity/power-switch/power-switch-led.png",
      x = 48,
      width = 48,
      height = 60,
      shift = { 1.0, 0.0 },
      blend_mode = "additive",
      scale = 0.5,
      tint = { r = 0.4, g = 1.0, b = 0.4, a = 1.0 },
    },
    led_off = {
      filename = "__base__/graphics/entity/power-switch/power-switch-led.png",
      width = 48,
      height = 60,
      shift = { 1.0, 0.0 },
      blend_mode = "additive",
      scale = 0.5,
      tint = { r = 1.0, g = 0.35, b = 0.35, a = 1.0 },
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.5 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.5 },
    working_sound = {
      main_sounds = {
        {
          sound = { filename = "__base__/sound/power-switch.ogg", volume = 0.35, audible_distance_modifier = 0.4 },
          match_volume_to_activity = true,
          activity_to_volume_modifiers = { offset = 1 },
        },
      },
      activate_sound = { filename = "__vixis-mod__/sound/power-switch-activate.ogg", volume = 0.3 },
      deactivate_sound = { filename = "__vixis-mod__/sound/power-switch-deactivate.ogg", volume = 0.15 },
      max_sounds_per_prototype = 2,
    },
    circuit_wire_connection_point = {
      shadow = {
        red = { -0.4375, 0.8125 },
        green = { -0.6875, 0.8125 },
      },
      wire = {
        red = { -0.53125, 0.5 },
        green = { -0.75, 0.5 },
      },
    },
    left_wire_connection_point = {
      shadow = {
        copper = { -1.25, 0.25 },
      },
      wire = {
        copper = { -2.25, 0.0 },
      },
    },
    right_wire_connection_point = {
      shadow = {
        copper = { 1.25, 0.25 },
      },
      wire = {
        copper = { 2.25, 0.0 },
      },
    },
    wire_max_distance = 10,
  },
})
