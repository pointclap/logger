local world = nil
local velocity_iterations = 8
local position_iterations = 3
local drag_coefficient = 5

entid = 0
players = {}
entities = {}

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
    local shape = love.physics.newPolygonShape(-size / 2, -size / 2,
                                                size / 2, -size / 2,
                                                size / 2,  size / 2,
                                               -size / 2,  size / 2)

    local fixture = love.physics.newFixture(body, shape, 5)
    fixture:setUserData(ent_id)
    entities[ent_id] = {}
    entities[ent_id].interpolated_position = {
        x = pos_x,
        y = pos_y
    }
    entities[ent_id].body = body
    entities[ent_id].vertices = {shape:getPoints()}
end

local function spawnPlayer(player_id)
    local body = love.physics.newBody(world, 0, 0, "dynamic");
    local shape = love.physics.newCircleShape(10)
    local fixture = love.physics.newFixture(body, shape, 5)

    -- Store the entity id in the body, so we can do collision stuff
    fixture:setUserData(player_id)

    return body
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

    for ent_id, ent in pairs(entities) do
        if ent.body and ent.interpolated_position and ent.interpolated_position.x and ent.interpolated_position.y then
            local x, y = ent.body:getPosition()

            local x_distance = x - ent.interpolated_position.x
            local y_distance = y - ent.interpolated_position.y

            ent.interpolated_position.x = ent.interpolated_position.x + x_distance * dt * 20.0
            ent.interpolated_position.y = ent.interpolated_position.y + y_distance * dt * 20.0
        end
    end
end

hooks.add("fixed_timestep", function(fixed_timestep)
    world:update(fixed_timestep, velocity_iterations, position_iterations)
    apply_drag(fixed_timestep)
    interpolate_position(fixed_timestep)
end)

messages.subscribe("spawn-box", function(peer, msg)
    spawnBox(tonumber(msg.ent_id), tonumber(msg.pos_x), tonumber(msg.pos_y), tonumber(msg.size))
end)

messages.subscribe("update-world", function(peer, msg)
    local ent_id = tonumber(msg.ent_id)

    if not entities[ent_id] then return end

    if entities[ent_id].body then
        entities[ent_id].body:setPosition(tonumber(msg.x), tonumber(msg.y))
        entities[ent_id].body:setLinearVelocity(tonumber(msg.vx), tonumber(msg.vy))
    end
end)

hooks.add("draw_world", function()
    if is_server then
        return
    end

    for ent_id, ent in pairs(entities) do
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
    spawnBox = spawnBox,
    spawnPlayer = spawnPlayer
}
