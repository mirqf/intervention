--- @diagnostic disable
local S = minetest.get_translator(minetest.get_current_modname())
intervention.helpful = nil

dialog.register_speaker("s", {
	name = "<...>",
	portrait = "glitch_dialog_portrait_system.png",
})

dialog.register_dialogtree("dialog:intro", {
	speeches = {
		{
			text = S("Oh, look, there's another one! Get up soon, you'll freeze. And follow me."),
			speaker = "s",
			options = {
				{ action = "quit", text = S("Stand Up") },
			}
		}
	},
    on_exit = function(userdata)
        for i = 1, 100 do
            minetest.after(i*0.01, function() userdata:set_properties({eye_height=0.625+i*0.01}) end)
        end
        userdata:set_animation({x = 0, y = 79})
        minetest.after(1, function()
            userdata:set_physics_override({speed=1,jump=1,gravity=1,sneak=true})
            intervention.spectator(userdata, false)
        end)
        intervention.animate_to(intervention.helpful, {x=129,y=25,z=67})
    end
})

intervention.plot = {
    {
        once = function() return end,
        always = function(userdata)
            intervention.freezing_toggle = true
            intervention.spectator(userdata, true)
            userdata:set_physics_override({speed=0,jump=0,gravity=0,sneak=false})
            userdata:set_animation({x = 162, y = 166}, 30)
            userdata:set_look_horizontal(math.rad(90))
            userdata:set_look_vertical(0)
            userdata:set_pos({x=6.4,y=1,z=2.5})
            userdata:set_properties({eye_height=0.5})
            local idx = userdata:hud_add({
                hud_elem_type = "image",
                position      = {x = 0.5, y = 0.5},
                offset        = {x = 0,   y = 0},
                text          = ("black.png^[opacity:%d"):format(300),
                alignment     = {x = 0, y = 0},
                scale         = {x = 4000, y = 2000},
                number = 0xD61818,
            })
            local handle = minetest.sound_play("hospital_ambience", {to_player=userdata:get_player_name(), gain=0.9})
            minetest.after(1, function() 
                for i = 300, 150, -1 do
                    minetest.after((300-i)*0.02, function() userdata:hud_change(idx, "text", ("black.png^[opacity:%d"):format(i)) end)
                end
            end)
            minetest.after(15, function() 
                minetest.sound_fade(handle, 0.2, 0.01) 
                intervention.darkness(userdata, 8)
                minetest.after(3, function() intervention.set_enviroment(userdata) userdata:set_pos({x=107,y=25.5,z=55}) end)
                userdata:get_meta():set_int("int_p:plot",2)
                minetest.after(13, function()
                    userdata:hud_remove(idx)
                    intervention.plot[2].once(userdata)
                    intervention.plot[2].always(userdata)
                end)
            end)
        end,
    },

    {
        once = function(userdata)
            userdata:get_meta():set_int("int_p:done_2", 1) 
            local object = minetest.add_entity({x=116,y=26,z=65}, "intervention_default:npc")
            object:set_properties({
                mesh = "skinsdb_3d_armor_character_5.b3d",
                textures = {
                    "intervention_player.png",
                    "blank.png",
                    "blank.png",
                    "blank.png"
                },
                visual = "mesh",
                visual_size = {x = 1, y = 1},
                stepheight = 0.6
            })
            object:set_yaw(math.rad(150))
            minetest.after(1, function() 
                intervention.animate_to(object, {x=108,y=26,z=55}) 
            end)
            minetest.after(10, function() dialog.show_dialogtree(userdata, "dialog:intro") end)
            intervention.helpful = object
        end,
        always = function(userdata)
            intervention.freezing_toggle = false
            intervention.set_enviroment(userdata)
        end
    }, 

    {
        once = function() return end,
        always = function(userdata)
            intervention.freezing_toggle = true
            intervention.spectator(userdata, true)
            if intervention.huds.freezing_factor then userdata:hud_remove(intervention.huds.freezing_factor) end
            if intervention.huds.snow_outline then userdata:hud_remove(intervention.huds.snow_outline) end
            userdata:set_physics_override({speed=0,jump=0,gravity=0,sneak=false})
            intervention.darkness(userdata, 5)
            minetest.after(3, function()
                userdata:set_animation({x = 162, y = 166}, 30)
                userdata:set_look_horizontal(math.rad(90))
                userdata:set_look_vertical(0)
                userdata:set_pos({x=6.4,y=1,z=2.5})
                userdata:set_properties({eye_height=0.5})
                userdata:get_inventory():set_list("main", {})
                minetest.after(7, function()
                    for i = 1, 100 do
                        minetest.after(i*0.01, function() userdata:set_properties({eye_height=0.625+i*0.01}) end)
                    end
                    minetest.after(1, function() 
                        userdata:set_physics_override({speed=1,jump=1,gravity=1,sneak=true})
                        intervention.spectator(userdata, false)
                        userdata:set_animation({x = 0, y = 79})
                    end)
                end)
            end)
        end
    }
}

minetest.register_chatcommand("try", {
    func = function(name)
        intervention.plot[2].once(minetest.get_player_by_name(name))
    end
})