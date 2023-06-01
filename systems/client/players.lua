local character = require("assets.models.character")

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

    log.info("New player " .. msg.username .. " joined!")

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

    player.interpolated_position = {
        x = 0,
        y = 0
    }

    player.move = {
        x  = 0,
        y  = 0,
        dx = 0,
        dy = 0
    }

    player.mouse = {
        x  = 0,
        y  = 0,
        dx = 0,
        dy = 0,

        lmb  = 0,
        rmb  = 0,
        dlmb = 0,
        drmb = 0
    }

    local body = physics.new_body("dynamic")
    local shape = love.physics.newCircleShape(10)
    local fixture = love.physics.newFixture(body, shape, 5)
    -- Store the entity id in the body, so we can do collision stuff
    fixture:setUserData(id)
    player.body = body

    models.set_model(id, character)
    
    labels.set_label(id, msg.username)
end)

messages.subscribe("player-left", function(peer, msg)
    log.info("Player " .. msg.username .. " left!")
end)

messages.subscribe("update-mouse", function(peer, msg)
    local player_id = tonumber(msg.id)
    if player_id ~= localplayer then
        local player = entities.get(player_id)
        player.mouse.x = tonumber(msg.x)
        player.mouse.y = tonumber(msg.y)
        player.mouse.lmb = tonumber(msg.lmb)
        player.mouse.rmb = tonumber(msg.rmb)
    end
end)

hooks.add("fixed_timestep", function(fixed_timestep)
    local player = entities.get(localplayer)
    if player and player.move then
        if love.window.hasFocus() then
            player.move.dx = player.move.x
            player.move.dy = player.move.y

            local x, y = 0, 0
            if love.keyboard.isDown("d") then
                x = x + 1
            end

            if love.keyboard.isDown("a") then
                x = x - 1
            end
        
            if love.keyboard.isDown("s") then
                y = y + 1
            end

            if love.keyboard.isDown("w") then
                y = y - 1
            end

            player.move.x = x
            player.move.y = y
            
            if player.move.x ~= player.move.dx or player.move.y ~= player.move.dy then
                network.broadcast({
                    cmd = "player-move",
                    x = player.move.x,
                    y = player.move.y
                })
            end

            player.mouse.dx = player.mouse.x
            player.mouse.dy = player.mouse.y
            player.mouse.dlmb = player.mouse.lmb
            player.mouse.drmb = player.mouse.drmb

            player.mouse.x, player.mouse.y = love.mouse:getPosition()
            
            if love.mouse.isDown(1) then
                player.mouse.lmb = 1
            else
                player.mouse.lmb = 0
            end

            if love.mouse.isDown(2) then
                player.mouse.rmb = 1
            else
                player.mouse.rmb = 0
            end
            
            if player.mouse.x   ~= player.mouse.dx   or player.mouse.y   ~= player.mouse.dy or
               player.mouse.lmb ~= player.mouse.dlmb or player.mouse.rmb ~= player.mouse.drmb then
                network.broadcast({
                    cmd = "update-mouse",
                    x = player.mouse.x,
                    y = player.mouse.y,
                    lmb = player.mouse.lmb,
                    rmb = player.mouse.rmb
                })
            end
        end
    end
end)

local countdown = 0
hooks.add("update", function(dt)
    countdown = countdown - dt
    if countdown < 0 then
        local player = entities.get(localplayer)
        if player and player.body then
            local x, y = player.body:getPosition()
            local vx, vy = player.body:getLinearVelocity()
        end
        countdown = 0.1
    end
    
    if love.mouse.isDown(1) then
        love.mouse.setCursor(cursors.point.cursor)
    elseif love.mouse.isDown(2) then
        love.mouse.setCursor(cursors.closed.cursor)
    else
        love.mouse.setCursor(cursors.open.cursor)
    end
end)

hooks.add("draw_local", function()
    local player = entities.get(localplayer)
    if not player or not player.interpolated_position then
        return
    end

    local x = player.interpolated_position.x
    local y = player.interpolated_position.y

    for id, player in entities.players() do
        love.graphics.setColor(player.colour.r, player.colour.g, player.colour.b)
        if player.mouse then
            local mouseX = player.mouse.x
            local mouseY = player.mouse.y

            if id ~= localplayer and player.interpolated_position then
                mouseX = mouseX + player.interpolated_position.x - x
                mouseY = mouseY + player.interpolated_position.y - y
                    
                -- offset the quad so the index finger lines up with actual cursor point
                mouseX = mouseX - 15
                mouseY = mouseY - 0

                --love.graphics.circle("fill", mouseX, mouseY, 3)
                if player.mouse.lmb == 1 then
                    love.graphics.draw(cursors.point.image,  cursors.point.quad,   mouseX, mouseY)
                elseif player.mouse.rmb == 1 then
                    love.graphics.draw(cursors.closed.image, cursors.closed.quad, mouseX, mouseY)
                else
                    love.graphics.draw(cursors.open.image,   cursors.open.quad,   mouseX, mouseY)
                end
            end
        end
    end
end)
