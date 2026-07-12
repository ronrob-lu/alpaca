local MyEntity = {
    initial_properties = {
        hp_max = 1,
        physical = true,
        collide_with_objects = false,
        collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
        visual = "mesh",
        --visual_size = {x = 0.4, y = 0.4},
		mesh = "notloc_test_sphere.glb",
        textures = {"notloc_test_sphere.png"},
        spritediv = {x = 1, y = 1},
        initial_sprite_basepos = {x = 0, y = 0},
    },

    message = "Default message",
}

function MyEntity:set_message(msg)
    self.message = msg
end

function MyEntity:on_step(dtime)
    local pos      = self.object:get_pos()
    local pos_down = vector.subtract(pos, vector.new(0, 1, 0))

    local delta
    if core.get_node(pos_down).name == "air" then
        delta = vector.new(0, -1, 0)
    elseif core.get_node(pos).name == "air" then
        delta = vector.new(0, 0, 1)
    else
        delta = vector.new(0, 1, 0)
    end

    delta = vector.multiply(delta, dtime)

    self.object:move_to(vector.add(pos, delta))
end

function MyEntity:on_punch(hitter)
    core.chat_send_player(hitter:get_player_name(), self.message)
end

function MyEntity:get_staticdata()
    return core.write_json({
        message = self.message,
    })
end

function MyEntity:on_activate(staticdata, dtime_s)
    if staticdata ~= "" and staticdata ~= nil then
        local data = core.parse_json(staticdata) or {}
        self:set_message(data.message)
    end
end

core.register_entity("lmgjam_notloc_alpac_alachia:foobie", MyEntity)

-- local pos = { x = 1, y = 2, z = 3 }
-- local obj = core.add_entity(pos, "lmgjam_notloc_alpac_alachia:entity", nil)