SERVER = false
CLIENT = true

SCRWIDTH, SCRHEIGHT = love.graphics.getDimensions()

hooks.add("uncaught-message", function(peer, msg)
    network.broadcast(msg)
end)

entities = require("systems.client.entities")

local debug = require("systems.client.debug")
cursors = require("assets.models.parts.cursor")
models = require("systems.client.models")
require("systems.client.pong")

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

    local player = entities.get(localplayer)
    if player and player.interpolated_position then
        love.graphics.push()
        love.graphics.translate(-player.interpolated_position.x + SCRWIDTH / 2,
            -player.interpolated_position.y + SCRHEIGHT / 2)
        hooks.call("draw_world")
        love.graphics.pop()
    end

    hooks.call("draw_local")
end)

messages.subscribe("spawn-box", function(peer, msg)
    local id = tonumber(msg.id)
    local x, y = tonumber(msg.x), tonumber(msg.y)
    local width = tonumber(msg.width)
    local height = tonumber(msg.height)

    physics.spawn_box(id, x, y, width, height)
end)

messages.subscribe("spawn-circle", function(peer, msg)
    local id = tonumber(msg.id)
    local x, y = tonumber(msg.x), tonumber(msg.y)
    local radius = tonumber(msg.radius)

    physics.spawn_circle(id, x, y, radius)
end)

messages.subscribe("update-tile", function(peer, msg)
    local id = tonumber(msg.id)
    local newtile = {}
    newtile.position = {
        x = tonumber(msg.x),
        y = tonumber(msg.y)
    }
    newtile.type = msg.type
    tiles[id] = newtile
end)