local entities = {}
local last_entity_id = 0
local entities = require("systems.entities")

local function spawn()
    last_entity_id = last_entity_id + 1
    entities.entities[last_entity_id] = {}

    network.broadcast({
        cmd = "entity-spawned",
        id = last_entity_id
    })

    return last_entity_id, entities.entities[last_entity_id]
end

local function delete(id)
    -- next(table) returns nil if the table is empty
    if next(entities.entities[id]) then
        entities.entities[id] = {}

        network.broadcast({
            cmd = "entity-deleted",
            id = id
        })
    end
end

return {
    get = entities.get,
    all = entities.all,
    players = entities.players,
    dump = entities.dump,
    delete = delete,
    spawn = spawn
}
