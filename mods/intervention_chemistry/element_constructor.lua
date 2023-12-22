--- @diagnostic disable
local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.colorize
local F = minetest.formspec_escape
local m = math.min
local r = math.random
local t = tonumber

--- @param username string
--- @param elements table
--- @return nil
function intervention.element_constructor(username, elements)
	local atom_model = ""
	for i = 0, math.ceil(math.floor(math.sqrt(math.max(1, elements.electrons)))/2)-1 do
        local xpos, ypos, size = 5.535-0.34*i, 4.035-0.34*i, 2.2+i*0.7
		atom_model = atom_model .. ("image[%f,%f;%f,%f;intervention_ring.png;]"):format(xpos, ypos, size, size)
        for q = 1, 10 do
            atom_model = atom_model .. ("image[%f,%f;0.3,0.3;electron.png;]"):format(6.5+size/2*math.cos(((q-1)/10)*(2*math.pi)), 5+size/2*math.sin(((q-1)/10)*(2*math.pi)))
        end
	end
	for i = 1, math.ceil(math.sqrt(elements.protons)) do
		atom_model = atom_model .. ("image[%f,%f;0.3,0.3;proton.png;]"):format(6+r(), 4.45+r())
	end
	for i = 1, math.ceil(math.sqrt(elements.neutrons)) do
		atom_model = atom_model .. ("image[%f,%f;0.3,0.3;neutron.png;]"):format(6+r(), 4.45+r())
	end
    local pos = vector.from_string(minetest.get_player_by_name(username):get_meta():get_string("int_c:ec_pos")) or {x=0,y=0,z=0}
    local item = ""
    if (elements.protons<119 and (elements.protons == elements.electrons) and (elements.neutrons == (intervention.elements[elements.protons].Mass - elements.protons))) then 
        item = "intervention_chemistry:" .. intervention.elements[elements.protons].Name:lower()
    end
    minetest.get_meta(pos):get_inventory():set_stack("output", 1, item)
    local output_list = ("list[nodemeta:%f,%f,%f;output;10.375,6.075;1,1;]"):format(pos.x,pos.y,pos.z)
    local formspec = table.concat({
        "formspec_version[4]",
        "size[12.875,11.125]",
		"style_type[image;noclip=true] style_type[label;noclip=true;font_size=*1.5]",
		"image[2.1375,-0.6;8.6,1;intervention_formspec_bg.png;9]",
        "image[2.2375,-0.5;8.4,0.75;intervention_layout.png;]",
        "label[5,-0.13;Element Constructor]",
		"container[0,-1.65]",
		"style_type[list;size=0.9;spacing=0.05,0.05]",
        "list[current_player;main;3.875,8.575;9,3;9]",
        "list[current_player;main;3.875,11.525;9,1;]",
		"style_type[list;size=1.2]",
        "image[9,6.575;2,0.2;intervention_layout.png;]",
		output_list,
		"style_type[field;font_size=*1.5]",
 		"scrollbaroptions[min=1;max=120;smallstep=1;largestep=1]",
		"scrollbar[0.5,4.575;0.5,7.875;vertical;protons;".. 120-elements.protons.."]",
		"field[0.25,3.325;1,0.8;protons_field;;"..elements.protons.."]",
		"image[0.5,2.375;0.5,0.5;proton.png;]",
		"scrollbar[1.6875,4.575;0.5,7.875;vertical;electrons;".. 120-elements.electrons.."]",
		"field[1.4375,3.325;1,0.8;electrons_field;;"..elements.electrons.."]",
		"image[1.6875,2.375;0.5,0.5;electron.png;]",
		"scrollbar[2.875,4.575;0.5,7.875;vertical;neutrons;".. 120-elements.neutrons.."]",
		"field[2.625,3.325;1,0.8;neutrons_field;;"..elements.neutrons.."]",
		"image[2.875,2.375;0.5,0.5;neutron.png;]",
        "image[3.875,2.375;5.625,5.625;intervention_layout.png;]",
		"image[10,2.375;2,2.9;microscope.png]",
		"field_close_on_enter[neutrons_field;false]",
		"field_close_on_enter[protons_field;false]",
		"field_close_on_enter[electrons_field;false]",
        "set_focus[electrons;true]",
		atom_model,
		"container_end[]",
		"listring[]"
    })
	minetest.show_formspec(username, "intervention_chemistry:element_constructor", formspec)
end

-- For better scrollbar performance. Oh my god :/
local update_cycle_storage = {}
local function update_cycle(username)
    local before = update_cycle_storage[username][1]
    minetest.after(1, function() if update_cycle_storage[username][1] == before then update_cycle(username) else 
        intervention.element_constructor(username, update_cycle_storage[username][2])
        update_cycle_storage[username] = nil
        end 
    end)
end
local function start_update_cycle(username, data)
    local a = (update_cycle_storage[username] == nil)
    update_cycle_storage[username] = {os.clock(), data}
    if a then update_cycle(username) end
end

intervention.register_on_player_receive_form("intervention_chemistry:element_constructor", function(userdata, formname, fields)
    if fields.quit then return end
    local username = userdata:get_player_name()
    local elements_table = {protons=t(fields.protons_field),electrons=t(fields.electrons_field),neutrons=t(fields.neutrons_field)}
    for _, elem in ipairs({"neutrons", "protons", "electrons"}) do
        local data = minetest.explode_scrollbar_event(fields[elem])
        if data.type == "CHG" then
            elements_table[elem] = 120-data.value
            start_update_cycle(username, elements_table)
            return
        end
    end
    intervention.element_constructor(username, 
    {neutrons=m(120, t(fields.neutrons_field) or 1),
    protons=m(120, t(fields.protons_field) or 1),
    electrons=m(120, t(fields.electrons_field) or 1)}
    )
end)

minetest.register_node("intervention_chemistry:element_constructor", {
	description = S("Element Constructor"),
	tiles = {},
	paramtype2 = "facedir",
	groups = { axey = 2, handy = 1, deco_block = 1, material_wood = 1, flammable = 1 },
	on_construct = function(pos)
        minetest.get_meta(pos):get_inventory():set_size("output", 1)
	end,
	allow_metadata_inventory_put = function() return 0 end,
    allow_metadata_inventory_move = function() return 0 end,
    on_metadata_inventory_take = function(pos, listname, index, stack)
        minetest.get_meta(pos):get_inventory():set_stack(listname, index, stack)
    end,
	on_rightclick = function(pos, _, userdata)
		if not userdata:get_player_control().sneak then
            userdata:get_meta():set_string("int_c:ec_pos", vector.to_string(pos))
            intervention.element_constructor(userdata:get_player_name(), {neutrons=1,protons=1,electrons=1})
        end
	end,
})