localplayer = nil
local width, height = love.graphics.getDimensions()

local font = love.graphics.newFont(7, "mono")
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
    players[id].username_text = love.graphics.newText(font, {{colour.r, colour.g, colour.b},
                                                                           msg.username .. "#" .. msg.uniqueid})
end)

subscribe_message("player-left", function(msg)
    players[tonumber(msg.id)] = nil
    print("Player " .. msg.username .. "#" .. msg.uniqueid .. " left!")
end)

subscribe_message("update-position", function(msg)
    if tonumber(msg.id) ~= localplayer then
        local player_id = tonumber(msg.id)
        if players[player_id] and players[player_id].position then
            players[player_id].position.x = tonumber(msg.x)
            players[player_id].position.y = tonumber(msg.y)
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

function interpolate_player_location(dt)
    for _, player in pairs(players) do
        if player.body and player.model then
            local x, y = player.body:getPosition()

            local x_distance = x - player.model.x
            local y_distance = y - player.model.y

            player.model.x = player.model.x + x_distance * dt
            player.model.y = player.model.y + y_distance * dt
        end
    end
end

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
        connection:send({
            cmd = "update-position",
            id = localplayer,
            x = players[localplayer].position.x,
            y = players[localplayer].position.y,
            mouseX = players[localplayer].mouseX,
            mouseY = players[localplayer].mouseY
        })
    end
end

local function render_player(player)
    love.graphics.setColor(player.colour.r, player.colour.g, player.colour.b)

    if player.model then
        love.graphics.circle("fill", player.model.x, player.model.y, player.model.radius)
        if player.mouseX and player.mouseY then
            love.graphics.push()
            love.graphics.translate(players[localplayer].model.x - width / 2, players[localplayer].model.y - height / 2)
            love.graphics.circle("fill", player.mouseX, player.mouseY, 3)
            love.graphics.pop()
        end

        if player.username and player.uniqueid then
            local fontSize = 2

            love.graphics.push()
            love.graphics.scale(fontSize)
            local textWidth, textHeight = player.username_text:getDimensions()
            love.graphics.draw(player.username_text, player.model.x / fontSize - (textWidth / 2),
                ((player.model.y - 20) / fontSize) - (textHeight / 2))
            love.graphics.pop()
        end
    end
end

function render()
    love.graphics.push()

    if localplayer and players[localplayer] then
		love.graphics.translate(-players[localplayer].model.x + width / 2, -players[localplayer].model.y + height / 2)
	end

    -- render all other plays first..
    for id, player in pairs(players) do
        if id ~= localplayer then
            render_player(player)
        end
    end

    -- ..then local player on top
    for id, player in pairs(players) do
        if id == localplayer then
            render_player(player)
        end
    end
	
    love.graphics.pop()
end
