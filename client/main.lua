require("client.network")
require("client.messages")
require("client.systems.players")

players = {}
username = nil
connection = nil

function love.load(args) 
	username = args[2]
	connection = connect(args[1]);
end

next_update = 1.0
cur_time = 0.0
function love.update(dt)
	cur_time = cur_time + dt
	-- Update current player location to mouse position
	if localplayer and cur_time > next_update then
		next_update = cur_time + 0.01
		--local x, y = love.mouse.getPosition()
		local x = players[localplayer].x
		local y = players[localplayer].y
 
		if love.window.hasMouseFocus() then
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
	end
 
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

function love.draw()
	local color_index = 1
	local width, height = love.graphics.getDimensions()

	if localplayer then
		love.graphics.translate(-players[localplayer].x + width / 2, -players[localplayer].y + height / 2)
	end
 
	for id, player in pairs(players) do
		local colour = hsv2rgb(30 * (id - 1), 100, 100)
		love.graphics.setColor(
			colour.r,
			colour.g,
			colour.b
		)

		love.graphics.circle("fill", player.x, player.y, 10)
		color_index = color_index + 1
	end
end
