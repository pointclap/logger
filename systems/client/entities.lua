local entities = require("systems.entities")

messages.subscribe("entity-spawned", function(peer, msg)
    local id = tonumber(msg.id)
    log.trace("new entity spawned: " .. id)
    entities.entities[id] = {
        exists = true
    }

    entities.dump()
end)

messages.subscribe("entity-deleted", function(peer, msg)
    local id = tonumber(msg.id)

    if next(entities.entities[id]) then
        entities.entities[id] = nil
    end
end)

return {
    spawn = spawn,
    get = entities.get,
    all = entities.all,
    players = entities.players,
    dump = entities.dump
}
