local world = nil
local velocity_iterations = 8
local position_iterations = 3
local drag_coefficient = 5

local function collision_callback(a, b, contact)
    local a, b = a:getUserData(), b:getUserData()

    if a and b and entities.get(a) and entities.get(b) then
        hooks.call("collision", a, b, contact)
    end
end

hooks.add("load", function()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(collision_callback)
end)

local function new_body(type)
    return love.physics.newBody(world, 0, 0, type)
end

local function apply_drag(dt)
    for _, entity in entities.all() do
        if entity.body then
            local x, y = entity.body:getLinearVelocity()
            entity.body:applyForce(-x * drag_coefficient, -y * drag_coefficient)
        end
    end
end

local function interpolate_position(dt)
    for _, entity in entities.all() do
        if entity.body and entity.interpolated_position then
            local x, y = entity.body:getPosition()

            local x_distance = x - entity.interpolated_position.x
            local y_distance = y - entity.interpolated_position.y

            entity.interpolated_position.x = entity.interpolated_position.x + x_distance * dt * 20.0
            entity.interpolated_position.y = entity.interpolated_position.y + y_distance * dt * 20.0
        end
    end
end

hooks.add("fixed_timestep", function(fixed_timestep)
    world:update(fixed_timestep, velocity_iterations, position_iterations)
    apply_drag(fixed_timestep)
    interpolate_position(fixed_timestep)
end)

messages.subscribe("update-body", function(peer, msg)
    local player_id = tonumber(msg.id);

    local entity = entities.get(tonumber(msg.id))

    if not entity then return end

    if entity.body then
        entity.body:setPosition(tonumber(msg.x), tonumber(msg.y))
        entity.body:setLinearVelocity(tonumber(msg.vx), tonumber(msg.vy))
    end
end)

hooks.add("draw_world", function()
    for ent_id, ent in entities.all() do
        love.graphics.setColor({1, 1, 1})

        if ent.body and ent.interpolated_position then
            --local x, y = ent.body:getPosition()
            local x = ent.interpolated_position.x
            local y = ent.interpolated_position.y
            
            for _, fixture in pairs(ent.body:getFixtures()) do
                local shape = fixture:getShape()
                
                if shape:getType() == "polygon" and ent.vertices then
                    local verts = {}
                    for k, v in pairs(ent.vertices) do
                        if k%2 == 0 then
                            verts[k] = v+y
                        else
                            verts[k] = v+x
                        end
                    end

                    love.graphics.polygon("line", verts)
                end
            end
        end
    end
end)

return {
    new_body = new_body
}
