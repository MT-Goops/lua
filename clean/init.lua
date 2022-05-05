minetest.register_lbm({
  name              = "clean:undefined",
  nodenames         = {"factory:sapling_fertilizer"},
  run_at_every_load = true,
  action            = minetest.remove_node,
})
