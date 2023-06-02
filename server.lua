local curtime = 0.0
local nextupdate = 0.0
local TICK_RATE = 1 / 60.0
SERVER = true
CLIENT = false

entities = require("systems.server.entities")
require("systems.server.ping")
player_index = {} -- Maps peer:index() to player entity ids

hooks.add("load", function(args)
    love.window.close()
    network.listen();
    log.info("listening..")

    local min, max = -500, 500
    for i=1, 10 do
        physics.spawnCircle(0, love.math.random(min, max), love.math.random(min, max), love.math.random(10, 30))
    end

    for i=1, 5 do
        physics.spawnBox(0, love.math.random(min, max), love.math.random(min, max), love.math.random(20, 50))
    end
    
    -- generate world icons
    --  1<=x<= 6 : short grass
    --  7<=x<= 9 : long grass
    --     x =10 : flowers

    for i = -20, 20 do
        for k = -20, 20 do
            local newtile = {}
            newtile.position = {
                x = k * 16,
                y = i * 16
            }
            local n = math.random(1, 10)
            if n == 10 then
                newtile.type = "flowers"
            elseif n >= 7 and n <= 9 then
                newtile.type = "longgrass"
            else
                newtile.type = "shortgrass"
            end

            table.insert(tiles, newtile)
        end
    end
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
    player.move = {
        x  = 0,
        y  = 0
    }
    player.mouse = {
        x = 0,
        y = 0,
        lmb = false,
        rmb = false
    }
    player_index[peer:index()] = player_id

    local body = physics.new_body("dynamic")
    local shape = love.physics.newRectangleShape(15, 15)
    local fixture = love.physics.newFixture(body, shape, 5)
    -- Store the entity id in the body, so we can do collision stuff
    fixture:setUserData(id)
    player.body = body

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

        -- send server world tiles
        for k, tile in pairs(tiles) do
            peer:send({
                cmd = "update-tile",
                id = k,
                x = tile.position.x,
                y = tile.position.y,
                type = tile.type
            })
        end

        if entity.is_box and entity.body then
            local x, y = entity.body:getPosition()

            peer:send({
                cmd = "spawn-box",
                id = id,
                x = x,
                y = y,
                width = entity.width,
                height = entity.height
            })
        elseif entity.is_circle and entity.body then
            local x, y = entity.body:getPosition()

            peer:send({
                cmd = "spawn-circle",
                id = id,
                x = x,
                y = y,
                radius = entity.radius
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

messages.subscribe("player-move", function(peer, msg)
    local player_id = player_index[peer:index()]
    local player = entities.get(player_id)
    local x = tonumber(msg.x)
    local y = tonumber(msg.y)

    if player then
        player.move.x = x
        player.move.y = y
    else
        log.error("player-move called but no player!!")
        return
    end
end)

messages.subscribe("update-mouse", function(peer, msg)
    local player_id = player_index[peer:index()]
    local player = entities.get(player_id)
    local x = tonumber(msg.x)
    local y = tonumber(msg.y)
    local lmb = tonumber(msg.lmb)
    local rmb = tonumber(msg.rmb)

    if player then
        player.mouse.x = x
        player.mouse.y = y
        player.mouse.lmb = lmb
        player.mouse.rmb = rmb
    else
        log.error("update-mouse called but no player!!")
        return
    end
    
    -- relay mouse position to all connected players
    -- ideally we only broadcast new values to players
    -- instead of assuming the peer only sent us new values
    network.broadcast({
        cmd = "update-mouse",
        id = player_id,
        x = x,
        y = y,
        lmb = lmb,
        rmb = rmb
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

hooks.add("fixed_timestep", function(fixed_timestep)
    for id, player in entities.players() do
        if player.move then
            if player.move.x ~= 0 or player.move.y ~= 0 then
                local ms = 100000.0 * fixed_timestep
                local force_x = player.move.x * ms
                local force_y = player.move.y * ms

                player.body:applyForce(force_x, force_y)
            end
        end
    end
    
    -- Now send the world data to all players
    for id, ent in entities.all() do
        if ent.body then
            local x, y = ent.body:getPosition()
            local a = ent.body:getAngle()
            local vx, vy = ent.body:getLinearVelocity()
            local ax, ay = 0, 0

            if ent.player then
                ax = ent.player.move.x * 100000.0 * fixed_timestep
                ay = ent.player.move.y * 100000.0 * fixed_timestep
            end

            network.broadcast({
                cmd = "update-body",
                id = id,
                x = x,
                y = y,
                a = a,
                vx = vx,
                vy = vy,
                ax = ax,
                ay = ay
            })
        end
    end
end)

hooks.add("update", function(dt)
    curtime = curtime + dt
    if curtime < nextupdate then
        return
    end
    nextupdate = curtime + TICK_RATE

end)
