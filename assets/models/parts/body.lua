local image = love.graphics.newImage("assets/textures/body.png");
local body = {
    image = image,
    selector = {
        animation = models.selectors.animation.from_velocity({
            {0, "stand"},
            {10, "walk"},
        }),
        direction = models.selectors.direction.from_velocity
    },
    animations = {
        stand = {
            s  = { { quad = love.graphics.newQuad(   0,  0, 12,  9, image), time = 1.0, x = -6, y = -4 } },
            n  = { { quad = love.graphics.newQuad(  13,  0, 12,  9, image), time = 1.0, x = -6, y = -4 } },
            w  = { { quad = love.graphics.newQuad(  27,  0,  5,  9, image), time = 1.0, x = -3, y = -4 } },
            e  = { { quad = love.graphics.newQuad(  37,  0,  5,  9, image), time = 1.0, x = -2, y = -4 } },
            nw = { { quad = love.graphics.newQuad(  45,  0,  6,  9, image), time = 1.0, x = -3, y = -4 } },
            ne = { { quad = love.graphics.newQuad(  54,  0,  6,  9, image), time = 1.0, x = -3, y = -4 } },
            sw = { { quad = love.graphics.newQuad(  62,  0,  7,  9, image), time = 1.0, x = -4, y = -4 } },
            se = { { quad = love.graphics.newQuad(  70,  0,  7,  9, image), time = 1.0, x = -3, y = -4 } },
        },
        walk = {
            s  = { 
                { quad = love.graphics.newQuad(  0, 10, 12,  9, image), time = 0.1, x = -6, y = -6 },
                { quad = love.graphics.newQuad(  0, 20, 12,  9, image), time = 0.1, x = -6, y = -6 },
                { quad = love.graphics.newQuad(  0, 30, 12,  9, image), time = 0.1, x = -6, y = -6 },
                { quad = love.graphics.newQuad(  0, 40, 12,  9, image), time = 0.1, x = -6, y = -6 },
            },
            n  = {
                { quad = love.graphics.newQuad( 13, 10, 12,  9, image), time = 0.1, x = -6, y = -4 },
                { quad = love.graphics.newQuad( 13, 20, 12,  9, image), time = 0.1, x = -6, y = -4 },
                { quad = love.graphics.newQuad( 13, 30, 12,  9, image), time = 0.1, x = -6, y = -4 },
                { quad = love.graphics.newQuad( 13, 40, 12,  9, image), time = 0.1, x = -6, y = -4 },
            },
            w  = { 
                { quad = love.graphics.newQuad( 26, 10,  8,  9, image), time = 0.1, x = -4, y = -4 },
                { quad = love.graphics.newQuad( 26, 20,  8,  9, image), time = 0.1, x = -4, y = -4 },
                { quad = love.graphics.newQuad( 26, 30,  8,  9, image), time = 0.1, x = -4, y = -4 },
                { quad = love.graphics.newQuad( 26, 40,  8,  9, image), time = 0.1, x = -4, y = -4 },
            },
            e  = { 
                { quad = love.graphics.newQuad( 35, 10,  8,  9, image), time = 0.1, x = -4, y = -4 },
                { quad = love.graphics.newQuad( 35, 20,  8,  9, image), time = 0.1, x = -4, y = -4 },
                { quad = love.graphics.newQuad( 35, 30,  8,  9, image), time = 0.1, x = -4, y = -4 },
                { quad = love.graphics.newQuad( 35, 40,  8,  9, image), time = 0.1, x = -4, y = -4 },
            },
            nw  = { 
                { quad = love.graphics.newQuad( 44, 10, 8,  9, image), time = 0.1, x = -4, y = -4 },
                { quad = love.graphics.newQuad( 44, 20, 8,  9, image), time = 0.1, x = -4, y = -4 },
                { quad = love.graphics.newQuad( 44, 30, 8,  9, image), time = 0.1, x = -4, y = -4 },
                { quad = love.graphics.newQuad( 44, 40, 8,  9, image), time = 0.1, x = -4, y = -4 },
            },
            ne  = { 
                { quad = love.graphics.newQuad( 53, 10, 8,  9, image), time = 0.1, x = -4, y = -4 },
                { quad = love.graphics.newQuad( 53, 20, 8,  9, image), time = 0.1, x = -4, y = -4 },
                { quad = love.graphics.newQuad( 53, 30, 8,  9, image), time = 0.1, x = -4, y = -4 },
                { quad = love.graphics.newQuad( 53, 40, 8,  9, image), time = 0.1, x = -4, y = -4 },
            },
            sw  = {
                { quad = love.graphics.newQuad( 62, 10, 7,  9, image), time = 0.1, x = -4, y = -4 },
                { quad = love.graphics.newQuad( 62, 20, 7,  9, image), time = 0.1, x = -4, y = -4 },
                { quad = love.graphics.newQuad( 62, 30, 7,  9, image), time = 0.1, x = -4, y = -4 },
                { quad = love.graphics.newQuad( 62, 40, 7,  9, image), time = 0.1, x = -4, y = -4 },
            },
            se  = {
                { quad = love.graphics.newQuad( 70, 10, 7,  9, image), time = 0.1, x = -3, y = -4 },
                { quad = love.graphics.newQuad( 70, 20, 7,  9, image), time = 0.1, x = -3, y = -4 },
                { quad = love.graphics.newQuad( 70, 30, 7,  9, image), time = 0.1, x = -3, y = -4 },
                { quad = love.graphics.newQuad( 70, 40, 7,  9, image), time = 0.1, x = -3, y = -4 },
            }
        }
    }
}

return body