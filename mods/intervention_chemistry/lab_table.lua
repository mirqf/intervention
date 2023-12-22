--- @diagnostic disable
local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.colorize
local F = minetest.formspec_escape
local m = math.min
local r = math.random
local t = tonumber

function intervention.lab_table(username, pos)
    minetest.show_formspec(username, "intervention_chemistry:lab_table", table.concat({
        "formspec_version[4]",
        "size[10,10]",
        "style_type[image;noclip=true] style_type[label;noclip=true;font_size=*1.5]",
        "image[2.1375,-0.6;8.6,1;intervention_formspec_bg.png;9]",
        "image[2.2375,-0.5;8.4,0.75;intervention_layout.png;]",
        "label[5,-0.13;Material Reducer]",
        string.format("list[nodemeta:%f,%f,%f;input;10.375,6.075;9,1;]", pos.x, pos.y, pos.z),
        "list[current_player;main;3.875,8.575;9,3;9]",
        "list[current_player;main;3.875,11.525;1,1;]",
        "listring[]"
    }))
end

intervention.register_on_player_receive_form("intervention_chemistry:lab_table", function(userdata, formname, fields)
    if fields.quit then return end
    minetest.add_item(vector.offset(vector.from_string(userdata:get_meta():get_string("int_c:lt_pos")),0,1,0), "intervention_chemistry:hydrogen")
end)

minetest.register_node("intervention_chemistry:lab_table", {
	description = S("Lab Table"),
	tiles = {},
	paramtype2 = "facedir",
	groups = { axey = 2, handy = 1, deco_block = 1, material_wood = 1, flammable = 1 },
	on_construct = function(pos)
        minetest.get_meta(pos):get_inventory():set_size("input", 9)
	end,
    on_rightclick = function(pos, _, userdata)
		if not userdata:get_player_control().sneak then
            userdata:get_meta():set_string("inc_c:lt_pos", vector.to_string(pos))
            intervention.lab_table(userdata:get_player_name(), pos)
        end
	end,
})