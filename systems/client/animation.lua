local models = {
    character = require("assets.models.character")
}

local function set_animation(entity_id, animation_name)

end

--[[
local function set_animation(entity_id, animation_name)
    local animation = models[animation_name]

    entities.get(entity_id).animation = {
        animation = animation,
        current_animation = animation.default_animation,
        frame = 1,
        frametime = 0,
        direction = "s",
    }
end

hooks.add("update", function(dt)
    for _, player in entities.players() do
        if player.animation then
            if player.animation.animation.animation_selector then
                player.animation.animation.animation_selector(player)
            end

            player.animation.frametime = player.animation.frametime + dt

            local directed_animation = player.animation.animation.animations[player.animation.current_animation][player.animation.direction]

            if player.animation.frametime > directed_animation[player.animation.frame].time then
                player.animation.frametime = 0
                player.animation.frame = (player.animation.frame + 1)

                if not directed_animation[player.animation.frame] then
                    player.animation.frame = 1
                end
            end
        end
    end
end)

hooks.add("draw_world", function()
    for _, player in entities.players() do
        love.graphics.setColor(1, 1, 1, 1)
        if player.animation then
            local quad = player.animation.animation.animations[player.animation.current_animation][player.animation.direction][player.animation.frame].quad
            local x, y, w, h = quad:getViewport()

            love.graphics.draw(player.animation.animation.image, quad, player.interpolated_position.x - w / 2, player.interpolated_position.y - h / 2)
        end
    end
end)
]]

return {
    set_animation = set_animation
}