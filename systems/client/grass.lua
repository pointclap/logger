local grass_shader = nil
local grass_mesh = nil

hooks.add("load", function()
    local spread = 500.0

    grass_shader = love.graphics.newShader([[
        #pragma language glsl3
        extern vec2 screen;
        extern vec2 offset;
        extern float spread;
        extern float time;
        
        float PHI = 1.61803398874989484820459;
        float gold_noise(in vec2 xy, in float seed) {
            return fract(tan(distance(xy*PHI, xy)*seed)*xy.x);
        }

        float grass_wave(vec4 vertex_position) {
            float grass_wave_distance = 0.2;

            return
                // Modulate with time and seed with instance ID so each batch waves 
                // independently of each other.
                sin((time + love_InstanceID * 1.0)) *
                
                // Grass "grows" from y=0.0 to y=-grass_height so min(y, 0) ensures
                // that we only affect the top of the grass straws, not the root.
                min(vertex_position.y, 0.0)
                
                // Scale the distance
                * grass_wave_distance;
        }

        vec4 position(mat4 transform_projection, vec4 vertex_position)
        {
            vec2 expanded_screen = vec2(screen.x + spread, screen.y + spread);
            float position = gold_noise(vec2(love_InstanceID, love_InstanceID), love_InstanceID * 1.0) * expanded_screen.x * expanded_screen.y;

            float x = floor(mod(position, expanded_screen.x)) + grass_wave(vertex_position);
            float y = floor(mod(position, expanded_screen.x * expanded_screen.y) / expanded_screen.x);

            vertex_position.xy += vec2(
                mod(x - offset.x, expanded_screen.x) - spread,
                mod(y - offset.y, expanded_screen.y) - spread
            );
            return transform_projection * vertex_position;
        }
    ]], [[
        #pragma language glsl3
        vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
        {
            vec4 texcolor = Texel(tex, texture_coords);
            return texcolor * color;
        }
    ]]);

    grass_shader:send("screen", {800, 600});
    grass_shader:send("spread", spread);

    local grass_height = 16.0
    local grass_width = 16.0
    local vertices = {}
    for x = 1, 200 do
        local x = love.math.random() * spread
        local y = love.math.random() * grass_height + 1.0
        local rb = love.math.random() * 0.2 + 0.2
        local g = love.math.random() * 0.2 + 0.6

        table.insert(vertices, {x - grass_width, y - grass_height, 0, 0, rb, g, rb, 1})
        table.insert(vertices, {x + grass_width, y - grass_height, 1.0, 0, rb, g, rb, 1})
        table.insert(vertices, {x + grass_width, y, 1.0, 1.0, rb, g, rb, 1})

        table.insert(vertices, {x + grass_width, y, 1.0, 1.0, rb, g, rb, 1})
        table.insert(vertices, {x - grass_width, y, 0, 1.0, rb, g, rb, 1})
        table.insert(vertices, {x - grass_width, y - grass_height, 0, 0, rb, g, rb, 1})
    end

    grass_mesh = love.graphics.newMesh(vertices, "triangles", "static")
    grass_mesh:setTexture(love.graphics.newImage("assets/textures/grass.png"))
end)

hooks.add("draw_local_pre", function()
    if localplayer then
        love.graphics.setColor(0.1, 0.4, 0.1, 1.0)
        local width, height = love.graphics.getDimensions()
        love.graphics.rectangle("fill", 0, 0, width, height)

        local player = entities.get(localplayer)

        grass_shader:send("offset", {player.interpolated_position.x, player.interpolated_position.y});
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.setShader(grass_shader)

        love.graphics.drawInstanced(grass_mesh, 1000, 0, 0)

        love.graphics.setShader()
    end
end)

local cur_time = 0
hooks.add("update", function(dt)
    cur_time = cur_time + dt
    grass_shader:send("time", cur_time)
end)

hooks.add("resize", function(width, height)
    grass_shader:send("screen", {width, height});
end)
