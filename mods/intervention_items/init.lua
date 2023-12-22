--- @diagnostic disable
local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node("intervention_items:dirt_with_grass", {
	description = S("Grass Block"),
	tiles = {"intervention_grass_top.png", "intervention_dirt.png", "intervention_grass_side.png"},
	groups = {node = 1},
	is_ground_content = true,
	stack_max = 64,
})

minetest.register_node("intervention_items:dirt", {
	description = S("Dirt Block"),
	tiles = {"intervention_dirt.png"},
	groups = {node = 1},
	is_ground_content = true,
	stack_max = 64,
})

minetest.register_node("intervention_items:stone", {
	description = S("Stone"),
	tiles = {"intervention_stone.png"},
	groups = {node = 1},
	is_ground_content = true,
	stack_max = 64,
})

minetest.register_node("intervention_items:leaves", {
	description = S("Leaves"),
	drawtype = "allfaces_optional",
	waving = 1,
	tiles = {"intervention_leaves.png"},
	special_tiles = {"intervention_leaves_simple.png"},
	paramtype = "light",
	is_ground_content = false,
})

for _, wood in ipairs({"oak", "birch", "spruce", "acacia"}) do
	minetest.register_node("intervention_items:planks_" .. wood, {
		description = S(string.gsub(wood, "%l?", string.upper, 1) .. " Planks"),
		paramtype2 = "facedir",
		tiles = {"intervention_" .. wood .. "_planks.png"},
		groups = {node = 1},
	})
	if wood ~= "acacia" then 
		minetest.register_node("intervention_items:log_" .. wood, {
			description = S(string.gsub(wood, "%l?", string.upper, 1) .. " Log"),
			tiles = {"intervention_" .. wood .. "_log_top.png", "intervention_" .. wood .. "_log_side.png"},
			groups = {node = 1},
		})
	end	
end

minetest.register_node("intervention_items:log_acacia", {
	description = S("Acacia Log"),
	tiles = {"intervention_acacia_log_side.png"},
	groups = {node = 1},
})


