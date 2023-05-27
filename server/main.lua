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
        print("Server detected message type: " .. hostevent.type)
        if hostevent.type == "connect" then
            print(hostevent.peer, "connected.")

		elseif hostevent.type == "disconnect" then
			enethost:broadcast(encode_message({
				cmd = "player-left",
				username = players[hostevent.peer:index()],
				id = hostevent.peer:index()
			}))

			players[hostevent.peer:index()] = nil

		elseif hostevent.type == "receive" then
            print("Received message: ", hostevent.data, hostevent.peer)

			tbl = {}
			for k, v in hostevent.data:gmatch("([^=]+)=([^;]+);") do
				tbl[k] = v
			end

			if tbl.cmd == "new-player" then
				for id, username in pairs(players) do
					hostevent.peer:send(encode_message({
						cmd = "new-player",
						username = username,
						id = id
					}))
				end

				players[hostevent.peer:index()] = tbl.username

				enethost:broadcast(encode_message({
					cmd = "new-player",
					username = tbl.username,
					id = hostevent.peer:index()
				}))
			elseif tbl.cmd == "player-left" then
				print("test")
				enethost:broadcast(encode_message({
					cmd = "player-left",
					username = players[hostevent.peer:index()],
					id = hostevent.peer:index()
				}))
	
				players[hostevent.peer:index()] = nil
			else
				enethost:broadcast(hostevent.data)
			end
        end
    end
end
