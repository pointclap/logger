localplayer = nil

local font = love.graphics.newFont(9, "mono")
font:setFilter("nearest")
love.graphics.setFont(font)

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

subscribe_message("new-player", function(msg)
    local id = tonumber(msg.id)
    if msg.username == username and localplayer == nil then
        print("localplayer not set, assigning " .. msg.id)
        localplayer = id
    else
        print("New player " .. msg.username .. "#" .. msg.uniqueid .. " joined!")
    end

    if players[id] == nil then
        players[id] = {}
    end

    players[id].model = {
        x = 0,
        y = 0,
        radius = 10
    }

    local colour = hsl2rgb((id - 1) / 12)
    players[id].colour = colour
    players[id].mouseX = 0
    players[id].mouseY = 0
    players[id].username = msg.username
    players[id].uniqueid = tonumber(msg.uniqueid)
    players[id].username_text = msg.username .. "#" .. msg.uniqueid
    players[id].drawable_text = love.graphics.newText(font, {{colour.r, colour.g, colour.b},
                                                             msg.username .. "#" .. msg.uniqueid})
    players[id].contact_sound = love.audio.newSource("assets/audio/toot.wav", "static")

    set_model(id, "character")
end)

subscribe_message("player-left", function(msg)
    players[tonumber(msg.id)] = nil
    print("Player " .. msg.username .. "#" .. msg.uniqueid .. " left!")
end)

subscribe_message("update-position", function(msg)
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

subscribe_message("update-mouse", function(msg)
    if tonumber(msg.id) ~= localplayer then
        local player_id = tonumber(msg.id)
        players[player_id].mouseX = tonumber(msg.mouseX)
        players[player_id].mouseY = tonumber(msg.mouseY)
    end
end)

function player_movement(dt)
    if localplayer then
        if love.window.hasMouseFocus() then
            local x, y = love.mouse.getPosition()
            players[localplayer].mouseX = x
            players[localplayer].mouseY = y

            local ms = 100000.0 * dt
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

            players[localplayer].body:applyForce(force_x, force_y)
        end
    end
end

function send_updated_position(dt)
    if localplayer then
        local x, y = players[localplayer].body:getPosition()
        local vx, vy = players[localplayer].body:getLinearVelocity()

        connection:send({
            cmd = "update-position",
            id = localplayer,
            x = x,
            y = y,
            vx = vx,
            vy = vy
        })

        connection:send({
            cmd = "update-mouse",
            id = localplayer,
            mouseX = players[localplayer].mouseX,
            mouseY = players[localplayer].mouseY
        })
    end
end

function render_username(player)
    love.graphics.setColor(player.colour.r, player.colour.g, player.colour.b)

    if player.interpolated_position and player.username and player.uniqueid then
        love.graphics.push()
        -- love.graphics.scale(fontSize)
        player.drawable_text:set(player.username_text)
        local w, h = player.drawable_text:getDimensions()
        love.graphics.draw(player.drawable_text, player.interpolated_position.x - w / 2, player.interpolated_position.y - 30)
        player.drawable_text:set("int x: " .. player.interpolated_position.x)
        love.graphics.draw(player.drawable_text, player.interpolated_position.x - w / 2, player.interpolated_position.y + 30)
        player.drawable_text:set("int y: " .. player.interpolated_position.y)
        love.graphics.draw(player.drawable_text, player.interpolated_position.x - w / 2, player.interpolated_position.y + 40)
        love.graphics.pop()
    end
end

function local_render()
    -- render all other plays first..
    for id, player in pairs(players) do
        if id ~= localplayer then
            render_username(player)
        end
    end

    if localplayer then
        render_username(players[localplayer])
    end
end

function render_cursors()
    if not players[localplayer] then return end

    local x = players[localplayer].interpolated_position.x
    local y = players[localplayer].interpolated_position.y

    for id, player in pairs(players) do
        love.graphics.setColor(player.colour.r, player.colour.g, player.colour.b)    
        if player.mouseX and player.mouseY then
            local mouseX = player.mouseX
            local mouseY = player.mouseY

            if id ~= localplayer and player.interpolated_position then
                mouseX = mouseX + player.interpolated_position.x - x
                mouseY = mouseY + player.interpolated_position.y - y
            end
            
            love.graphics.circle("fill", mouseX, mouseY, 3)

            player.drawable_text:set("mouseX: " .. player.mouseX)
            love.graphics.draw(player.drawable_text, mouseX, mouseY + 10)
            player.drawable_text:set("mouseY: " .. player.mouseY)
            love.graphics.draw(player.drawable_text, mouseX, mouseY + 20)
        end
    end
end
