print("This file will be run at load time!")

-- core.register_node("lmgjam_notloc_alpac_alachia:node", {
--     description = "This is a node",
--     tiles = {"mymod_node.png"},
--     groups = {cracky = 1}
-- })

-- core.register_craft({
--     type = "shapeless",
--     output = "lmgjam_notloc_alpac_alachia:node 3",
--     recipe = { "default:dirt", "default:stone" },
-- })

dofile(core.get_modpath("lmgjam_notloc_alpac_alachia").."/mobs/notloc_foobie.lua")
dofile(core.get_modpath("lmgjam_notloc_alpac_alachia").."/mobs/notloc_alpaca.lua")