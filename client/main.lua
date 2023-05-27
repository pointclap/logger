require("client.network")
require("client.messages")
require("client.systems.players")

players = {}
username = nil
connection = nil

next_update = 0.1
cur_time = 0.0

local font = love.graphics.newFont(7, "mono")
font:setFilter("nearest")
love.graphics.setFont(font)
 
function love.load(args)
	username = args[2]
	connection = connect(args[1]);
end

function love.update(dt)
	cur_time = cur_time + dt
	-- Update current player location to mouse position
	if localplayer and cur_time > next_update then
		next_update = cur_time + (1.0 / 128)

		--local x, y = love.mouse.getPosition()
		local x = players[localplayer].x
		local y = players[localplayer].y
 
        local mouseX = players[localplayer].mouseX
        local mouseY = players[localplayer].mouseY

		if love.window.hasMouseFocus() then
			local mouseX, mouseY = love.mouse.getPosition()
			local ms = 1000.0 * dt

			if love.keyboard.isDown("d") then
				x = x + ms
			elseif love.keyboard.isDown("a") then
				x = x - ms
			end
 
			if love.keyboard.isDown("s") then
				y = y + ms
			elseif love.keyboard.isDown("w") then
				y = y - ms
			end
		end
 
		if players[localplayer].x ~= x or players[localplayer].y ~= y then
			connection:send({
				cmd = "update-position",
				id = localplayer,
				x = x,
				y = y,
			})
 
			players[localplayer].x = x
			players[localplayer].y = y
		end
		
        if players[localplayer].mouseX ~= mouseX or players[localplayer].mouseY ~= mouseY then
            connection:send({
                cmd = "update-mouse",
                id = localplayer,
                mouseX = mouseX,
                mouseY = mouseY
            })

            players[localplayer].mouseX = mouseX
            players[localplayer].mouseY = mouseY
        end
	end
 
	if connection then
		for _, event in pairs(connection:events()) do
			if event.type == "receive" then
				incoming_message(event.data)
	
			elseif event.type == "connect" then
				print("connected to server")
				connection:send({
					cmd = "new-player",
					username = username
				})
	
			elseif event.type == "disconnected" then
				print("disconnected")
			end
		end
	end
end

function love.quit()
	connection:send({
		cmd = "player-left",
		id = localplayer,
		username = username
	})
	connection:close()
end

function love.draw()
	local color_index = 1
	local width, height = love.graphics.getDimensions()

	if localplayer then
		love.graphics.translate(-players[localplayer].x + width / 2, -players[localplayer].y + height / 2)
	end
 
	for id, player in pairs(players) do
		local colour = hsl2rgb(id/12)
		
		love.graphics.setColor(
			colour.r,
			colour.g,
			colour.b
		)

		love.graphics.circle("fill", player.x, player.y, 10)

		if player.username then
			local text = love.graphics.newText(font, {colour, player.username})
			love.graphics.scale(2)
			local textWidth, textHeight = text:getDimensions()
			love.graphics.draw(text, player.x - textWidth / 2, player.y - 10 - textHeight / 2)
			love.graphics.scale(0.5)
		end

		color_index = color_index + 1
	end
end

-- Converts HSL to RGB. (input and output range: 0 - 1)
function hsl2rgb(h, s, l, a)
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