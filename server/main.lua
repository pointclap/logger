enet = require "enet"

enethost = nil
hostevent = nil

players = {}

function love.load(args)
	love.window.close()
    local listen_address = "*:27031"
    print("listening on " .. listen_address)
    -- establish host for receiving msg
    enethost = enet.host_create(listen_address)
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
    hostevent = enethost:service()
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

			if tbl["cmd"] == "new-player" then
				players[hostevent.peer:index()] = tbl["username"]

				for id, username in pairs(players) do
					hostevent.peer:send(encode_message({
						cmd = "new-player",
						username = username,
						id = id
					}))
				end

				enethost:broadcast(encode_message({
					cmd = "new-player",
					username = tbl["username"],
					id = hostevent.peer:index()
				}))
			else
				enethost:broadcast(hostevent.data)
			end
        end
    end
end

function print_table(tbl) 
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			print(k .. " = { ")
			print_table(v)
			print(" }, ")
		else 
			print(k .. " = " .. v .. ", ")
		end
	end
end