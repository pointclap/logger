local grass_shader = nil
local grass_mesh = nil

hooks.add("load", function()
    local spread = 1000.0

    grass_shader = love.graphics.newShader [[
        #pragma language glsl3
        extern vec2 screen;
        extern vec2 offset;
        extern float spread;
        
        float PHI = 1.61803398874989484820459;
        float gold_noise(in vec2 xy, in float seed) {
            return fract(tan(distance(xy*PHI, xy)*seed)*xy.x);
        }

        vec4 position(mat4 transform_projection, vec4 vertex_position)
        {
            vec2 expanded_screen = vec2(screen.x + spread, screen.y + spread);
            float position = gold_noise(vec2(love_InstanceID, love_InstanceID), love_InstanceID * 1.0) * expanded_screen.x * expanded_screen.y;

            float x = floor(mod(position, expanded_screen.x));
            float y = floor(mod(position, expanded_screen.x * expanded_screen.y) / expanded_screen.x);

            vertex_position.xy += vec2(
                mod(x - offset.x, expanded_screen.x) - spread,
                mod(y - offset.y, expanded_screen.y) - spread
            );
            return transform_projection * vertex_position;
        }


    ]];
    grass_shader:send("screen", {800, 600});
    grass_shader:send("spread", spread);

    local grass_height = 20.0
    local grass_width = 4.0
    local vertices = {}
    for y = 1, 50, 10 do
        for x = 1, 100 do
            local x = love.math.random() * spread
            local rb = love.math.random() * 0.2 + 0.2
            local g = love.math.random() * 0.6 + 0.2
            table.insert(vertices, {x, y, 0, 0, rb, g, rb, 0.1})
            table.insert(vertices, {x + grass_width / 2.0, y + grass_height, 0, 0, rb, g, rb, 0.2})
            table.insert(vertices, {x - grass_width / 2.0, y + grass_height, 0, 0, rb, g, rb, 0.2})
        end
    end

    grass_mesh = love.graphics.newMesh(vertices, "triangles", "static")
end)

hooks.add("draw_local_pre", function()
    if localplayer then
        love.graphics.setColor(0.0, 0.3, 0.0, 1.0)
        love.graphics.rectangle("fill", 0, 0, 800, 600)

        grass_shader:send("offset",
            {players[localplayer].interpolated_position.x, players[localplayer].interpolated_position.y});
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.setShader(grass_shader)
        love.graphics.drawInstanced(grass_mesh, 500)
        love.graphics.setShader()
    end
end)

local cur_time = 0
hooks.add("update", function(dt)
    cur_time = cur_time + dt
    -- grass_shader:send("time", cur_time)
end)
