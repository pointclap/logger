local world = nil
local velocity_iterations = 8
local position_iterations = 3
local drag_coefficient = 5

local function collision_callback(a, b, contact)
    local a, b = a:getUserData(), b:getUserData()

    for _, player_id in pairs({a, b}) do
        if players[player_id] and players[player_id].contact_sound then
            players[player_id].contact_sound:play()
        end
    end
end

hooks.add("load", function()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(collision_callback)
end)

local function spawnBox(ent_id, pos_x, pos_y, size)
    local body = love.physics.newBody(world, pos_x, pos_y, "dynamic");
    local shape = love.physics.newPolygonShape(-size/2, -size,
                                                size/2, -size/2,
                                                size/2,  size/2,
                                               -size/2,  size/2)
    local fixture = love.physics.newFixture(body, shape, 5)
    fixture:setUserData(ent_id)
    entities[ent_id] = {}
    entities[ent_id].body = body
    entities[ent_id].vertices = {shape:getPoints()}
    for k,v in pairs(entities[ent_id].vertices) do
        print(k .. ": " .. v)
    end
    
    if is_server then
        enethost:broadcast(encode_message({
            cmd = "spawn-box",
            ent_id = ent_id,
            pos_x = pos_x,
            pos_y = pos_y,
            size = size
        }))
    end
end

local function apply_drag(dt)
    for _, player in pairs(players) do
        if player.body then
            local x, y = player.body:getLinearVelocity()
            player.body:applyForce(-x * drag_coefficient, -y * drag_coefficient)
        end
    end

    for ent_id, ent in pairs(entities) do
        if ent.body then
            local x, y = ent.body:getLinearVelocity()
            ent.body:applyForce(-x * drag_coefficient, -y * drag_coefficient)
        end
    end
end

local function interpolate_position(dt)
    for _, player in pairs(players) do
        if player.body and player.interpolated_position then
            local x, y = player.body:getPosition()

            local x_distance = x - player.interpolated_position.x
            local y_distance = y - player.interpolated_position.y

            player.interpolated_position.x = player.interpolated_position.x + x_distance * dt * 20.0
            player.interpolated_position.y = player.interpolated_position.y + y_distance * dt * 20.0
        end
    end
end

hooks.add("fixed_timestep", function(fixed_timestep)
    world:update(fixed_timestep, velocity_iterations, position_iterations)
    apply_drag(fixed_timestep)
    interpolate_position(fixed_timestep)
end)

messages.subscribe("spawn-box", function(msg)
    print("spawning a box!")
    spawnBox(msg.ent_id, msg.pos_x, msg.pos_y, msg.size)
end)

messages.subscribe("update-world", function(msg)
    local ent_id = tonumber(msg.ent_id)
    if not entities[ent_id] then return end
    
    if entities[ent_id].body then
        entities[ent_id].body.x = tonumber(msg.x)
        entities[ent_id].body.y = tonumber(msg.y)
    end
end)

messages.subscribe("new-player", function(msg)
    local id = tonumber(msg.id);

    if players[id] == nil then
        players[id] = {}
    end

    players[id].interpolated_position = {
        x = 0,
        y = 0
    }

    local body = love.physics.newBody(world, 0, 0, "dynamic");
    local shape = love.physics.newCircleShape(10)
    local fixture = love.physics.newFixture(body, shape, 5)

    -- Store the entity id in the body, so we can do collision stuff
    fixture:setUserData(id)

    players[id].body = body
end)

hooks.add("draw_world", function()
    if is_server then return end
    
    
    for ent_id, ent in pairs(entities) do
        love.graphics.setColor({1, 1, 1})

        if ent.body then
            local x, y = ent.body:getPosition()

            for _, fixture in pairs(ent.body:getFixtures()) do
                local shape = fixture:getShape()

                if shape:getType() == "polygon" and ent.vertices then
                    local verts = {}
                    for k,v in pairs(ent.vertices) do
                        if k % 2 == 0 then
                            verts[k] = v + x
                        else
                            verts[k] = v + y
                        end
                    end

                    love.graphics.polygon("line", verts)
                end
            end
        end
    end
end)

return {
    spawnBox = spawnBox
}