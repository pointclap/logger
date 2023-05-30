local enet = require "enet"

local wrapped_peer = {}
function wrapped_peer:send(data)
    return self.peer:send(messages.encode(data))
end

function wrapped_peer:index()
    return self.peer:index()
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
            -- Wrap the peer so we can do custom encoding on the transmitted data.
            local peer = setmetatable({
                peer = event.peer
            }, {
                __index = wrapped_peer
            })

            if event.type == "receive" then
                log.debug("received message: ", event.data)
                local encoded_message = messages.decode(event.data);
                -- Submit message to subscribers, calling the 'uncaught-message'
                -- hook if nobody is subscribed to the message.
                if messages.incoming(peer, encoded_message) == 0 then
                    hooks.call("uncaught-message", peer, encoded_message)
                end

            elseif event.type == "connect" then
                hooks.call("connected", peer)

            elseif event.type == "disconnect" then
                hooks.call("disconnected", peer)
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
