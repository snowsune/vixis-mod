data:extend({
  {
    type = "simple-entity",
    name = "vixipawb-entity",

    icon = "__vixis-mod__/graphics/icons/pawb.png",
    icon_size = 64,

    flags = {"placeable-neutral", "player-creation"},
    selectable_in_game = true,

    -- Allow mining and return the item
    minable = { mining_time = 0.2, result = "vixipawb-item" },

    -- No collision so it's decoration-only
    collision_box = {{0, 0}, {0, 0}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

    -- Scale down the big 128px sprite
    picture = {
      filename = "__vixis-mod__/graphics/pawb.png",
      width = 128,
      height = 128,
      scale = 0.5  -- <--- try 0.5 first; tweak to taste
      -- shift = {0, 0} -- optional
    }
  }
})
