data:extend({
    {
      type = "simple-entity",
      name = "vixipawb-entity",
      icon = "__vixis-mod__/graphics/ortho.png",
      icon_size = 128,
      flags = {"placeable-neutral", "player-creation"},
      selectable_in_game = true,
  
      -- No collision so it's purely decorative
      collision_box = {{0, 0}, {0, 0}},
      selection_box = {{-0.9, -0.9}, {0.9, 0.9}},
  
      picture = {
        filename = "__vixis-mod__/graphics/ortho.png",
        width = 128,
        height = 128
      }
    }
  })
  