require("network")
require("messages")
require("systems.players")
require("systems.physics")

players = {}
username = nil
connection = nil
tick_rate = 1 / 64
cur_time = 0
next_update = 0
 
local function load(args)
	username = args[2]
	connection = connect(args[1]);

	init_physics()
end

local function update(dt)
	cur_time = cur_time + dat

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

	if cur_time > next_update then
		next_update = curtime + tick_rate
		send_updated_position(dt)
	end
end

local function quit()
	connection:send({
		cmd = "player-left"
	})
	connection:close()
end

local function draw()
	local width, height = love.graphics.getDimensions()

	if localplayer and players[localplayer] then
		love.graphics.translate(-players[localplayer].model.x + width / 2, -players[localplayer].model.y + height / 2)
	end
 
	render_player_model()
end

return {
	draw = draw,
	load = load,
	update = update,
	quit = quit
}