
local character_image = love.graphics.newImage("assets/models/character.png");
local character = {
    image = character_image,
    default_animation = "walk",
    animations = {
        stand = {
            s  = { { quad = love.graphics.newQuad(   0, 0, 16, 16 , character_image), time = 1.0 } },
            n  = { { quad = love.graphics.newQuad(  16, 0, 16, 16 , character_image), time = 1.0 } },
            w  = { { quad = love.graphics.newQuad(  32, 0, 16, 16 , character_image), time = 1.0 } },
            e  = { { quad = love.graphics.newQuad(  48, 0, 16, 16 , character_image), time = 1.0 } },
            nw = { { quad = love.graphics.newQuad(  64, 0, 16, 16 , character_image), time = 1.0 } },
            ne = { { quad = love.graphics.newQuad(  80, 0, 16, 16 , character_image), time = 1.0 } },
            sw = { { quad = love.graphics.newQuad(  96, 0, 16, 16 , character_image), time = 1.0 } },
            se = { { quad = love.graphics.newQuad( 112, 0, 16, 16 , character_image), time = 1.0 } },
        },
        walk = {
            s  = { 
                { quad = love.graphics.newQuad( 0,  0, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 0, 16, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 0, 32, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 0, 48, 16, 16 , character_image), time = 0.1 },
            },
            n  = { 
                { quad = love.graphics.newQuad( 16,  0, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 16, 16, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 16, 32, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 16, 48, 16, 16 , character_image), time = 0.1 },
            },
            w  = { 
                { quad = love.graphics.newQuad( 32,  0, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 32, 16, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 32, 32, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 32, 48, 16, 16 , character_image), time = 0.1 },
            },
            e = {
                { quad = love.graphics.newQuad( 48,  0, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 48, 16, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 48, 32, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 48, 48, 16, 16 , character_image), time = 0.1 },
            },
            nw = {
                { quad = love.graphics.newQuad( 64,  0, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 64, 16, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 64, 32, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 64, 48, 16, 16 , character_image), time = 0.1 },
            },
            ne = {
                { quad = love.graphics.newQuad( 80,  0, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 80, 16, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 80, 32, 16, 16 , character_image), time = 0.1 },
                { quad = love.graphics.newQuad( 80, 48, 16, 16 , character_image), time = 0.1 },
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

local models = {
    character = character
}

function set_model(player_id, model)
    local player = players[player_id]
    local x, y = 0, 0
    if player.animated then
        x, y = player.animated.x, player.animated.y
    elseif player.body then
        x, y = player.body:getPosition()
    end

    local model = models[model]

    players[player_id].animated = {
        x = x,
        y = y,
        model = model,
        frame = 1,
        frametime = 0,
        direction = "s",
        animation = model.default_animation,
    }
end

function interpolate_model_location(dt)
    for _, player in pairs(players) do
        if player.body and player.animated then
            local x, y = player.body:getPosition()

            local x_distance = x - player.animated.x
            local y_distance = y - player.animated.y

            player.animated.x = player.animated.x + x_distance * dt * 20.0
            player.animated.y = player.animated.y + y_distance * dt * 20.0
        end
    end
end

function update_animation(dt)
    for _, player in pairs(players) do
        if player.animated then
            player.animated.frametime = player.animated.frametime + dt

            local directed_animation = player.animated.model.animations[player.animated.animation][player.animated.direction]

            if player.animated.frametime > directed_animation[player.animated.frame].time then
                player.animated.frametime = 0
                player.animated.frame = (player.animated.frame + 1)

                if not directed_animation[player.animated.frame] then
                    player.animated.frame = 1
                end
            end
        end
    end
end

function render_model()
    for _, player in pairs(players) do
        love.graphics.setColor(1, 1, 1, 1)
        if player.animated then
            print("rendering")
            local quad = player.animated.model.animations[player.animated.animation][player.animated.direction][player.animated.frame].quad
            local x, y, w, h = quad:getViewport()

            love.graphics.draw(player.animated.model.image, quad, player.animated.x - w / 2, player.animated.y - h / 2)
        end
    end
end
