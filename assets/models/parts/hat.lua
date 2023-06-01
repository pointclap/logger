local image = love.graphics.newImage("assets/textures/hat.png");
---@type Part
local hat = {
    image = image,
    selector = {
        animation = function(entity) return "idle" end,
        direction = models.selectors.direction.from_velocity,
        colour = models.selectors.colour.from_entity,
    },
    animations = {
        idle = {
            s   = { { quad = love.graphics.newQuad(    0,  0,  8,  5, image), time = 1.0, x = -4, y = -4 } },
            n   = { { quad = love.graphics.newQuad(    9,  0,  8,  5, image), time = 1.0, x = -4, y = -4 } },
            w   = { { quad = love.graphics.newQuad(   18,  0, 10,  5, image), time = 1.0, x = -6, y = -4 } },
            e   = { { quad = love.graphics.newQuad(   29,  0, 10,  5, image), time = 1.0, x = -4, y = -4 } },
            nw  = { { quad = love.graphics.newQuad(   40,  0, 10,  5, image), time = 1.0, x = -6, y = -4 } },
            ne  = { { quad = love.graphics.newQuad(   51,  0, 10,  5, image), time = 1.0, x = -4, y = -4 } },
            sw  = { { quad = love.graphics.newQuad(   62,  0, 10,  6, image), time = 1.0, x = -6, y = -4 } },
            se  = { { quad = love.graphics.newQuad(   73,  0, 10,  6, image), time = 1.0, x = -4, y = -4 } },
        },
    }
}

return hat
