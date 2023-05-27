local server = require("server")
local client = require("client")
local is_server = false

function love.load(args)
    if not args[1] then
        is_server = true
        server.load(args)
        client.load({
            "localhost",
            "local-user"
        })
    else
        client.load(args)
    end
end

function love.update(dt)
    if is_server then
        server.update(dt)
    end

    client.update(dt)
end

function love.draw()
    client.draw()
end

function love.quit()
    client.quit()
end