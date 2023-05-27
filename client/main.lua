require("client.network")
require("client.messages")
require("client.systems.players")

players = {}
username = nil
connection = nil

event_handlers = {}

next_update = 1.0
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
		local colour = hsv2rgb(30 * (id - 1), 100, 100)
		local smallColour = {
			colour.r / 255.0,
			colour.g / 255.0,
			colour.b / 255.0
		}

		love.graphics.setColor(
			colour.r,
			colour.g,
			colour.b
		)

		love.graphics.circle("fill", player.x, player.y, 10)

		if player.username then
			local text = love.graphics.newText(font, {smallColour, player.username})
			love.graphics.scale(2)
			local textWidth, textHeight = text:getDimensions()
			love.graphics.draw(text, player.x - textWidth / 2, player.y - 10 - textHeight / 2)
			love.graphics.scale(0.5)
		end

		color_index = color_index + 1
	end
end

function hsv2rgb(a, b, c)
	return {r=a, g=b, b=c}
end