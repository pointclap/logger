localplayer = nil

local function hsl2rgb(h, s, l, a)
    if s == nil then
        s = 1
    end
    if l == nil then
        l = 0.5
    end
    if a == nil then
        a = 1
    end

    if s <= 0 then
        return {
            r = l,
            g = l,
            b = l,
            a = a
        }
    end
    h, s, v = h * 6, s, l
    local c = (1 - math.abs(2 * l - 1)) * s
    local x = (1 - math.abs(h % 2 - 1)) * c
    local m, r, g, b = (l - .5 * c), 0, 0, 0
    if h < 1 then
        r, g, b = c, x, 0
    elseif h < 2 then
        r, g, b = x, c, 0
    elseif h < 3 then
        r, g, b = 0, c, x
    elseif h < 4 then
        r, g, b = 0, x, c
    elseif h < 5 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    return {
        r = r + m,
        g = g + m,
        b = b + m,
        a = a
    }
end

hooks.add("connected", function(peer)
    log.info("connected to server!")
    network.broadcast({
        cmd = "new-player",
        username = username
    })
end)

messages.subscribe("assign-localplayer", function(peer, msg)
    id = tonumber(msg.id)
    log.debug("Assigning localplayer = " .. id)
    localplayer = id
end)

messages.subscribe("new-player", function(peer, msg)
    local id = tonumber(msg.id)

    log.info("New player " .. msg.username .. "#" .. msg.uniqueid .. " joined!")

    local player = entities.get(id)

    player.model = {
        x = 0,
        y = 0,
        radius = 10
    }

    local colour = hsl2rgb((id - 1) / 12)
    player.colour = colour
    player.mouseX = 0
    player.mouseY = 0
    player.username = msg.username
    player.uniqueid = tonumber(msg.uniqueid)

    player.interpolated_position = {
        x = 0,
        y = 0
    }

    local body = physics.new_body("dynamic")
    local shape = love.physics.newCircleShape(10)
    local fixture = love.physics.newFixture(body, shape, 5)
    -- Store the entity id in the body, so we can do collision stuff
    fixture:setUserData(id)
    player.body = body

    models.set_model(id, "character")
    labels.set_label(id, msg.username .. "#" .. msg.uniqueid)
end)

messages.subscribe("player-left", function(peer, msg)
    log.info("Player " .. msg.username .. "#" .. msg.uniqueid .. " left!")
end)

messages.subscribe("update-position", function(peer, msg)
    if tonumber(msg.id) ~= localplayer then
        local player_id = tonumber(msg.id)
        if players[player_id] and players[player_id].body then
            players[player_id].body:setPosition(tonumber(msg.x), tonumber(msg.y))
            players[player_id].body:setLinearVelocity(tonumber(msg.vx), tonumber(msg.vy))
            players[player_id].mouseX = tonumber(msg.mouseX)
            players[player_id].mouseY = tonumber(msg.mouseY)
        end
    end
end)

messages.subscribe("update-mouse", function(peer, msg)
    local player_id = tonumber(msg.id)
    if player_id ~= localplayer then
        local player = entities.get(player_id)
        player.mouseX = tonumber(msg.mouseX)
        player.mouseY = tonumber(msg.mouseY)
    end
end)

hooks.add("fixed_timestep", function(fixed_timestep)
    local player = entities.get(localplayer)
    if player then
        if love.window.hasMouseFocus() then
            local x, y = love.mouse.getPosition()
            player.mouseX = x
            player.mouseY = y

            local ms = 100000.0 * fixed_timestep
            local force_x = 0
            local force_y = 0

            if love.keyboard.isDown("d") then
                force_x = ms
            elseif love.keyboard.isDown("a") then
                force_x = -ms
            end

            if love.keyboard.isDown("s") then
                force_y = ms
            elseif love.keyboard.isDown("w") then
                force_y = -ms
            end

            player.body:applyForce(force_x, force_y)
        end
    end
end)

local countdown = 0
hooks.add("update", function(dt)
    countdown = countdown - dt
    if countdown < 0 then
        local player = entities.get(localplayer)
        if player then
            local x, y = player.body:getPosition()
            local vx, vy = player.body:getLinearVelocity()

            network.broadcast({
                cmd = "update-position",
                id = localplayer,
                x = x,
                y = y,
                vx = vx,
                vy = vy
            })

            network.broadcast({
                cmd = "update-mouse",
                id = localplayer,
                mouseX = player.mouseX,
                mouseY = player.mouseY
            })
        end
        countdown = 0.1
    end
end)

hooks.add("draw_local", function()
    local player = entities.get(localplayer)
    if not player then
        return
    end

    local x = player.interpolated_position.x
    local y = player.interpolated_position.y

    for id, player in entities.players() do
        love.graphics.setColor(player.colour.r, player.colour.g, player.colour.b)
        if player.mouseX and player.mouseY then
            local mouseX = player.mouseX
            local mouseY = player.mouseY

            if id ~= localplayer and player.interpolated_position then
                mouseX = mouseX + player.interpolated_position.x - x
                mouseY = mouseY + player.interpolated_position.y - y
            end

            love.graphics.circle("fill", mouseX, mouseY, 3)
        end
    end
end)
