
local font = love.graphics.newFont(12, "mono")
local framerate = love.graphics.newText(font, {0.8, 0.8, 0.8, 1.0, "0.00ms"})

local countdown = 0
function print_debug_information(dt)
    countdown = countdown - dt
    if countdown < 0 then
        countdown = 0.1
        framerate:set(math.floor(dt * 100000) / 100 .. "ms")
    end
    love.graphics.draw(framerate, 20, 20)
end
