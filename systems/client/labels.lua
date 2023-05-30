local font = love.graphics.newFont(9, "mono")
font:setFilter("nearest")

hooks.add("draw_world", function()
    for _, entity in entities.all() do
        if entity.interpolated_position and entity.overhead_label then
            if entity.colour then
                love.graphics.setColor(entity.colour.r, entity.colour.g, entity.colour.b)
            end
            local w, h = entity.overhead_label:getDimensions()
            love.graphics.draw(entity.overhead_label, entity.interpolated_position.x - w / 2,
                entity.interpolated_position.y - 30)
        end
    end
end)

local function set_label(id, text)
    entity = entities.get(id)
    if not entity.overhead_label then
        local label = love.graphics.newText(font, {{1.0, 1.0, 1.0}, text})
        entity.overhead_label = label
    else
        entity.overhead_label:set(text)
    end
end

return {
    set_label = set_label
}
