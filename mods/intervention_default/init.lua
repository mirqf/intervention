--- @diagnostic disable
local S = minetest.get_translator(minetest.get_current_modname())
local colors = {"light_purple", "blue", "red", "green", "yellow", "dark_purple", "white"}
local storage = minetest.get_mod_storage()
intervention = {}

function intervention.rollback()
    for _, userdata in ipairs(minetest.get_connected_players()) do
        if vector.distance(userdata:get_pos(), {x=0,y=0,z=0}) > 50 then
            intervention.darkness(userdata, 2)
            minetest.sound_play("todo", {to_player=userdata:get_player_name()})
            minetest.after(3, function() userdata:set_pos({x=0,y=0,z=0}) end)
        end
    end
end

function intervention.darkness(userdata, delay)
    local idx = userdata:hud_add({
        hud_elem_type = "image",
        position      = {x = 0.5, y = 0.5},
        offset        = {x = 0,   y = 0},
        text          = ("black.png^[opacity:%d"):format(0),
        alignment     = {x = 0, y = 0},
        scale         = {x = 4000, y = 2000},
        number = 0xD61818,
    })
    for i = 1, 300 do
        minetest.after(0.01*i, function() userdata:hud_change(idx, "text", ("black.png^[opacity:%d"):format(i)) end)
    end
    minetest.after(0.01*300 + delay, function()
        for i = 300, 1, -1 do
            minetest.after(3-0.01*i, function() userdata:hud_change(idx, "text", ("black.png^[opacity:%d"):format(i)) end)
        end
    end)
end

local function format_image(color, percentage)
    local index = math.abs(table.indexof(colors, color))*2-1
    return string.format("(mcl_bossbars.png"
        .. "^[transformR270"
        .. "^[verticalframe:14:" .. (index - 1)
        .. "^(mcl_bossbars_empty.png"
        .. "^[lowpart:%d:mcl_bossbars.png"
        .. "^[transformR270"
        .. "^[verticalframe:14:" .. index .. "))^[resize:1456x40", percentage)
end

function intervention.init_bossbar(userdata, label, value)
    local username = userdata:get_player_name()
    if intervention.huds[username] then
        for _, idx in pairs(intervention.huds) do userdata:hud_remove(idx) end
    end
    intervention.huds[username] = {
        text = userdata:hud_add({
            hud_elem_type = "text",
            text = label,
            number = tonumber(("red"):sub(2,7), 16),
            position = {x=0.5, y=0},
            alignment = {x=0, y=1},
            offset = {x=0, y=0}
        }),
        image = userdata:hud_add({
            hud_elem_type = "image",
            text = format_image("red", value),
            position = {x=0.5, y=0},
            alignment = {x=0, y=1},
            offset = {x=0, y=25},
            scale = {x=0.375, y=0.375}
        })
    }
    return intervention.huds[username]
end

-- DEBUG ONLY
core.settings:set("time_speed", 0)

-- Commands, their usage can breake the game or change performance.
local disallowed_chatcommands = {"deleteblocks", "emergeblocks", "clearobjects", "give", "giveme", "spawnentity", "teleport", "pulverize", "clearinv"}
for _, command in ipairs(disallowed_chatcommands) do
    minetest.unregister_chatcommand(command)
end

minetest.register_alias("mapgen_water_source", "air")
minetest.register_alias("mapgen_stone", "intervention_items:stone")
minetest.register_alias("intervention_nodes:concrete_white", "intervention_items:concrete_white")

if not vector.in_area then 
	function vector.in_area(pos, min, max)
		min, max = vector.sort(min, max)
        minetest.chat_send_all(dump(min) .. " " .. dump(max))
		return ((min.x <= pos.x <= max.x) and (min.y <= pos.y <= max.y) and (min.z <= pos.z <= max.z))
	end
end

function intervention.spectator(userdata, enabled)
    userdata:hud_set_flags({
        healthbar = not enabled,
		breathbar = not enabled,
        wielditem = not enabled,
        crosshair = not enabled,
        hotbar = not enabled
    })
end

