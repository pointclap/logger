messages.subscribe("ping", function(peer, msg)
    peer:send({
        cmd = "pong"
    })
end)
