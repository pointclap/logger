local enet = require "enet"

local connection = {}
local connection_meta = {__index = connection}

function connection:events()
    local all_events = {}

    local event = self.client:service()
    while event do
        if event.type == "receive" then
            decoded_message = {}
            for k, v in event.data:gmatch("([^=]+)=([^;]+);") do
                decoded_message[k] = v
            end

            event.data = decoded_message
        end

        table.insert(all_events, event)
        event = self.client:service()
    end

    return all_events
end

function connection:send(data)
    local encoded = ""
    for k, v in pairs(data) do
        encoded = encoded .. k .. "=" .. v .. ";"
    end

    self.peer:send(encoded)
end

function connect(ip_address)
    local client = enet.host_create()
    local peer = client:connect(ip_address .. ":27031")

    return setmetatable({
        client = client,
        peer = peer,
    }, connection_meta)
end
