log = require("log")
hooks = require("hooks")
messages = require("messages")
network = require("network")
physics = require("systems.physics")
util = require("util")
world = nil

function love.load(args)
    if not args[1] then
        log.debug("starting server")
        require("server")
    else
        log.debug("starting client")
        require("client")
    end

    world = require("systems.world")

    hooks.call("load", args)
end

local accumulated_deltatime = 0
local fixed_timestep = 0.008
function love.update(dt)
    hooks.call("update", dt)

    accumulated_deltatime = accumulated_deltatime + dt
    while accumulated_deltatime > fixed_timestep do
        hooks.call("fixed_timestep", fixed_timestep)
        accumulated_deltatime = accumulated_deltatime - fixed_timestep
    end   
end

function love.draw()
    hooks.call("draw")
end

function love.quit()
    hooks.call("quit")
end

function love.keyreleased(...)
    hooks.call("keyreleased", ...)
end

function love.resize(...)
    hooks.call("resize", ...)
end

hooks.add("uncaught-message", function(peer, msg)
    log.warn("uncaught message from " .. peer:index() .. ":", messages.encode(msg))
end)
