local debug_mode = false
local font = love.graphics.newFont(12, "mono")
font:setFilter("nearest")
local framerate = love.graphics.newText(font, {0.8, 0.8, 0.8, 1.0, "0.00ms"})

local countdown = 0
local function update_debug_information(dt)
    if not debug_mode then return end

    countdown = countdown - dt
    if countdown < 0 then
        countdown = 0.1
        framerate:set(math.floor(dt * 100000) / 100 .. "ms")
    end
end

local function render_debug_information()
    if not debug_mode then return end
    love.graphics.setColor(0.8, 0.8, 0.8, 1.0)
    love.graphics.draw(framerate, 20, 20)
    
    for _, player in pairs(players) do   
        love.graphics.setColor(player.colour.r, player.colour.g, player.colour.b)

        if player.mouseX and player.mouseY then
            local mouseX = player.mouseX
            local mouseY = player.mouseY

            if id ~= localplayer and player.interpolated_position then
                mouseX = mouseX + player.interpolated_position.x - players[localplayer].interpolated_position.x
                mouseY = mouseY + player.interpolated_position.y - players[localplayer].interpolated_position.y
            end

            player.drawable_text:set("mouseX: " .. player.mouseX)
            love.graphics.draw(player.drawable_text, mouseX, mouseY + 10)
            player.drawable_text:set("mouseY: " .. player.mouseY)
            love.graphics.draw(player.drawable_text, mouseX, mouseY + 20)
        end
    end
end

local function render_debug_bodies()
    if not debug_mode then return end

    for _, player in pairs(players) do
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
            -- love.graphics.scale(fontSize)
            player.drawable_text:set("int x: " .. player.interpolated_position.x)
            love.graphics.draw(player.drawable_text, player.interpolated_position.x, player.interpolated_position.y + 30)
            player.drawable_text:set("int y: " .. player.interpolated_position.y)
            love.graphics.draw(player.drawable_text, player.interpolated_position.x, player.interpolated_position.y + 40)
            love.graphics.pop()
        end
    end
end

local function keyreleased(key, scancode, isrepeat)
    if key == "f1" then
        debug_mode = not debug_mode
    end
end

return {
    keyreleased = keyreleased,
    update = update_debug_information,
    draw_local = render_debug_bodies,
    draw_global = render_debug_information,
}