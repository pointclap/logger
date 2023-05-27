localplayer = nil

subscribe_message("new-player", function(msg)
    if msg.username == username then
        localplayer = tonumber(msg.id)
    else
        print("New player \"" .. msg.username .. "\" joined!")
    end

    players[tonumber(msg.id)] = {
        x = 0,
        y = 0
    }
end)

subscribe_message("player-left", function(msg)
    players[tonumber(msg.id)] = nil
    print("Player \"" .. msg.username .. "\" left!")
end)

subscribe_message("update-position", function(msg)
    if tonumber(msg.id) ~= localplayer then
        local player_id = tonumber(msg.id)
        players[player_id].x = tonumber(msg.x)
        players[player_id].y = tonumber(msg.y)
    end
end)
