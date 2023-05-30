hooks = require("hooks")
messages = require("messages")
network = require("network")
local server = require("server")
local client = require("client")
local is_server = false

function love.load(args)
    if not args[1] then
        is_server = true
        server.load(args)
        love.window.close()
        -- client.load({
        --     "localhost",
        --     "local-user"
        -- })
    else
        client.load(args)
    end
end

function love.update(dt)
    if is_server then
        server.update(dt)
    else
        client.update(dt)
    end    
end

function love.draw()
    if is_server then
        -- list players + other stats
    else
        client.draw()
    end

end

function love.quit()
    if not is_server then
        client.quit()
    end
end

function love.keyreleased(key, scancode, isrepeat)
	client.keyreleased(key, scancode, isrepeat)
end
