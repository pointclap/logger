local world = nil
local velocity_iterations = 8
local position_iterations = 3
local drag_coefficient = 5

function init_physics()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(collision_callback)
end

function collision_callback(a, b, contact)
    local a, b = a:getUserData(), b:getUserData()

    for _, player_id in pairs({a, b}) do
        if players[player_id].contact_sound then
            players[player_id].contact_sound:play()
        end
    end
end

local accumulated_deltatime = 0
local fixed_timestep = 0.008
function update_physics(dt)
    accumulated_deltatime = accumulated_deltatime + dt

    while accumulated_deltatime > fixed_timestep do
        player_movement(fixed_timestep)
        accumulated_deltatime = accumulated_deltatime - fixed_timestep
        world:update(fixed_timestep, velocity_iterations, position_iterations)
        apply_drag(fixed_timestep)
        interpolate_model_location(fixed_timestep)
    end
end

function apply_drag(dt)
    for _, player in pairs(players) do
        if player.body then
            local x, y = player.body:getLinearVelocity()
            player.body:applyForce(-x * drag_coefficient, -y * drag_coefficient)
        end
    end
end

subscribe_message("new-player", function(msg)
    local id = tonumber(msg.id);

    if players[id] == nil then
        players[id] = {}
    end

    local body = love.physics.newBody(world, 0, 0, "dynamic");
    local shape = love.physics.newCircleShape(10)
    local fixture = love.physics.newFixture(body, shape, 5)

    -- Store the entity id in the body, so we can do collision stuff
    fixture:setUserData(id)

    players[id].body = body
end)
