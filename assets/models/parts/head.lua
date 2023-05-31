local image = love.graphics.newImage("assets/textures/head.png");
local head = {
    image = image,
    selector = {
        animation = function(entity) return "stare" end,
        direction = models.selectors.direction.from_velocity
    },
    animations = {
        stare = {
            s   = { { quad = love.graphics.newQuad(    0,  0, 10,  8, image), time = 1.0, x = -5, y = -4 } },
            n   = { { quad = love.graphics.newQuad(   10,  0, 10,  8, image), time = 1.0, x = -5, y = -4 } },
            w   = { { quad = love.graphics.newQuad(   20,  0, 10,  8, image), time = 1.0, x = -5, y = -4 } },
            e   = { { quad = love.graphics.newQuad(   30,  0, 10,  8, image), time = 1.0, x = -5, y = -4 } },
            nw  = { { quad = love.graphics.newQuad(   40,  0, 10,  8, image), time = 1.0, x = -5, y = -4 } },
            ne  = { { quad = love.graphics.newQuad(   50,  0, 10,  8, image), time = 1.0, x = -5, y = -4 } },
            sw  = { { quad = love.graphics.newQuad(   60,  0, 10,  8, image), time = 1.0, x = -5, y = -4 } },
            se  = { { quad = love.graphics.newQuad(   70,  0, 10,  8, image), time = 1.0, x = -5, y = -4 } },
        },
    }
}

return head
