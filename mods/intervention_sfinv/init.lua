--- @diagnostic disable
intervention.registered_on_player_receive_form = {}

--- @param formname string
--- @param func function
--- @return nil
function intervention.register_on_player_receive_form(formname, func)
    intervention.registered_on_player_receive_form[formname] = func
end

--- @param username string
--- @param formname string
--- @param title string
--- @param options table
--- @return nil
function intervention.show_dialog_screen(username, formname, title, options)
    local text = ""
    for row, text in ipairs(minetest.wrap_text(title, 48, true)) do
        text = text .. string.format("label[%f,1;%s]", row*0.25, text)
    end
    local buttons = ""
    if not options or #options == 0 then buttons = "" end
    minetest.show_formspec(username, formname, table.concat({
        "formspec_version[4]",
        "size[10,10]",
        text,
        buttons
    }))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local func = intervention.registered_on_player_receive_form[formname]
    if func then func(player, formname, fields) end
end)