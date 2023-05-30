hooks.add("uncaught-message", function(peer, msg)
    network.broadcast(msg)
end)

local debug = require("systems.client.debug")
models = require("systems.client.models")

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
    if localplayer and players[localplayer] then
        love.graphics.push()
        love.graphics.translate(-players[localplayer].interpolated_position.x + width / 2,
            -players[localplayer].interpolated_position.y + height / 2)
        hooks.call("draw_world")
        love.graphics.pop()
    end

    hooks.call("draw_local")
end)
