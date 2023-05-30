local connected_players = {}
local curtime = 0.0
local nextupdate = 0.0
local TICK_RATE = 1 / 60.0


local function next_entity_id()
    entid = entid + 1
    return entid
end

hooks.add("load", function(args)
    love.window.close()
    network.listen();
    print("listening..")
    -- create a box at 50,50
    physics.spawnBox(next_entity_id(), 50, 50, 20)
end)

local function generate_uniqueid(username)
    local newuniqueid = ""

    while true do
        local uniqueidused = 0
        newuniqueid = math.random(1, 9999)

        for id, ply in pairs(connected_players) do
            if ply.username == username and ply.uniqueid == newuniqueid then
                uniqueidused = 1
                break
            end
        end

        if uniqueidused == 0 then
            break
        end
    end

    return newuniqueid
end

hooks.add("uncaught-message", function(peer, msg)
    network.broadcast(msg)
end)

messages.subscribe("disconnect", function(peer, msg)
    if connected_players[peer:index()] ~= nil then
        network.broadcast({
            cmd = "player-left",
            username = connected_players[peer:index()].username,
            uniqueid = connected_players[peer:index()].uniqueid,
            id = peer:index()
        })

        connected_players[peer:index()] = nil
    end
end)

messages.subscribe("new-player", function(peer, msg)
    connected_players[peer:index()] = {
        username = msg.username,
        uniqueid = generate_uniqueid(msg.username),
    }

    print(msg.username .. "#" .. connected_players[peer:index()].uniqueid .. " joined")

    -- Tell the new player about all other players
    for id, ply in pairs(connected_players) do
        if id ~= peer:index() then
            peer:send({
                cmd = "new-player",
                username = ply.username,
                uniqueid = ply.uniqueid,
                id = id
            })
        end
    end

    -- Tell new player about all entities and their positions
    for ent_id, ent in pairs(entities) do
        if ent.body then
            peer:send({
                cmd = "spawn-box",
                ent_id = ent_id,
                pos_x = ent.body.x,
                pos_y = ent.body.y,
                size = 20 -- to do: send vert details to/from server 
            })
        end
    end

    -- Tell all players (including the player itself) about the new player
    network.broadcast({
        cmd = "new-player",
        username = connected_players[peer:index()].username,
        uniqueid = connected_players[peer:index()].uniqueid,
        id = peer:index()
    })
end)

messages.subscribe("player-left", function(peer, msg)
    network.broadcast({
        cmd = "player-left",
        username = connected_players[peer:index()].username,
        uniqueid = connected_players[peer:index()].uniqueid,
        id = peer:index()
    })
end)

hooks.add("update", function(dt)
    curtime = curtime + dt
    if curtime < nextupdate then return end
    nextupdate = curtime + TICK_RATE

    -- Now send the world data to all players
    for ent_id, ent in pairs(entities) do
        if ent.body then
            network.broadcast({
                cmd = "update-world",
                ent_id = ent_id,
                x = ent.body.x,
                y = ent.body.y
            })
        end
    end
end)

return {
    load = load,
}
