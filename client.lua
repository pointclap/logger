local debug = require("systems.client.debug")
local physics = require("systems.physics")
models = require("systems.client.models")

local accumulated_deltatime = 0
local fixed_timestep = 0.008

require("systems.client.grass")
require("systems.players")

players = {}
username = nil
tick_rate = 1 / 10

local function load(args)
    username = args[2]
    network.connect(args[1]);

    hooks.call("load", args)

    love.graphics.setDefaultFilter("nearest", "nearest", 0)
end

local function update(dt)
    hooks.call("update", dt)

    accumulated_deltatime = accumulated_deltatime + dt
    while accumulated_deltatime > fixed_timestep do
        hooks.call("fixed_timestep", fixed_timestep)
        accumulated_deltatime = accumulated_deltatime - fixed_timestep
    end
end

local function quit()
    network.broadcast({
        cmd = "player-left"
    })
end

local function draw()
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
end

local function keyreleased(key, scancode, isrepeat)
    hooks.call("keyreleased", key, scancode, isrepeat)
end

return {
    draw = draw,
    load = load,
    update = update,
    quit = quit,
    keyreleased = keyreleased
}
