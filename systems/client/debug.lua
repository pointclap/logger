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
    love.graphics.setColor(0.8, 0.8, 0.8, 1.0)
    love.graphics.draw(framerate, 20, 20)
end)

hooks.add("draw_world", function()
    if not debug_mode then return end

    love.graphics.setColor(1, 1, 1, 1)

    for _, entity in entities.all() do
        if entity then
            if entity.body then
                local x, y = entity.body:getPosition()
                love.graphics.circle("fill", x, y, 2)
            end
        end
    end

    for _, player in entities.players() do
        love.graphics.setColor(player.colour.r, player.colour.g, player.colour.b)

        if player.body then
            local x, y = player.body:getPosition()

            for _, fixture in pairs(player.body:getFixtures()) do
                local shape = fixture:getShape()
                if shape:getType() == "circle" then
                    love.graphics.circle("line", x, y, shape:getRadius())
                elseif shape:getType() == "polygon" then
                    local verts = nil

                    if player.vertices then
                        verts = player.vertices
                    else
                        verts = {shape:getPoints()}
                    end

                    for k,v in pairs(verts) do
                        if k%2==0 then
                            verts[k] = v+y
                        else
                            verts[k] = v+x
                        end
                    end
                    love.graphics.polygon("line", verts)
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
    
    love.graphics.setColor(0, 0, 0, 1)
    
    for _, player in entities.players() do   
        --love.graphics.setColor(player.colour.r, player.colour.g, player.colour.b)

        if player.mouse.x and player.mouse.y then
            local x = player.mouse.x
            local y = player.mouse.y
            
            mouse_text:set("mouse.x: " .. x)
            love.graphics.draw(mouse_text, x, y + 10)
            mouse_text:set("mouse.y: " .. y)
            love.graphics.draw(mouse_text, x, y + 20)
        end
    end
end)

hooks.add("keyreleased", function(key, scancode, isrepeat)
    if key == "f1" then
        debug_mode = not debug_mode
    end
end)
