hooks.add("uncaught-message", function(peer, msg)
    network.broadcast(msg)
end)

local debug = require("systems.client.debug")
entities = require("systems.client.entities")
models = require("systems.client.models")

labels = require("systems.client.labels")
require("systems.client.grass")
require("systems.client.players")

username = nil
tick_rate = 1 / 10

hooks.add("load", function(args)
    username = args[2]
    network.connect(args[1]);

    love.graphics.setDefaultFilter("nearest", "nearest", 0)
end)

hooks.add("quit", function()
    network.broadcast({
        cmd = "player-left"
    })
end)

hooks.add("draw", function()
    hooks.call("draw_local_pre")

    local width, height = love.graphics.getDimensions()
    local player = entities.get(localplayer)
    if player then
        love.graphics.push()
        love.graphics.translate(-player.interpolated_position.x + width / 2,
            -player.interpolated_position.y + height / 2)
        hooks.call("draw_world")
        love.graphics.pop()
    end

    hooks.call("draw_local")
end)

messages.subscribe("spawn-box", function(peer, msg)
    local id = tonumber(msg.id)
    local x, y = tonumber(msg.pos_x), tonumber(msg.pos_y)
    local size = tonumber(msg.size)

    local body = physics.new_body("dynamic");
    body:setPosition(x, y)
    local shape = love.physics.newPolygonShape(-size / 2, -size / 2, size / 2, -size / 2, size / 2, size / 2, -size / 2,
        size / 2)

    local fixture = love.physics.newFixture(body, shape, 5)
    fixture:setUserData(id)

    local entity = entities.get(id)
    entity.interpolated_position = {
        x = x,
        y = y
    }
    entity.body = body
    entity.vertices = {shape:getPoints()}
end)
