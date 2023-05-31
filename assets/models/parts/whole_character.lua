local character_image = love.graphics.newImage("assets/textures/character.png");
local character = {
    image = character_image,
    selector = {
        animation = models.selectors.animation.from_velocity({
            {0, "stand"},
            {10, "walk"},
        }),
        direction = models.selectors.direction.from_mouse
    },
    animations = {
        stand = {
            s  = { { quad = love.graphics.newQuad(   0, 0, 16, 16 , character_image), time = 1.0, x = -8, y = -8 } },
            n  = { { quad = love.graphics.newQuad(  16, 0, 16, 16 , character_image), time = 1.0, x = -8, y = -8 } },
            w  = { { quad = love.graphics.newQuad(  32, 0, 16, 16 , character_image), time = 1.0, x = -8, y = -8 } },
            e  = { { quad = love.graphics.newQuad(  48, 0, 16, 16 , character_image), time = 1.0, x = -8, y = -8 } },
            nw = { { quad = love.graphics.newQuad(  64, 0, 16, 16 , character_image), time = 1.0, x = -8, y = -8 } },
            ne = { { quad = love.graphics.newQuad(  80, 0, 16, 16 , character_image), time = 1.0, x = -8, y = -8 } },
            sw = { { quad = love.graphics.newQuad(  96, 0, 16, 16 , character_image), time = 1.0, x = -8, y = -8 } },
            se = { { quad = love.graphics.newQuad( 112, 0, 16, 16 , character_image), time = 1.0, x = -8, y = -8 } },
        },
        walk = {
            s  = { 
                { quad = love.graphics.newQuad( 0,  0, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 0, 16, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 0, 32, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 0, 48, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
            },
            n  = { 
                { quad = love.graphics.newQuad( 16,  0, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 16, 16, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 16, 32, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 16, 48, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
            },
            w  = { 
                { quad = love.graphics.newQuad( 32,  0, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 32, 16, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 32, 32, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 32, 48, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
            },
            e = {
                { quad = love.graphics.newQuad( 48,  0, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 48, 16, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 48, 32, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 48, 48, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
            },
            nw = {
                { quad = love.graphics.newQuad( 64,  0, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 64, 16, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 64, 32, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 64, 48, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
            },
            ne = {
                { quad = love.graphics.newQuad( 80,  0, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 80, 16, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 80, 32, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
                { quad = love.graphics.newQuad( 80, 48, 16, 16 , character_image), time = 0.1, x = -8, y = -8 },
            },
            sw = {
                { quad = love.graphics.newQuad( 96,  0, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 96, 16, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 96, 32, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 96, 48, 16, 16 , character_image), time = 0.1 },
            },
            se = {
                { quad = love.graphics.newQuad( 112,  0, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 112, 16, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 112, 32, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 112, 48, 16, 16 , character_image), time = 0.1 },
            }
        }
    }
}

return character