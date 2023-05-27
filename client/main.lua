require("client.network")

connection = nil
username = nil
 
localplayer = nil
players = {}

event_handlers = {}
 
function register_handler(name, func)
	if event_handlers[name] == nil then
		event_handlers[name] = {}
	end
 
	table.insert(event_handlers[name], func)
end

function incoming_message(msg)
	if msg["cmd"] and event_handlers[msg["cmd"]] then
		for _, handler in pairs(event_handlers[msg["cmd"]]) do
			handler(msg)
		end
	end
end

function handle_update_position(msg)
	if tonumber(msg["id"]) ~= localplayer then
		local player_id = tonumber(msg["id"])
		players[player_id].x = tonumber(msg["x"])
		players[player_id].y = tonumber(msg["y"])
	end
end

function handle_new_player(msg)
	if msg["username"] == username then
		localplayer = tonumber(msg["id"])
	else
		print("New player \"" .. msg["username"] .. "\" joined!")
	end
 
	players[tonumber(msg["id"])] = {
		x = 0,
		y = 0
	}
end

function love.load(args)
    local connect_address = args[1] .. ":27031"
    print("connecting to " .. connect_address)
 
	register_handler("new-player", handle_new_player)
	register_handler("update-position", handle_update_position)
 
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
 
-- hsv2rgb.lua - transformes a color given in hsv to rgb values
-- Copyright (C) 2015 Max Andre (http://telegnom.org)
-- derived from work by Ulrich Radig
-- http://www.ulrichradig.de/home/index.php/projekte/hsv-to-rgb-led
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 
function hsv2rgb(h,s,v)
 
    -- calculates the position in the chromatic circle
    -- 0 - 359° (hue)
    if h < 61 then
        r = 255
        b = 0
        g = (425 * h) / 100
    elseif h >= 61 and h < 121 then
        r = 255 - ((425 * (h - 60)) / 100)
        g = 255
        b = 0
    elseif h >= 121 and h < 181 then
        r = 0
        g = 255
        b = (425 * (h-120)) / 100
    elseif h >= 181 and h < 241 then
        r = 0
        g = 255 - ((425 * (h-180))/100)
        b = 255
    elseif h >= 241 and h < 301 then
        r = (425 * (h-240))/100
        g = 0
        b = 255
    elseif h >= 241 and h < 360 then
        r = 255
        g = 0
        b = 255 - ((425 * (h-300))/100);
    end
 
    -- calculates the saturation
    -- a value in the range 0-100 (percent) is expected
    s = 100 - s
    diff = ((255 - r) * s) / 100
    r = r + diff
    diff = ((255 - g) * s) / 100
    g = g + diff
    diff = ((255 - b) * s) / 100
    b = b + diff
 
    -- calculates the black value
    -- a value in the range 0-100 (percent) is expected
    r = (r * v) / 100
    g = (g * v) / 100
    b = (b * v) / 100
    color = {r = math.floor(r), g = math.floor(g), b = math.floor(b)}
    return(color)
end