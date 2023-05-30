local font = love.graphics.newFont(9, "mono")
font:setFilter("nearest")

hooks.add("draw_world", function()
    for _, player in pairs(players) do
        if player.interpolated_position and player.overhead_label then
            if player.colour then
                love.graphics.setColor(
                    player.colour.r,
                    player.colour.g,
                    player.colour.b
                )
            end
            local w, h = player.overhead_label:getDimensions()
            love.graphics.draw(player.overhead_label, player.interpolated_position.x - w / 2, player.interpolated_position.y - 30)
        end
    end
end)

local function set_label(player_id, text)
    if not players[player_id].overhead_label then
        local label = love.graphics.newText(font, {{ 1.0, 1.0, 1.0 }, text})
        players[player_id].overhead_label = label
    else
        players[player_id].overhead_label:set(text)
    end
end

return {
    set_label = set_label
}
