require("client.network")
require("client.messages")
require("client.systems.players")
require("client.systems.physics")

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

	init_physics()
end

function love.update(dt)
	cur_time = cur_time + dt
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

	player_movement(dt)
	apply_drag(dt)
	update_physics(dt)
	interpolate_player_location(dt)
	send_updated_position()
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
	local width, height = love.graphics.getDimensions()

	if localplayer then
		love.graphics.translate(-players[localplayer].model.x + width / 2, -players[localplayer].model.y + height / 2)
	end
 
	render_player_model()
end