local locations = {
    ["intervention_hospital"] = {
        pos = {x=0, y=0, z=0},
        size = 10,
        schematic = "intervention_hospital"
    }, 

    ["intervention_main_base"] = {
        pos = {x=0,y=25,z=0},
        size = 90,
        schematic = "main",
        on_place = function()
        end
    }
}

if storage:get_int("mapgen_init") == 0 then
    minetest.after(0, function() 
        for location, definition in pairs(locations) do
            minetest.emerge_area(definition.pos, vector.add(definition.pos, definition.size), function(blockpos, action, calls_remaining)
                if calls_remaining > 0 then return end
                if action ~= minetest.EMERGE_FROM_DISK and action ~= minetest.EMERGE_FROM_MEMORY and action ~= minetest.EMERGE_GENERATED then return end
                minetest.place_schematic(definition.pos, ("%s/schems/%s.mts"):format(minetest.get_modpath("intervention_default"), definition.schematic), "0", {}, true, "")
                if definition.on_place then definition.on_place() end
            end)
        end
        storage:set_int("mapgen_init", 46)
    end)
end

if not minetest.is_singleplayer() then
    error("-!- Multiplayer is not allowed.")
end

minetest.register_entity("intervention_default:npc", {
    initial_properties = {
        visual = "mesh",
        physical = false,
        mesh = "skinsdb_3d_armor_character_5.b3d",
        hp_max = 32,
        textures = {},
        collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
    },
    on_punch = function(self, puncher, time_from_last_punch, toolcaps, dir, damage)
        return 0
    end,
    on_step = function(self, dtime)
        if self.action then
            -- Thanks to rubenwardy (Conquer)
            if not self.path then return end
            local next = self.path[self.path_i]
            if not next then
                self.object:set_velocity(vector.new())
                self.object:set_animation({x = 0, y = 79}, 30, 0)
                self.path = nil
                return
            end
            local from = self.object:get_pos()
            local distance = vector.distance(from, next)
            if distance < 0.1 then
                self.path_i = self.path_i + 1
                self:on_step(dtime)
                return
            end
            local step = vector.multiply(vector.normalize(vector.subtract(next, from)), 1)
            self.object:set_velocity(step)
            local target = vector.add(from, vector.multiply(step, dtime))
            self.object:move_to(target, true)
            self.object:set_yaw(math.atan2(step.z, step.x) - math.pi / 2)
            self.object:set_animation({x = 168, y = 187}, 30, 0)
        end
        if not self.waiting and self.going_to and vector.distance(self.object:get_pos(), self.going_to) < 1 and self.coroutine then
            self.waiting = true
            minetest.after(self.poslist[self.current].wait, function()
                self.current = self.current + (self.reversed and -1 or 1)
                if self.current == 1 then self.reversed = false elseif self.current == #self.poslist then self.reversed = true end
                coroutine.resume(self.coroutine) 
                self.waiting = false
            end)
        end
    end,
    get_staticdata = function(self)
        return minetest.write_json({
            _poslist = self.poslist,
            _going_to = self.going_to,
            _waiting = self.waiting,
            _reversed = self.reversed,
            _current = self.current,
            _action = self.action,
            _texture = self.object:get_properties().textures
        })
    end,
    on_activate = function(self, staticdata, dtime)
        local data = (staticdata ~= "" and minetest.parse_json(staticdata) or nil)
        self.poslist = (data and (data._poslist and data._poslist or {}) or {})
        self.going_to = (data and data._going_to or nil)
        self.waiting = (data and data._waiting or nil)
        self.reversed = (data and data._reversed or nil)
        self.current = (data and (data._current and data._current or 1) or 1)
        self.action = (data and data._action or nil)
        if self.poslist and #self.poslist > 0 then self:start_npc(self.poslist) end
        if data and data._texture then self.object:set_properties({textures=data._texture}) end
    end,
    start_npc = function(self, poslist)
        self.poslist = poslist
        self.coroutine = coroutine.create(function()
            while true do
                intervention.animate_to(self.object, self.poslist[self.current].pos)
                self.going_to = self.poslist[self.current].pos
                coroutine.yield()
            end
        end)
        coroutine.resume(self.coroutine)
    end
})