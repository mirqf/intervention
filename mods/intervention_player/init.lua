--- @diagnostic disable

local colors = {"light_purple", "blue", "red", "green", "yellow", "dark_purple", "white"}
--- @param color string
--- @param percentage integer
--- @return string
local function format_image(color, percentage)
    local index = math.abs(table.indexof(colors, color))*2-1
    return string.format("(mcl_bossbars.png"
        .. "^[transformR270"
        .. "^[verticalframe:14:" .. (index - 1)
        .. "^(mcl_bossbars_empty.png"
        .. "^[lowpart:%f:mcl_bossbars.png"
        .. "^[transformR270"
        .. "^[verticalframe:14:" .. index .. "))^[resize:1456x40", percentage)
end

--- @param userdata userdata
--- @param position table
--- @param unphysical? boolean
--- @return nil
function intervention.move_player(userdata, position, unphysical)
    if unphysical then userdata:set_physics_override({speed=0,jump=0,gravity=0,sneak=false}) end
    local playerpos = userdata:get_pos()
    userdata:add_velocity(vector.direction(playerpos, position))
    if unphysical then userdata:set_physics_override({speed=1,jump=1,gravity=1,sneak=true}) end
end

--- @param userdata userdata
--- @param point table
--- @param zone integer
--- @return nil
function intervention.fractalize(userdata, point, zone)
    local meta = userdata:get_meta()
    if meta:get_int("fractalization_passed") == 0 then
        meta:set_int("fractalization_passed", 1)
        -- TODO: Remind player, world is not unlimited.
    end
    local playerpos = userdata:get_pos()
    if not vector.in_area(playerpos, vector.subtract(point, zone), vector.add(point, zone)) then
        local where = vector.multiply(vector.direction(playerpos, point), zone)
        userdata:set_pos({x=where.x,y=playerpos.y,z=where.z})
    end
end

--- @param object object_ref
--- @param position table
--- @return boolean
function intervention.animate_to(object, position)
    local path = minetest.find_path(object:get_pos(), position, 20, 1, 1); if not path then return false end
    local entity = object:get_luaentity()
    entity.path = {}
	entity.path_i = 1
	for i=2, #path do
		entity.path[i - 1] = vector.add(path[i], vector.new(0, -0.49, 0))
	end
    object:get_luaentity().action = true
    return true
end

--- @param pos table
--- @param short_def? table
--- @return object_ref
function intervention.start_npc_as(pos, short_def)
    local object = minetest.add_entity(pos, "intervention_default:npc")
    object:set_properties({
        mesh = "skinsdb_3d_armor_character_5.b3d",
        textures = {
            "blank.png",
            short_def.texture,
            "blank.png",
            "blank.png"
        },
        visual = "mesh",
        visual_size = {x = 1, y = 1},
        stepheight = 0.6
    })
    object:get_luaentity():start_npc(short_def.waypoints)
    return entity
end

