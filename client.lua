hooks = require("systems.hooks")
messages = require("messages")
local debug = require("systems.debug")
local network = require("network")
local physics = require("systems.physics")
models = require("systems.models")

local accumulated_deltatime = 0
local fixed_timestep = 0.008

require("systems.players")

players = {}
username = nil
connection = nil
tick_rate = 1 / 10
 
local function load(args)
	username = args[2]
	connection = network.connect(args[1]);

	hooks.call("load", args)
end

local function update(dt)
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
	
	hooks.call("update", dt)

	accumulated_deltatime = accumulated_deltatime + dt
	while accumulated_deltatime > fixed_timestep do
		hooks.call("fixed_timestep", fixed_timestep)
		accumulated_deltatime = accumulated_deltatime - fixed_timestep
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
			love.graphics.push()
			love.graphics.translate(-players[localplayer].interpolated_position.x + width / 2, -players[localplayer].interpolated_position.y + height / 2)
			hooks.call("draw_world")
			love.graphics.pop()
		end

	hooks.call("draw_local")
end

local function keyreleased(key, scancode, isrepeat)
	hooks.call("keyreleased", key, scancode, isrepeat)
end

return {
	draw = draw,
	load = load,
	update = update,
	quit = quit,
	keyreleased = keyreleased
}
