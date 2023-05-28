local debug = require("systems.debug")
messages = require("messages")

local network = require("network")
local physics = require("systems.physics")
local models = require("systems.models")

require("systems.players")

players = {}
username = nil
connection = nil
tick_rate = 1 / 10
cur_time = 0
next_update = 0
 
local function load(args)
	username = args[2]
	connection = network.connect(args[1]);

	physics.load()
end

local delta_time = 0
local function update(dt)
	delta_time = dt
	cur_time = cur_time + dt

	if connection then
		for _, event in pairs(connection:events()) do
			if event.type == "receive" then
				messages.incoming(event.data)
	
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
	
	physics.update(dt)
	models.update(dt)

	if cur_time > next_update then
		next_update = cur_time + tick_rate
		send_updated_position(dt)
	end

	debug.update(dt)
end

local function quit()
	connection:send({
		cmd = "player-left"
	})
	connection:close()
end

local function draw()
	local width, height = love.graphics.getDimensions()
	love.graphics.push()
		if localplayer and players[localplayer] then
			love.graphics.translate(-players[localplayer].interpolated_position.x + width / 2, -players[localplayer].interpolated_position.y + height / 2)
		end

		models.draw()
		local_render()
		debug.draw_local()
	love.graphics.pop()

	render_cursors()
	debug.draw_global()
end

local function keyreleased(key, scancode, isrepeat)
	debug.keyreleased(key, scancode, isrepeat)
end

return {
	draw = draw,
	load = load,
	update = update,
	quit = quit,
	keyreleased = keyreleased
}