--[[            waypoints = {{pos={x=19,y=28,z=-17}, wait=0},
            {pos={x=36,y=28,z=2}, wait=0},
            {pos={x=50,y=28,z=45}, wait=2},
            {pos={x=60,y=28,z=18}, wait=0},
            {pos={x=67,y=28,z=0}, wait=0},
            {pos={x=88,y=28,z=-23}, wait=0}]]

minetest.register_on_joinplayer(function(userdata, last_login)
    userdata:hud_set_flags({minimap=false, minimap_radar=false, basic_debug=false, chat=false})
    local meta = userdata:get_meta()
    if meta:get_int("int_p:plot") == 0 then meta:set_int("int_p:plot", 1) end
    if meta:get_int("int_p:done_" .. tostring(meta:get_int("int_p:plot"))) == 0 then
        intervention.plot[meta:get_int("int_p:plot")].once(userdata)
    end
    intervention.plot[meta:get_int("int_p:plot")].always(userdata)
    userdata:set_formspec_prepend(table.concat({
        "bgcolor[#00000000]",
        "background9[1,1;1,1;intervention_formspec_bg.png;true;7]",
    }))
    userdata:set_inventory_formspec("")
    userdata:hud_set_hotbar_image("intervention_hotbar.png")
    userdata:hud_set_hotbar_itemcount(9)
    userdata:set_properties({
        visual = "mesh",
        mesh = "skinsdb_3d_armor_character_5.b3d",
        textures = {"intervention_player.png", "blank.png", "blank.png", "blank.png"},
        collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
        visual_size = {x=1, y=1},
        stepheight = 0.6
    })
    local inv = userdata:get_inventory()
    inv:set_size("main", 9)
    inv:set_size("craft", 0)
    inv:set_size("hand", 1)
    inv:set_stack("hand", 1, {
        visual_scale = 1,
        wield_scale = {x=1,y=1,z=1},
        paramtype = "light",
        drawtype = "mesh"
    })
    inv:set_size("craftresult", 0)
    intervention.huds = {}
    local from_meta = minetest.get_player_by_name("singleplayer"):get_meta():get_float("int_p:fr_fc")
end)

function intervention.set_enviroment(player)
    player:override_day_night_ratio(0.2)
    local textures = {
        "FullMoonUp.jpg",
        "FullMoonDown.jpg",
        "FullMoonFront.jpg",
        "FullMoonBack.jpg",
        "FullMoonLeft.jpg",
        "FullMoonRight.jpg",
    }
    player:set_sky({
        base_color = "#24292c",
        type = "skybox",
        textures = textures,
        clouds = true
    })
    player:set_sun({visible = true, sunrise_visible = false, texture = "blank.png"})
    player:set_moon({visible = true, texture = "blank.png"})
    player:set_stars({visible = false})
    player:set_clouds({
        ensity = 0.25,
        color = "#ffffff80", 
        ambient = "#404040",
        height = 140, 
        thickness = 8, 
        speed = {x = -2, y = 2}
    })
end

--- @type float
intervention.freezing_factor = 100.0
--- @type boolean
intervention.freezing_toggle = false

--- @param userdata userdata
--- @return nil
function intervention.freeze(userdata)
    if intervention.freezing_toggle then return end
    local pos = userdata:get_pos()
    local warm_nodes = minetest.find_nodes_in_area(vector.add(pos, 5), vector.subtract(pos, 5), "group:warm", false)
    intervention.freezing_factor = math.min(math.max(intervention.freezing_factor - 0.05 + math.min(#warm_nodes*0.01, 0.08), 0), 100)

    -- Player has been frozen to death, send him back to control point
    if intervention.freezing_factor == 0 then
        intervention.freezing_toggle = true
        userdata:set_physics_override({speed=0,gravity=0,jump=0,sneak=false})
        userdata:set_velocity({x=0,y=-1,z=0})
        for i = 1, 100 do
            minetest.after(i*0.01, function() userdata:set_properties({eye_height=1.625-i*0.01}) end)
        end
        intervention.spectator(userdata, true)
        intervention.darkness(userdata, 2)
        userdata:hud_remove(intervention.huds.freezing_factor); intervention.huds.freezing_factor = nil
        userdata:hud_remove(intervention.huds.snow_outline); intervention.huds.snow_outline = nil
        minetest.after(3, function() 
            userdata:set_physics_override({speed=1,gravity=1,jump=1,sneak=true}) 
            userdata:set_properties({eye_height=1.625})
            intervention.spectator(userdata, false)
            intervention.freezing_factor = 100; intervention.freezing_toggle = false
        end)
        return
    end
    if not intervention.huds.freezing_factor then
        intervention.huds.freezing_factor = userdata:hud_add({
            hud_elem_type = "image",
            text = format_image("cyan", 100),
            position = {x=0.5, y=0},
            alignment = {x=0, y=1},
            offset = {x=0, y=1150},
            scale = {x=0.341, y=0.275}
        })
    end
    userdata:hud_change(intervention.huds.freezing_factor, "text", format_image("cyan", intervention.freezing_factor))
    if intervention.freezing_factor < 60 and not intervention.huds.snow_outline then
        intervention.huds.snow_outline = userdata:hud_add({
            hud_elem_type = "image",
            text = ("intervention_snow_outline.png^[opacity:0"),
            position = {x=0.5, y=0},
            alignment = {x=0, y=1},
            offset = {x=0, y=0},
            scale = {x=3.85, y=2.4}
        })
    elseif intervention.freezing_factor > 60 and intervention.huds.snow_outline then
        userdata:hud_remove(intervention.huds.snow_outline); intervention.huds.snow_outline = nil
    elseif intervention.freezing_factor < 60 then
        userdata:hud_change(intervention.huds.snow_outline, "text", ("intervention_snow_outline.png^[opacity:%d"):format(300-intervention.freezing_factor*5))
    end
end

local timer = 0
minetest.register_globalstep(function(dtime)
    local userdata = minetest.get_player_by_name("singleplayer"); if not userdata then return end
    if not intervention.freezing_toggle then
        local keys = userdata:get_player_control()
        if keys.up or keys.down or keys.left or keys.right then
            userdata:set_animation({x = 168, y = 187})
        else
            userdata:set_animation({x = 0, y = 79})
        end
        intervention.freeze(userdata)
        if userdata:get_pos().y < 16 then userdata:set_pos({x=50.5, y=100, z=-4.5}) end
        if timer == 10 and userdata:get_meta():get_int("int_p:plot") == 2 then
            minetest.add_particlespawner({
                amount = 100,
                time = 1,
                pos = {
                min = vector.offset(userdata:get_pos(), 10, 10, 10),
                max = vector.offset(userdata:get_pos(), -10, -10, -10)
                },
                vel = {
                min = vector.new(0, -1, 0),
                max = vector.new(0, -0.5, 0),
                },
                minsize = 2 - 1.5,
                maxsize = 2 + 1.5,
                glow = 14,
                texture = {
                name = "intervention_snowflake.png",
                alpha_tween = 100,
                scale_tween = {
                    {x = 1, y = 1},
                    {x = 0.2, y = 0.2},
                },
                },
                collisiondetection = true,
                collision_removal = true,
                minexptime = 3,
                maxexptime = 5,
            })
            timer = -1
        end
        timer = timer + 1
    end
end)

minetest.register_on_leaveplayer(function(userdata, timed_out)
    userdata:get_meta():set_float("int_p:fr_fc", intervention.freezing_factor)
end)