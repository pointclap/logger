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
        --[[
        walk = {
            s  = { 
                { quad = love.graphics.newQuad( 0,  0, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 0, 16, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 0, 32, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 0, 48, 16, 16 , image), time = 0.1, x = -8, y = -8 },
            },
            n  = { 
                { quad = love.graphics.newQuad( 16,  0, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 16, 16, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 16, 32, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 16, 48, 16, 16 , image), time = 0.1, x = -8, y = -8 },
            },
            w  = { 
                { quad = love.graphics.newQuad( 32,  0, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 32, 16, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 32, 32, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 32, 48, 16, 16 , image), time = 0.1, x = -8, y = -8 },
            },
            e = {
                { quad = love.graphics.newQuad( 48,  0, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 48, 16, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 48, 32, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 48, 48, 16, 16 , image), time = 0.1, x = -8, y = -8 },
            },
            nw = {
                { quad = love.graphics.newQuad( 64,  0, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 64, 16, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 64, 32, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 64, 48, 16, 16 , image), time = 0.1, x = -8, y = -8 },
            },
            ne = {
                { quad = love.graphics.newQuad( 80,  0, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 80, 16, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 80, 32, 16, 16 , image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 80, 48, 16, 16 , image), time = 0.1, x = -8, y = -8 },
            },
            sw = {
                { quad = love.graphics.newQuad( 96,  0, 16, 16 , image), time = 0.1 },
                { quad = love.graphics.newQuad( 96, 16, 16, 16 , image), time = 0.1 },
                { quad = love.graphics.newQuad( 96, 32, 16, 16 , image), time = 0.1 },
                { quad = love.graphics.newQuad( 96, 48, 16, 16 , image), time = 0.1 },
            },
            se = {
                { quad = love.graphics.newQuad( 112,  0, 16, 16 , image), time = 0.1 },
                { quad = love.graphics.newQuad( 112, 16, 16, 16 , image), time = 0.1 },
                { quad = love.graphics.newQuad( 112, 32, 16, 16 , image), time = 0.1 },
                { quad = love.graphics.newQuad( 112, 48, 16, 16 , image), time = 0.1 },
            }
        }
        ]]
    }
}

return head