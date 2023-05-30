local debug_mode = false
local font = love.graphics.newFont(12, "mono")
font:setFilter("nearest")

local mouse_text = love.graphics.newText(font, {{ 1.0, 1.0, 1.0 }, ""})
local framerate = love.graphics.newText(font, {0.8, 0.8, 0.8, 1.0, "0.00ms"})

local countdown = 0
hooks.add("update",  function(dt)
    if not debug_mode then return end

    countdown = countdown - dt
    if countdown < 0 then
        countdown = 0.1
        framerate:set(math.floor(dt * 100000) / 100 .. "ms")
    end
end)

hooks.add("draw_local", function()
    if not debug_mode then return end
    love.graphics.setColor(0.8, 0.8, 0.8, 1.0)
    love.graphics.draw(framerate, 20, 20)
    
    for _, player in entities.players() do   
        love.graphics.setColor(player.colour.r, player.colour.g, player.colour.b)

        if player.mouse.x and player.mouse.y then
            local x = player.mouse.x
            local y = player.mouse.y

            if id ~= localplayer and player.interpolated_position then
                x = mouse.x + player.interpolated_position.x - player.interpolated_position.x
                y = mouse.y + player.interpolated_position.y - player.interpolated_position.y
            end

            mouse_text:set("mouse.x: " .. player.mouse.x)
            love.graphics.draw(mouse_text, x, y + 10)
            mouse_text:set("mouse.y: " .. player.mouse.y)
            love.graphics.draw(mouse_text, x, y + 20)
        end
    end
end)

hooks.add("draw_world", function()
    if not debug_mode then return end

    for _, player in entities.players() do
        love.graphics.setColor(player.colour.r, player.colour.g, player.colour.b)

        if player.body then
            local x, y = player.body:getPosition()

            for _, fixture in pairs(player.body:getFixtures()) do
                local shape = fixture:getShape()
                if shape:getType() == "circle" then
                    love.graphics.circle("line", x, y, shape:getRadius())
                end
            end
                
            love.graphics.push()
            mouse_text:set("int x: " .. player.interpolated_position.x)
            love.graphics.draw(mouse_text, player.interpolated_position.x, player.interpolated_position.y + 30)
            mouse_text:set("int y: " .. player.interpolated_position.y)
            love.graphics.draw(mouse_text, player.interpolated_position.x, player.interpolated_position.y + 40)
            love.graphics.pop()
        end
    end
end)

hooks.add("keyreleased", function(key, scancode, isrepeat)
    if key == "f1" then
        debug_mode = not debug_mode
    end
end)
