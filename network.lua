local enet = require "enet"

local wrapped_peer = {}
function wrapped_peer:send(data)
    self.peer:send(messages.encode(data))
end

local host = nil

local function broadcast(data)
    if host then
        host:broadcast(messages.encode(data))
    end
end

local function connect(ip_address)
    -- assign global host
    host = enet.host_create()
    host:connect(ip_address .. ":27031")
end

local function listen()
    host = enet.host_create("*:27031")
end

hooks.add("update", function(dt)
    if host then
        local event = host:service()
        while event do
            if event.type == "receive" then
                -- Wrap the peer so we can do custom encoding on the transmitted data.
                local peer = setmetatable({
                    peer = event.peer
                }, {
                    __index = wrapped_peer
                })

                messages.incoming(peer, messages.decode(event.data))
            elseif event.type == "connect" then
                print("connected to server")
                broadcast({
                    cmd = "new-player",
                    username = username
                })
            elseif event.type == "disconnected" then
                print("disconnected")
            end
            event = host:service()
        end
    end
end)

return {
    connect = connect,
    listen = listen,
    broadcast = broadcast
}
