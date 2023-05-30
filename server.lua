local curtime = 0.0
local nextupdate = 0.0
local TICK_RATE = 1 / 60.0

entities = require("systems.server.entities")
player_index = {} -- Maps peer:index() to player entity ids

local function spawnBox(pos_x, pos_y, size)
    local id, entity = entities.spawn()

    local body = physics.new_body("dynamic");
    local shape = love.physics.newPolygonShape(-size / 2, -size / 2, size / 2, -size / 2, size / 2, size / 2, -size / 2,
        size / 2)

    local fixture = love.physics.newFixture(body, shape, 5)
    fixture:setUserData(id)

    entity.is_box = true
    entity.interpolated_position = {
        x = pos_x,
        y = pos_y
    }
    entity.body = body
end

hooks.add("load", function(args)
    love.window.close()
    network.listen();
    log.info("listening..")
    -- create a box at 50,50
    spawnBox(50, 50, 20)
end)

hooks.add("uncaught-message", function(peer, msg)
    network.broadcast(msg)
end)

messages.subscribe("disconnect", function(peer, msg)
    for id, player in entities.players() do
        if player.peer:index() == peer:index() then
            network.broadcast({
                cmd = "player-left",
                username = player.username,
                id = id
            })

            entities.delete(id)
            return
        end
    end
end)

messages.subscribe("new-player", function(peer, msg)
    player_id, player = entities.spawn()
    player.username = msg.username
    player.peer = peer
    player_index[peer:index()] = player_id

    log.info(msg.username .. "(€" .. player_id .. ") joined")

    peer:send({
        cmd = "assign-localplayer",
        id = player_id
    })

    -- Tell new player about all entities and their positions
    for id, entity in entities.all() do
        peer:send({
            cmd = "entity-spawned",
            id = id
        });

        if entity.is_box and entity.body then
            local x, y = entity.body:getPosition()
            local size = 20

            peer:send({
                cmd = "spawn-box",
                id = id,
                pos_x = x,
                pos_y = y,
                size = size -- to do: send vert details to/from server 
            })
        end
    end

    -- Tell the new player about all other players
    for id, existing_player in entities.players() do
        if existing_player.peer:index() ~= peer:index() then
            peer:send({
                cmd = "new-player",
                username = existing_player.username,
                id = id
            })
        end
    end

    -- Tell all players (including the player itself) about the new player
    network.broadcast({
        cmd = "new-player",
        username = player.username,
        id = player_id
    })
end)

messages.subscribe("report-player-position", function(peer, msg)
    -- So right now all the players communicate to the server
    -- their position and velocity, but the server doesn't
    -- have any serverside physics body for the player, so
    -- no collision detection/resolution is done 
    -- TO DO: put players' bodies into entities and run world
    -- updates on those bodies, then send back the updated 
    -- positions and velocities to clients

    -- Remember: server is always authoritative when it comes
    -- to physics simulation. Client can do its own thing as
    -- a means of interpolation but when the server tells the
    -- client where things really are they should be put in place

    local entity = entities.get(tonumber(msg.id))
    if entity and entity.body then
        entity.body:setPosition(tonumber(msg.x), tonumber(msg.y))
        entity.body:setLinearVelocity(tonumber(msg.vx), tonumber(msg.vy))
    end

    network.broadcast({
        cmd = "update-body",
        id = msg.id,
        x = msg.x,
        y = msg.y,
        vx = msg.vx,
        vy = msg.vy
    })
end)

messages.subscribe("update-mouse", function(peer, msg)
    network.broadcast({
        cmd = msg.cmd,
        id = msg.id,
        mouseX = msg.mouseX,
        mouseY = msg.mouseY
    })
end)

messages.subscribe("player-left", function(peer, msg)
    local player_id = player_index[peer:index()]
    local player = entities.get(player_id)

    entities.delete(player_id)
    player_index[peer:index()] = nil

    network.broadcast({
        cmd = "player-left",
        username = player.username,
        id = player_id
    })
end)

hooks.add("update", function(dt)
    curtime = curtime + dt
    if curtime < nextupdate then
        return
    end
    nextupdate = curtime + TICK_RATE

    -- Now send the world data to all players
    for id, ent in entities.all() do
        if ent.body then
            local x, y = ent.body:getPosition()
            local vx, vy = ent.body:getLinearVelocity()

            network.broadcast({
                cmd = "update-body",
                id = id,
                x = x,
                y = y,
                vx = vx,
                vy = vy
            })
        end
    end
end)
