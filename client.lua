require("network")
require("messages")
require("systems.players")
require("systems.physics")
require("systems.debug")

players = {}
username = nil
connection = nil
tick_rate = 1 / 10
cur_time = 0
next_update = 0
 
local function load(args)
	username = args[2]
	connection = connect(args[1]);

	init_physics()
end

local delta_time = 0
local function update(dt)
	delta_time = dt
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

	update_physics(dt)
	interpolate_player_location(dt)

	if cur_time > next_update then
		next_update = cur_time + tick_rate
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
	render()
	print_debug_information(delta_time)
end

return {
	draw = draw,
	load = load,
	update = update,
	quit = quit
}