minetest.register_node("intervention_items:glass", {
	description = S("Glass"),
	drawtype = "glasslike_framed_optional",
	tiles = {"intervention_glass.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {node = 1},
})

minetest.register_node("intervention_items:glass_black", {
	description = S("Glass"),
	drawtype = "glasslike_framed_optional",
	tiles = {"intervention_glass.png^[colorize:#050000"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {node = 1},
})

minetest.register_node("intervention_items:glass_pane", {
	description = S("Glass Pane"),
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	tiles = {
		"blank.png",
		"blank.png",
		"blank.png",
		"blank.png",
		"intervention_glass.png",
		"intervention_glass.png"
	},
	groups = {node = 1},
	use_texture_alpha = "blend",
	node_box = {
		type = "fixed",
		fixed = {{-1/2, -1/2, -1/32, 1/2, 1/2, 1/32}},
	},
	selection_box = {
		type = "fixed",
		fixed = {{-1/2, -1/2, -1/32, 1/2, 1/2, 1/32}},
	},
})

minetest.register_node("intervention_items:glass_pane_black", {
	description = S("Glass Pane Black"),
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	tiles = {
		"intervention_concrete_white.png^[colorize:#050000",
		"intervention_concrete_white.png^[colorize:#050000",
		"intervention_concrete_white.png^[colorize:#050000",
		"intervention_concrete_white.png^[colorize:#050000",
		"intervention_glass.png^[colorize:#050000",
		"intervention_glass.png^[colorize:#050000"
	},
	groups = {node = 1},
	use_texture_alpha = "blend",
	node_box = {
		type = "fixed",
		fixed = {{-1/2, -1/2, -1/32, 1/2, 1/2, 1/32}},
	},
	selection_box = {
		type = "fixed",
		fixed = {{-1/2, -1/2, -1/32, 1/2, 1/2, 1/32}},
	},
})

minetest.register_node("intervention_items:glass_pane_black_f", {
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	description = "glass pane f",
	tiles = {
		"intervention_concrete_white.png^[colorize:#050000",
		"intervention_concrete_white.png^[colorize:#050000",
		"intervention_glass.png^[colorize:#050000",
	},
	groups = {node=1},
	use_texture_alpha = "blend",
	node_box = {
		type = "connected",
		fixed = {{-1/32, -1/2, -1/32, 1/32, 1/2, 1/32}},
		connect_front = {{-1/32, -1/2, -1/2, 1/32, 1/2, -1/32}},
		connect_left = {{-1/2, -1/2, -1/32, -1/32, 1/2, 1/32}},
		connect_back = {{-1/32, -1/2, 1/32, 1/32, 1/2, 1/2}},
		connect_right = {{1/32, -1/2, -1/32, 1/2, 1/2, 1/32}},
	},
	connects_to = {"group:node"},
})

minetest.register_node("intervention_items:concrete_white", {
	description = S("White Concrete"),
	tiles = {"intervention_concrete_white.png"},
	groups = {node = 1, warm=1},
	stack_max = 64,
})

minetest.register_node("intervention_items:concrete_black", {
	description = S("White Concrete"),
	tiles = {"intervention_concrete_white.png^[colorize:#050000"},
	groups = {node = 1, warm=1},
	stack_max = 64,
})

minetest.register_node("intervention_items:concrete_grey", {
	description = S("White Concrete"),
	tiles = {"intervention_concrete_white.png^[colorize:#494949"},
	groups = {node = 1, warm=1},
	stack_max = 64,
})

minetest.register_node("intervention_items:snowblock", {
	description = S("Snow Block"),
	tiles = {"intervention_snowblock.png"},
	groups = {node = 1},
	stack_max = 64,
})

minetest.register_node("intervention_items:ice", {
	description = S("Ice"),
	tiles = {"intervention_ice.png"},
	groups = {node = 1, slippery = 3},
	paramtype = "light",
	stack_max = 64,
})

minetest.register_node("intervention_items:glowstone", {
	description = S("Glowstone"),
	tiles = {"intervention_glowstone.png"},
	groups = {node=1},
	light_source = minetest.LIGHT_MAX,
	stack_max = 64,
})

minetest.register_node("intervention_items:light", {
	description = S("Light"),
	drawtype = "airlike",
	paramtype = "light",
	pointable = false,
	walkable = false,
	light_source = 14,
	stack_max = 64,
	node_placement_prediction = "",
	sunlight_propagates = true,
	is_ground_content = false,
})

minetest.register_node("intervention_items:bookshelf", {
	description = S("Bookshelf"),
	tiles = {"intervention_bookshelf.png"},
	groups = {node=1},
	stack_max = 64,
})

minetest.register_craftitem("intervention_items:antidote", {
	description = S("Antidote"),
	inventory_image = "intervention_stone.png",
	stack_max = 1,
	on_use = function(itemstack, userdata, pointed_thing)
		intervention.spectator(userdata, true)
		intervention.darkness(userdata, 2)
		userdata:set_pos({x=0,y=0,z=0})
		userdata:set_physics_override({speed=0,jump=0,gravity=0,sneak=false})
		minetest.after(4, function()
			userdata:set_properties({eye_height=0.625}) 
			for i = 1, 100 do
				minetest.after(i*0.01, function() userdata:set_properties({eye_height=0.625+i*0.01}) end)
			end
			minetest.after(2, function() 
				userdata:set_physics_override({speed=1,jump=1,gravity=1,sneak=true})
				intervention.spectator(userdata, false) 
			end)
		end)
		return ItemStack("")
	end
})

minetest.register_on_punchnode(function(pos, node, userdata, pointed_thing)
	local name = userdata:get_player_name()
	if minetest.check_player_privs(name, {debug=true}) then
		minetest.remove_node(pos)
	end
end)
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	return true
end)

minetest.register_node("intervention_items:chest", {
	description = S("Chest"),
	tiles = {
		"intervention_chest_top.png",
		"intervention_chest_top.png",
		"intervention_chest_side.png",
		"intervention_chest_side.png",
		"intervention_chest_front.png",
	},
	stack_max = 64,
	groups = {node=1},
})