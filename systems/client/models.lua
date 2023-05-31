local directions = {"w", "nw", "n", "ne", "e", "se", "s", "sw"}

local function set_model(entity_id, model)
    -- Models are templates, so we need to do a semi-deep copy of each part
    -- for the entity, so we can store frame and animation data alongside
    -- each part without thrashing around in the "real" part table.
    local parts = {}
    for part_id, part in ipairs(model.parts) do
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
                if part.part.selector then
                    if part.part.selector.animation then
                        local selected = part.part.selector.animation(entity)
                        if selected ~= part.animation then
                            part.animation = selected
                            part.frametime = 0.0
                            part.frame = 1
                        end
                    end
                    if part.part.selector.direction then
                        local selected = part.part.selector.direction(entity)
                        if selected ~= part.direction then
                            part.direction = selected
                            part.frametime = 0.0
                            part.frame = 1
                        end
                    end
                end
            end
        end
    end
end)

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

local function direction_from_mouse(entity)
    -- get angle from player to their mouse
    if entity.mouseX and entity.mouseY then
        local w, h = love.graphics:getDimensions()
        x = entity.mouseX - w / 2
        y = entity.mouseY - h / 2
        log.error(entity.mouseX, entity.mouseY)
        local angle = math.floor(((math.atan2(y, x) + math.pi) / (2*math.pi) * 8 + (1/16)) % 8) + 1
        return directions[angle]
    else
        return "s"
    end
end

-- call using:
--   {{0, "stand"}, {10, "walk"}, {20, "run"}, {100, "fly"}}
-- for example
local function animation_from_velocity(velocity_cutoffs)
    return function(entity)
        if entity.body then
            local x, y = entity.body:getLinearVelocity()
            
            local squared_velocity = x*x+y*y

            -- go through the velocity cutoffs backwards, returning
            --  the first one that is below our current velocity
            for i = #velocity_cutoffs, 1, -1 do
                local v = velocity_cutoffs[i]
                if squared_velocity > v[1]*v[1] then
                    return v[2]
                end
            end

            -- default to first one
            return velocity_cutoffs[1][2]
        end
    end
end

return {
    set_model = set_model,
    directions = directions,
    selectors = {
        direction = {
            from_mouse = direction_from_mouse
        },
        animation = {
            from_velocity = animation_from_velocity
        }
    }
}
