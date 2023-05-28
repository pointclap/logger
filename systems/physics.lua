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

local function apply_drag(dt)
    for _, player in pairs(players) do
        if player.body then
            local x, y = player.body:getLinearVelocity()
            player.body:applyForce(-x * drag_coefficient, -y * drag_coefficient)
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
        player_movement(fixed_timestep)
        world:update(fixed_timestep, velocity_iterations, position_iterations)
        apply_drag(fixed_timestep)
        interpolate_position(fixed_timestep)
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
