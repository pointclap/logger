local enet = require "enet"

-- "Connection" class used for sending
-- and receiving data from the server.
local connection = {}

-- Get all new events from the server
function connection:events()
    local all_events = {}

    local event = self.client:service()
    while event do
        if event.type == "receive" then
            -- Messages are encoded using a key1=value1;key2=value2;
            -- format. Decode the format into a flat table instead.
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

function connection:close()
    self.client:flush()
    self.client:destroy()
end

function connect(ip_address)
    local client = enet.host_create()
    local peer = client:connect(ip_address .. ":27031")

    return setmetatable({
        client = client,
        peer = peer,
    }, {__index = connection})
end