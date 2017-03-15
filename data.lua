
data:extend({
  {
    type = "selection-tool",
    name = "combinatorgraph-tool",
    icon = "__combinatorgraph__/combinatorgraph.png",
    stack_size = 1,
    subgroup = "terrain",
    order = "d[combinatorgraph-tool]-a[plain]",
    flags = {"goes-to-quickbar"},
    selection_color = {r = 0.2, g = 0.8, b = 0.2, a = 0.2},
    alt_selection_color = {r = 0.2, g = 0.8, b = 0.2, a = 0.2},
    selection_mode = {"blueprint"},
    alt_selection_mode = {"blueprint"},
    selection_cursor_box_type = "copy",
    alt_selection_cursor_box_type = "copy"
  },
  {
    type = "recipe",
    name = "combinatorgraph-tool",
    enabled = true,
    energy_required = 0.5,
    ingredients =
    {
      {"electronic-circuit", 1}
    },
    result = "combinatorgraph-tool"
  }
})
