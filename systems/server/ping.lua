hooks.add("update", function(dt)
    local current_time = love.timer.getTime()

    for _, player in entities.players() do
        if not player.latency then
            player.latency = 0.0
        end

        if (not player.ping or current_time - player.ping > 5.0) and player.peer then
            player.peer:send({
                cmd = "ping"
            })
            player.ping = current_time
        end
    end
end)

messages.subscribe("pong", function(peer, msg)
    for _, player in entities.players() do
        if player.ping and player.peer:index() == peer:index() then
            player.latency = love.timer.getTime() - player.ping
        end
    end
end)
