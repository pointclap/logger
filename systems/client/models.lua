local models = {
    character = require("assets.models.character")
}

local function set_model(entity_id, model_name)
    if not models[model_name] then
        log.warn("attempted to unknown model " .. model_name .. " for entity €" .. entity_id)
    end

    -- Models are templates, so we need to do a semi-deep copy of each part
    -- for the entity, so we can store frame and animation data alongside
    -- each part without thrashing around in the "real" part table.
    local parts = {}
    for part_id, part in ipairs(models[model_name].parts) do
        parts[part_id] = {
            part_name = part.name,
            part = part.part,
            offset = part.offset,
            frame = 1,
            direction = "s",
            animation = next(part.part.animations),
            frametime = 0
        }
    end

    entities.get(entity_id).parts = parts
end

hooks.add("update", function(dt)
    for _, entity in entities.all() do
        if entity.parts then
            for _, part in ipairs(entity.parts) do
                part.frametime = part.frametime + dt
                local directed_animation = part.part.animations[part.animation][part.direction]

                if part.frametime > directed_animation[part.frame].time then
                    part.frametime = part.frametime % directed_animation[part.frame].time
                    part.frame = (part.frame + 1) % #directed_animation + 1
                end
            end
        end
    end
end)

hooks.add("draw_world", function()
    love.graphics.setColor(1, 1, 1, 1)
    for _, entity in entities.all() do
        if entity.interpolated_position and entity.parts then
            for _, part in ipairs(entity.parts) do
                local frame = part.part.animations[part.animation][part.direction][part.frame]

                local x = entity.interpolated_position.x + frame.x + part.offset.x
                local y = entity.interpolated_position.y + frame.y + part.offset.y

                love.graphics.draw(part.part.image, frame.quad, x, y)
            end
        end

    end
end)

return {
    set_model = set_model
}
