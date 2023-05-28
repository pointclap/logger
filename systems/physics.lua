local world = nil
local velocity_iterations = 8
local position_iterations = 3
local drag_coefficient = 5

function init_physics()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true)
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
        interpolate_player_location(fixed_timestep)
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
    if players[tonumber(msg.id)] == nil then
        players[tonumber(msg.id)] = {}
    end

    local body = love.physics.newBody(world, 0, 0, "dynamic");
    local shape = love.physics.newCircleShape(10)
    love.physics.newFixture(body, shape, 5)

    players[tonumber(msg.id)].body = body
end)
