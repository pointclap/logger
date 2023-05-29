messages = require("messages")
local enet = require "enet"
local enethost = nil
local connected_players = {}
local curtime = 0.0
local nextupdate = 0.0
local TICK_RATE = 1 / 60.0

local accumulated_deltatime = 0
local fixed_timestep = 0.008

entities = {}
entid = 0
local physics = require("systems.physics")

local function next_entity_id()
    entid = entid + 1
    return entid
end

local function load(args)
	hooks.call("load", args)
    enethost = enet.host_create("*:27031")
    print("listening..")

    -- create a box at 50,50
    physics.spawnBox(next_entity_id(), 50, 50, 20)
end

local function encode_message(msg)
    encoded = ""
    for k, v in pairs(msg) do
        encoded = encoded .. k .. "=" .. v .. ";"
    end

    return encoded
end

local function generate_uniqueid(username)
    local newuniqueid = ""

    while true do
        local uniqueidused = 0
        newuniqueid = math.random(1, 9999)

        for id, ply in pairs(connected_players) do
            if ply.username == username and ply.uniqueid == newuniqueid then
                uniqueidused = 1
                break
            end
        end

        if uniqueidused == 0 then
            break
        end
    end

    return newuniqueid
end

local function update(dt)
    curtime = curtime + dt
    if curtime < nextupdate then return end
    nextupdate = curtime + TICK_RATE

    local hostevent = enethost:service()
    if hostevent then
        if hostevent.type == "connect" then
            print(hostevent.peer, "connected.")

        elseif hostevent.type == "disconnect" then
            if connected_players[hostevent.peer:index()] ~= nil then
                enethost:broadcast(encode_message({
                    cmd = "player-left",
                    username = connected_players[hostevent.peer:index()].username,
                    uniqueid = connected_players[hostevent.peer:index()].uniqueid,
                    id = hostevent.peer:index()
                }))

                connected_players[hostevent.peer:index()] = nil
            end

        elseif hostevent.type == "receive" then
            --print("Received message: ", hostevent.data, hostevent.peer)

            tbl = {}
            for k, v in hostevent.data:gmatch("([^=]+)=([^;]+);") do
                tbl[k] = v
            end

            if tbl.cmd ~= "update-mouse" and tbl.cmd ~= "update-position" then
                print("Received message: ", hostevent.data, hostevent.peer)
            end

            if tbl.cmd == "new-player" then
                -- generate random 4 digit number to uniqueify each username
                connected_players[hostevent.peer:index()] = {
                    username = tbl.username,
                    uniqueid = generate_uniqueid(tbl.username),
                }

                print(tbl.username .. "#" .. connected_players[hostevent.peer:index()].uniqueid .. " joined")

                hostevent.peer:send(encode_message({
                    cmd = "new-player",
                    id = hostevent.peer:index(),
                    username = connected_players[hostevent.peer:index()].username,
                    uniqueid = connected_players[hostevent.peer:index()].uniqueid
                }))

                -- Tell the new player about all other players
                for id, ply in pairs(connected_players) do
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

                -- and the boxes
                for ent_id, ent in pairs(entities) do
                    if ent.body then
                        hostevent.peer:send(encode_message({
                            cmd = "spawn-box",
                            ent_id = ent_id,
                            pos_x = ent.body.x,
                            pos_y = ent.body.y,
                            size = 20 -- to do: send vert details to/from server 
                        }))
                    end
                end

                -- Tell all players about the new player
                enethost:broadcast(encode_message({
                    cmd = "new-player",
                    username = connected_players[hostevent.peer:index()].username,
                    uniqueid = connected_players[hostevent.peer:index()].uniqueid,
                    id = hostevent.peer:index()
                }))
            elseif tbl.cmd == "player-left" then
                enethost:broadcast(encode_message({
                    cmd = "player-left",
                    username = connected_players[hostevent.peer:index()].username,
                    uniqueid = connected_players[hostevent.peer:index()].uniqueid,
                    id = hostevent.peer:index()
                }))

                connected_players[hostevent.peer:index()] = nil
            else
                enethost:broadcast(hostevent.data)
            end
        end
    end
    
	accumulated_deltatime = accumulated_deltatime + dt
	while accumulated_deltatime > fixed_timestep do
		hooks.call("fixed_timestep", fixed_timestep)
		accumulated_deltatime = accumulated_deltatime - fixed_timestep
	end

    -- Now send the world data to all players
    for ent_id, ent in pairs(entities) do
        if ent.body then
            enethost:broadcast(encode_message({
                cmd = "update-world",
                ent_id = ent_id,
                x = ent.body.x,
                y = ent.body.y
            }))
        end
    end
end

return {
    load = load,
    update = update
}
