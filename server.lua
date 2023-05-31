local curtime = 0.0
local nextupdate = 0.0
local TICK_RATE = 1 / 60.0

entities = require("systems.server.entities")
require("systems.server.ping")
player_index = {} -- Maps peer:index() to player entity ids

local function spawnBox(pos_x, pos_y, width, height)
    local id, entity = entities.spawn()
    if width and not height then
        height = width
    elseif height and not width then 
        width = height
    elseif not width and not height then
        return
    end

    local body = physics.new_body("dynamic");
    local shape = love.physics.newPolygonShape(-width / 2, -height / 2, 
                                                width / 2, -height / 2,
                                                width / 2,  height / 2, 
                                               -width / 2,  height / 2)

    local fixture = love.physics.newFixture(body, shape, 5)
    fixture:setUserData(id)

    entity.is_box = true
    entity.interpolated_position = {
        x = pos_x,
        y = pos_y
    }
    entity.body = body
    entity.body:setPosition(pos_x, pos_y)
end

local function spawnCircle(pos_x, pos_y, radius)
    local id, entity = entities.spawn()
    local body = physics.new_body("static")
    local shape = love.physics.newCircleShape(radius)
    local fixture = love.physics.newFixture(body, shape, 5)
    fixture:setUserData(id)

    entity.is_circle = true
    entity.interpolated_position = {
        x = pos_x,
        y = pos_y
    }
    entity.radius = radius
    entity.body = body
    entity.body:setPosition(pos_x, pos_y)
end

hooks.add("load", function(args)
    love.window.close()
    network.listen();
    log.info("listening..")
    -- create a box at 50,50
    spawnBox(50, 50, 50, 20)

    for i=1, 10 do
        local min, max = -500, 500
        spawnCircle(love.math.random(min, max), love.math.random(min, max), love.math.random(10, 30))
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
        y = 0
    }
    player_index[peer:index()] = player_id

    local body = physics.new_body("dynamic")
    local shape = love.physics.newCircleShape(10)
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
            local size = 20 -- to do: send vert details to/from server 
            -- if the box is not square shaped then this fails compeltely
            -- not sure best way to send down variable amount of vertices
            -- so that client can accurately construct a body/prop
            peer:send({
                cmd = "spawn-box",
                id = id,
                pos_x = x,
                pos_y = y,
                size = size
            })
        elseif entity.is_circle and entity.body then
            local x, y = entity.body:getPosition()
            -- all of this is risky, we don't know for sure about fixtures of shape type
            -- make this more robust later
            local shape = entity.body:getFixtures()[1]:getShape()
            local radius = shape:getRadius()

            peer:send({
                cmd = "spawn-circle",
                id = id,
                pos_x = x,
                pos_y = y,
                radius = radius
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

    if player then
        player.mouse.x = x
        player.mouse.y = y
    else
        log.error("update-mouse called but no player!!")
        return
    end
    
    -- relay mouse position to all connected players
    network.broadcast({
        cmd = "update-mouse",
        id = player_id,
        x = x,
        y = y
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
