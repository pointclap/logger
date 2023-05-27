enet = require "enet"

enethost = nil

players = {}

function love.load(args)
	love.window.close()
    enethost = enet.host_create("*:27031")
	print("listening..")
end

function love.update(dt)
    ServerListen()
end

function love.draw()

end

function encode_message(msg)
	encoded = ""
	for k, v in pairs(msg)	do
		encoded = encoded .. k .. "=" .. v ..";"
	end

	return encoded
end

function ServerListen()
    local hostevent = enethost:service()
    if hostevent then
        --print("Server detected message type: " .. hostevent.type)
        if hostevent.type == "connect" then
            print(hostevent.peer, "connected.")

		elseif hostevent.type == "disconnect" then
			if players[hostevent.peer:index()] ~= nil then
				enethost:broadcast(encode_message({
					cmd = "player-left",
					username = players[hostevent.peer:index()].username,
					uniqueid = players[hostevent.peer:index()].uniqueid,
					id = hostevent.peer:index()
				}))

				players[hostevent.peer:index()] = nil
			end			

		elseif hostevent.type == "receive" then
            --print("Received message: ", hostevent.data, hostevent.peer)

			tbl = {}
			for k, v in hostevent.data:gmatch("([^=]+)=([^;]+);") do
				tbl[k] = v
			end

			if tbl.cmd == "new-player" then
				-- generate random 4 digit number to uniqueify each username
				players[hostevent.peer:index()] = {
					username = tbl.username
				}

				while true do
					local uniqueidused = 0
					local newuniqueid = math.random(1, 9999)

					for id, ply in pairs(players) do
						if ply.username == tbl.username and ply.uniqueid == newuniqueid then
							uniqueidused = 1
							break
						end
					end

					if uniqueidused == 0 then
						players[hostevent.peer:index()].uniqueid = newuniqueid
						print(players[hostevent.peer:index()].username .."#" .. newuniqueid .. " joined")
						break
					end
				end

				hostevent.peer:send(encode_message({
					cmd = "new-player",
					id = hostevent.peer:index(),
					username = players[hostevent.peer:index()].username,
					uniqueid = players[hostevent.peer:index()].uniqueid
				}))

				-- Tell the new player about all other players
				for id, ply in pairs(players) do
					if id ~= hostevent.peer:index() then
						hostevent.peer:send(encode_message({
							cmd = "new-player",
							username = ply.username,
							uniqueid = ply.uniqueid,
							id = id
						}))

						-- debugging: print all players
						print(id .. " => " .. ply.username .. "#" .. ply.uniqueid)
					end
				end
				
				-- Tell all players about the new player
				enethost:broadcast(encode_message({
					cmd = "new-player",
					username = players[hostevent.peer:index()].username,
					uniqueid = players[hostevent.peer:index()].uniqueid,
					id = hostevent.peer:index()
				}))
			elseif tbl.cmd == "player-left" then
				enethost:broadcast(encode_message({
					cmd = "player-left",
					username = players[hostevent.peer:index()].username,
					uniqueid = players[hostevent.peer:index()].uniqueid,
					id = hostevent.peer:index()
				}))
	
				players[hostevent.peer:index()] = nil
			else
				enethost:broadcast(hostevent.data)
			end
        end
    end
end
