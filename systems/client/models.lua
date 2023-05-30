
local directions = {"w", "nw", "n", "ne", "e", "se", "s", "sw"}

local character_image = love.graphics.newImage("assets/models/character.png");
local character = {
    image = character_image,
    animation_selector = function(player)
        local x, y = player.body:getLinearVelocity()

        if x*x+y*y < 10 then
            if player.animated.animation ~= "stand" then
                player.animated.animation = "stand"
                player.animated.frame = 1
            end
        else
            if player.animated.animation ~= "walk" then
                player.animated.animation = "walk"
                player.animated.frame = 1
            end

            -- take the angle of the velocity, divide it into 8 equal parts and assign
            -- each of them to one animation direction.
            -- local angle = math.floor(((math.atan2(y, x) + math.pi) / (2*math.pi) * 8 + (1/16)) % 8) + 1
            -- player.animated.direction = directions[angle]
        end
    
        -- get angle from player to their mouse
        local w, h = love.graphics:getDimensions()
        x = player.mouseX - w / 2
        y = player.mouseY - h / 2
        local angle = math.floor(((math.atan2(y, x) + math.pi) / (2*math.pi) * 8 + (1/16)) % 8) + 1
        player.animated.direction = directions[angle]
    end,
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

local function set_model(entity_id, model)
    local model = models[model]

    entities.get(entity_id).animated = {
        model = model,
        frame = 1,
        frametime = 0,
        direction = "s",
    }
end

hooks.add("update", function(dt)
    for _, player in entities.players() do
        if player.animated then
            if player.animated.model.animation_selector then
                player.animated.model.animation_selector(player)
            end

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
end)

hooks.add("draw_world", function()
    for _, player in entities.players() do
        love.graphics.setColor(1, 1, 1, 1)
        if player.animated then
            local quad = player.animated.model.animations[player.animated.animation][player.animated.direction][player.animated.frame].quad
            local x, y, w, h = quad:getViewport()

            love.graphics.draw(player.animated.model.image, quad, player.interpolated_position.x - w / 2, player.interpolated_position.y - h / 2)
        end
    end
end)

return {
    set_model = set_model
}