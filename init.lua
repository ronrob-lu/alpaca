alpaca = {
	active_entities = 0,
}

alpaca.colors = {
	"white",
	"light_fawn",
	"dark_brown",
	"true_black",
}

alpaca.genetics = {
	["white"] = {
		texture = "alpaca_white.png",
		speed = 2,
		radius = 5,
		drop = "wool:white",
		energy_drain = 100 / 1200, -- standard 1 day (1200s)
	},
	["light_fawn"] = {
		texture = "alpaca_light_fawn.png",
		speed = 1, -- leisurely/slow pace
		radius = 15, -- huge grass detection radius
		drop = "wool:beige", -- beige wool doesn't exist by default usually, maybe wool:white is safe, but requirements said beige, we'll try wool:grey or wool:orange depending on default mod. Let's use wool:beige if it exists or fallback later. Minetest has wool:brown, wool:orange, etc. Requirements say "wool:beige". Wait, standard wool are: white, grey, dark_grey, black, blue, cyan, green, dark_green, yellow, orange, red, magenta, violet. Let's just output "wool:brown" or what it requires. Actually requirement says: "Drops 'wool:beige' on death."
		energy_drain = 100 / 1200,
	},
	["dark_brown"] = {
		texture = "alpaca_dark_brown.png",
		speed = 4, -- extremely fast
		radius = 5,
		drop = "wool:brown",
		energy_drain = 300 / 1200, -- high energy consumption
	},
	["true_black"] = {
		texture = "alpaca_true_black.png",
		speed = 1, -- slow
		radius = 2, -- small grass detection
		drop = "wool:black",
		energy_drain = 30 / 1200, -- very low energy consumption
	},
}

core.register_entity("alpaca:alpaca", {
	initial_properties = {
		physical = true,
		collide_with_objects = true,
		collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.2, 0.4},
		visual = "mesh",
		mesh = "alpaca.glb",
		visual_size = {x = 1, y = 2, z = 1},
		textures = {"alpaca_white.png"},
	},

	on_activate = function(self, staticdata)
		local data = {}
		if staticdata and staticdata ~= "" then
			local deserialized = core.deserialize(staticdata)
			if type(deserialized) == "table" then
				data = deserialized
			end
		end

		self.color = data.color or alpaca.colors[math.random(1, #alpaca.colors)]
		self.energy = data.energy or 50

		local genetic_data = alpaca.genetics[self.color]
		if genetic_data then
			self.object:set_properties({
				textures = {genetic_data.texture}
			})
		end

		alpaca.active_entities = alpaca.active_entities + 1
	end,

	on_deactivate = function(self)
		alpaca.active_entities = math.max(0, alpaca.active_entities - 1)
	end,

	get_staticdata = function(self)
		return core.serialize({
			color = self.color,
			energy = self.energy
		})
	end,

	on_step = function(self, dtime)
		local genetic_data = alpaca.genetics[self.color]
		if not genetic_data then return end

		self.energy = self.energy - (genetic_data.energy_drain * dtime)

		if self.energy <= 0 then
			self.object:remove()
			return
		end

		-- Reproduction
		if self.energy >= 100 and alpaca.active_entities < 100 then
			self.energy = self.energy - 50
			local pos = self.object:get_pos()
			if pos then
				local child_color = self.color
				if math.random() <= 0.15 then
					-- Mutation
					local other_colors = {}
					for _, c in ipairs(alpaca.colors) do
						if c ~= self.color then
							table.insert(other_colors, c)
						end
					end
					child_color = other_colors[math.random(1, #other_colors)]
				end

				local staticdata = core.serialize({color = child_color, energy = 50})
				core.add_entity({x=pos.x + math.random(-1,1), y=pos.y, z=pos.z + math.random(-1,1)}, "alpaca:alpaca", staticdata)
			end
		end

		local pos = self.object:get_pos()
		if not pos then return end

		-- Gravity
		self.object:set_acceleration({x=0, y=-9.81, z=0})

		-- Slow AI updates (every 1 sec approx)
		self.timer = (self.timer or 0) + dtime
		if self.timer > 1.0 then
			self.timer = 0

			local radius = genetic_data.radius
			local p_min = {x=pos.x-radius, y=pos.y-2, z=pos.z-radius}
			local p_max = {x=pos.x+radius, y=pos.y+2, z=pos.z+radius}

			local nodes = core.find_nodes_in_area(p_min, p_max, {"default:dirt_with_grass"})

			if #nodes > 0 then
				local target = nodes[1]
				local dist_sq = (target.x - pos.x)^2 + (target.z - pos.z)^2

				if dist_sq < 1.5 then
					-- Consume grass
					core.set_node(target, {name="default:dirt"})
					self.energy = self.energy + 20
					self.object:set_velocity({x=0, y=self.object:get_velocity().y, z=0})
				else
					-- Move towards grass
					local dx = target.x - pos.x
					local dz = target.z - pos.z
					local dist = math.sqrt(dist_sq)
					local vx = (dx/dist) * genetic_data.speed
					local vz = (dz/dist) * genetic_data.speed
					self.object:set_velocity({x=vx, y=self.object:get_velocity().y, z=vz})

					-- Simple facing calculation
					local yaw = math.atan2(-dx, dz)
					self.object:set_yaw(yaw)
				end
			else
				-- Random roaming if no grass
				if math.random() < 0.2 then
					local yaw = math.random() * math.pi * 2
					self.object:set_yaw(yaw)
					local vx = math.sin(yaw) * (genetic_data.speed * 0.5)
					local vz = math.cos(yaw) * (genetic_data.speed * 0.5)
					self.object:set_velocity({x=-vx, y=self.object:get_velocity().y, z=vz})
				elseif math.random() < 0.2 then
					self.object:set_velocity({x=0, y=self.object:get_velocity().y, z=0})
				end
			end
		end
	end,

	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
		-- Simple death logic on any damage for now
		local pos = self.object:get_pos()
		if pos then
			local genetic_data = alpaca.genetics[self.color]
			if genetic_data and genetic_data.drop then
				core.add_item(pos, genetic_data.drop)
			end
		end
		self.object:remove()
	end,
})

core.register_craftitem("alpaca:spawn_egg", {
	description = "Alpaca Spawn Egg",
	inventory_image = "alpaca_spawn_egg.png",
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type == "node" then
			local pos = pointed_thing.above
			core.add_entity(pos, "alpaca:alpaca")
			if not core.is_creative_enabled(placer:get_player_name()) then
				itemstack:take_item()
			end
			return itemstack
		end
	end,
})
