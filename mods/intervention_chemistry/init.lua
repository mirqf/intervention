--- @diagnostic disable
local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.colorize
local F = minetest.formspec_escape
local m = math.min
local r = math.random
dofile(minetest.get_modpath(minetest.get_current_modname()).."/table.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/element_constructor.lua")
--dofile(minetest.get_modpath(minetest.get_current_modname()).."/lab_table.lua")


for position, data in ipairs(intervention.elements) do
    minetest.register_craftitem("intervention_chemistry:"..data.Name:lower(), {
        description = data.Name,
        groups = {},
        inventory_image = "intervention_" .. data.Classification .. ".png",
        wield_image = "",
        wield_overlay = "",
        wield_scale = {x = 1, y = 1, z = 1},
    })
end