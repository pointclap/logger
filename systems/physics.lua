local world = nil
local velocity_iterations = 8
local position_iterations = 3
local drag_coefficient = 5

function init_physics()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true)
end



local accumulated_deltatime = 0
function update_physics(dt)
    accumulated_deltatime = accumulated_deltatime + dt

    while accumulated_deltatime > 0.008 do
        accumulated_deltatime = accumulated_deltatime - 0.008
        for _, player in pairs(players) do
            if player.body ~= nil then
                if player.velocity ~= nil then
                    player.body:setLinearVelocity(player.velocity.x, player.velocity.y)
                end

                if player.position ~= nil then
                    player.body:setPosition(player.position.x, player.position.y)
                end
            end
        end

        world:update(dt, velocity_iterations, position_iterations)

        for _, player in pairs(players) do
            if player.body then
                if player.velocity then
                    local x, y = player.body:getLinearVelocity()
                    player.velocity = {
                        x = x,
                        y = y
                    }
                end

                if player.position ~= nil then
                    local x, y = player.body:getPosition()
                    player.position = {
                        x = x,
                        y = y
                    }
                end
            end
        end
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

    players[tonumber(msg.id)].velocity = {
        x = 0,
        y = 0
    };

    players[tonumber(msg.id)].position = {
        x = 0,
        y = 0
    }

    local body = love.physics.newBody(world, 0, 0, "dynamic");
    local shape = love.physics.newCircleShape(10)
    love.physics.newFixture(body, shape, 5)

    players[tonumber(msg.id)].body = body
end)
