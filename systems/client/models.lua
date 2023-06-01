
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
            frametime = 0,
            colour = {1.0, 1.0, 1.0, 1.0}
        }
    end

    entities.get(entity_id).parts = parts
end

hooks.add("update", function(dt)
    for _, entity in entities.all() do
        if entity.parts then
            for _, part in ipairs(entity.parts) do
                if part.part.selector then
                    -- Animation
                    if part.part.selector.animation then
                        local selected = part.part.selector.animation(entity)
                        if selected and selected ~= part.animation then
                            part.animation = selected
                            part.frametime = 0.0
                            part.frame = 1
                        end
                    end

                    -- Direction
                    if part.part.selector.direction then
                        local selected = part.part.selector.direction(entity)
                        if selected and selected ~= part.direction then
                            part.direction = selected
                            part.frametime = 0.0
                            part.frame = 1
                        end
                    end
                    
                    -- Colours
                    if part.part.selector.colour then
                        local colour = part.part.selector.colour(entity)
                        if colour then
                            part.colour = colour
                        else
                            part.colour = {1.0, 1.0, 1.0, 1.0}                            
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
                    part.frame = part.frame + 1
                end

                if not directed_animation[part.frame] then
                    part.frame = 1
                end
            end
        end
    end
end)

hooks.add("draw_world", function()
    for _, entity in entities.all() do
        if entity.interpolated_position and entity.parts then
            for _, part in ipairs(entity.parts) do
                love.graphics.setColor(unpack(part.colour))
                local frame = part.part.animations[part.animation][part.direction][part.frame]

                local x = entity.interpolated_position.x + part.offset.x + frame.x
                local y = entity.interpolated_position.y + part.offset.y + frame.y

                love.graphics.draw(part.part.image, frame.quad, x, y)
            end
        end

    end
end)

local function direction_from_mouse(entity)
    if entity.mouseX and entity.mouseY then
        local w, h = love.graphics:getDimensions()
        x = entity.mouseX - w / 2
        y = entity.mouseY - h / 2
        local angle = math.floor(((math.atan2(y, x) + math.pi) / (2*math.pi) * 8 + (1/16)) % 8) + 1
        return directions[angle]
    end
end

local function direction_from_velocity(entity)
    if entity.body then
        local x, y = entity.body:getLinearVelocity()

        if math.abs(x)+math.abs(y) > 1 then
            local angle = math.floor(((math.atan2(y, x) + math.pi) / (2*math.pi) * 8 + (1/16)) % 8) + 1
            return directions[angle]
        end
    end
end

local function direction_from_part(part_name)
    return function(entity)
        if entity.parts then
            for _, part in pairs(entity.parts) do
                if part.name == part_name then
                    return part.direction
                end
            end
        end
    end
end

local function colour_from_entity(entity)
    return {entity.colour.r, entity.colour.g, entity.colour.b, entity.colour.a}
end


---@class VelocityCutoff
---@field public velocity number @velocity at which this animation is activated.
---@field public animation string @name of animation to activate.

--- Sets the *part*'s current animation based on the velocity of
--- the physics body (if any) of the entity to which the part
--- is assigned.
---
--- For example:
---
--- ```lua
--- models.selector.animation.from_velocity({
--- {velocity =  0.0, animation = "idle"},
---   {velocity = 10.0, animation = "walk"},
---   {velocity = 30.0, animation =  "run"},
--- })
--- ```
--- 
---@param velocity_cutoffs VelocityCutoff[] @list of cutoffs.
---@return function @selector which deduces current animation from an entity
local function animation_from_velocity(velocity_cutoffs)
    return function(entity)
        if entity.body then
            local x, y = entity.body:getLinearVelocity()
            
            local squared_velocity = x*x+y*y

            -- go through the velocity cutoffs backwards, returning
            -- the first one that is below our current velocity
            for i = #velocity_cutoffs, 1, -1 do
                local cutoff = velocity_cutoffs[i]
                if squared_velocity > cutoff.velocity*cutoff.velocity then
                    return cutoff.animation
                end
            end

            -- default to first one
            return velocity_cutoffs[1].animation
        end
    end
end

---@class Image @created with `love.graphics.newImage("assets/textures/...")`

---@class Direction: string @One of n, ne, e, se, s, sw, w, nw

---@class AnimationSelector: function(entity: Entity): string @Name of the animation to use
---@class DirectionSelector: function(entity: Entity): Direction
---@class ColourSelector: function(entity: Entity): number[4]

---@class Selectors @table of functions for deriving attributes of the part from its associated entity
---@field animation function(entity: Entity): string
---@field direction function(entity: Entity): Direction
---@field colour function(entity: Entity): number[4]

---@class Quad @from `love.graphics.newQuad`

---@class Frame
---@field quad Quad
---@field time number @time in seconds for this frame to run before switching to the next one.
---@field x number? @x-offset of this frame relative to the part.
---@field y number? @y-offset of this frame relative to the part.

---@alias Frames Frame[] @array of `Frame`s
---@alias Animation table<Direction, Frames> @Table of directions and their associated animations.

---@class Part @An animated part
---@field image Image @Source spritesheet from which the quads are rendered.
---@field selector Selectors? @Optional selectors for part attributes
---@field animations table<string, Animation>
return {
    set_model = set_model,
    directions = directions,
    selectors = {
        direction = {
            from_mouse = direction_from_mouse,
            from_velocity = direction_from_velocity,
            from_part = direction_from_part,
        },
        animation = {
            from_velocity = animation_from_velocity
        },
        colour = {
            from_entity = colour_from_entity
        }
    },
}
