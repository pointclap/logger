localplayer = nil

subscribe_message("new-player", function(msg)
    if msg.username == username and localplayer == nil then
        print("localplayer not set, assigning " .. msg.id)
        localplayer = tonumber(msg.id)
    else
        print("New player " .. msg.username .. "#" .. msg.uniqueid .. " joined!")
    end

    players[tonumber(msg.id)] = {
        username = msg.username,
        uniqueid = tonumber(msg.uniqueid),
        x = 0,
        y = 0,
        mouseX = 0,
        mouseY = 0
    }
end)

subscribe_message("player-left", function(msg)
    players[tonumber(msg.id)] = nil
    print("Player " .. msg.username .. "#" .. msg.uniqueid .. " left!")
end)

subscribe_message("update-position", function(msg)
    if tonumber(msg.id) ~= localplayer then
        local player_id = tonumber(msg.id)
        players[player_id].x = tonumber(msg.x)
        players[player_id].y = tonumber(msg.y)
    end
end)

subscribe_message("update-mouse", function(msg)
    if tonumber(msg.id) ~= localplayer then
        local player_id = tonumber(msg.id)
        players[player_id].mouseX = tonumber(msg.mouseX)
        players[player_id].mouseY = tonumber(msg.mouseY)
    end
end)
