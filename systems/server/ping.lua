hooks.add("update", function(dt)
    for _, player in entities.players() do
        if not player.latency then
            player.latency = 0.0
        end

        if not player.ping and player.peer then
            player.peer:send({
                cmd = "ping"
            })
            player.ping = love.timer.getTime()
        end
    end
end)

messages.subscribe("pong", function(peer, msg)
    for _, player in entities.players() do
        if player.ping and player.peer:index() == peer:index() then
            player.latency = love.timer.getTime() - player.ping
            player.ping = nil
        end
    end
end)
