localplayer = nil

local font = love.graphics.newFont(7, "mono")
font:setFilter("nearest")
love.graphics.setFont(font)

local function hsl2rgb(h, s, l, a)
	if s == nil then s = 1 end
	if l == nil then l = 0.5 end
	if a == nil then a = 1 end

	if s<=0 then return {r=l,g=l,b=l,a=a} end
	h, s, v = h*6, s, l
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end return {r=r+m, g=g+m, b=b+m, a=a}
end

subscribe_message("new-player", function(msg)
    if msg.username == username and localplayer == nil then
        print("localplayer not set, assigning " .. msg.id)
        localplayer = tonumber(msg.id)
    else
        print("New player " .. msg.username .. "#" .. msg.uniqueid .. " joined!")
    end

    if players[tonumber(msg.id)] == nil then
        players[tonumber(msg.id)] = {}
    end

    players[tonumber(msg.id)].model = {
        x = 0,
        y = 0,
        radius = 10
    }

    players[tonumber(msg.id)].username = msg.username
    players[tonumber(msg.id)].uniqueid = tonumber(msg.uniqueid)
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

            player.model.x = player.model.x + (x - player.model.x) * dt * 100.0
            player.model.y = player.model.y + (y - player.model.y) * dt * 100.0
        end
    end
end


function player_movement(dt)
    if localplayer then 
		if love.window.hasMouseFocus() then
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

local cur_time = 0
local next_update = nil
function send_updated_position(dt)
    cur_time = cur_time + dt
    if next_update == nil then
        next_update = cur_time
    end

    if localplayer and cur_time > next_update then
        next_update = cur_time + 0.016
        connection:send({
            cmd = "update-position",
            id = localplayer,
            x = players[localplayer].position.x,
            y = players[localplayer].position.y,
        })
    end
end

function render_player_model()
    local color_index = 1

    for id, player in pairs(players) do
		local colour = hsl2rgb((id-1)/12)
		
		love.graphics.setColor(colour.r, colour.g, colour.b, colour.a)

        if player.model then
            love.graphics.circle("fill", player.model.x, player.model.y, player.model.radius)
        end

        -- if player.username then
        --     local text = love.graphics.newText(font, {colour, player.username})
        --     love.graphics.scale(2)
        --     local textWidth, textHeight = text:getDimensions()
        --     love.graphics.draw(text, player.model.x - textWidth / 2, player.model.y - 10 - textHeight / 2)
        --     love.graphics.scale(0.5)
        -- end

        color_index = color_index + 1
	end
end
