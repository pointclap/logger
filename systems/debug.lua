
local font = love.graphics.newFont(12, "mono")
local framerate = love.graphics.newText(font, {0.8, 0.8, 0.8, 1.0, "0.00ms"})

local countdown = 0
function print_debug_information(dt)
    countdown = countdown - dt
    if countdown < 0 then
        countdown = 0.1
        framerate:set(math.floor(dt * 100000) / 100 .. "ms")
    end
    love.graphics.setColor(0.8, 0.8, 0.8, 1.0)
    love.graphics.draw(framerate, 20, 20)
end

function render_debug_bodies()
    for _, player in pairs(players) do
        if player.body then
            local x, y = player.body:getPosition()

            for _, fixture in pairs(player.body:getFixtures()) do
                local shape = fixture:getShape()
                if shape:getType() == "circle" then
                    love.graphics.circle("line", x, y, shape:getRadius())
                end
            end
        end
    end
end