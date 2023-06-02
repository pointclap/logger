local world = nil
tiles = {}
local velocity_iterations = 8
local position_iterations = 3
local drag_coefficient = 5

local function collision_callback(a, b, contact)
    local a, b = a:getUserData(), b:getUserData()

    if a and b and entities.get(a) and entities.get(b) then
        hooks.call("collision", a, b, contact)
    end
end

hooks.add("load", function()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(collision_callback)
end)

local function new_body(type)
    return love.physics.newBody(world, 0, 0, type)
end

local function spawnCircle(id, x, y, radius)
    local entity = nil
    if SERVER then
        if not radius then return end

        id, entity = entities.spawn()
    else
        entity = entities.get(id)
    end

    local body = physics.new_body("dynamic");
    body:setPosition(x, y)

    local shape = love.physics.newCircleShape(radius)
    local fixture = love.physics.newFixture(body, shape, 5)
    fixture:setUserData(id)

    entity.is_circle = true
    entity.interpolated_position = {
        x = x,
        y = y
    }
    entity.body = body
    entity.radius = radius
end

local function spawnBox(id, x, y, width, height)
    local entity = nil

    if SERVER then            
        if width and not height then
            height = width
        elseif height and not width then 
            width = height
        elseif not width and not height then
            return
        end

        id, entity = entities.spawn()
    else
        entity = entities.get(id)
    end
    
    local body = physics.new_body("dynamic");
    body:setPosition(x, y)

    local shape = love.physics.newPolygonShape(-width / 2, -height / 2, 
                                                width / 2, -height / 2,
                                                width / 2,  height / 2, 
                                               -width / 2,  height / 2)

    local fixture = love.physics.newFixture(body, shape, 5)
    fixture:setUserData(id)

    entity.is_box = true
    entity.interpolated_position = {
        x = x,
        y = x
    }
    entity.body = body
    entity.vertices = {shape:getPoints()}
    entity.width = width
    entity.height = height
end

local function apply_drag(dt)
    for _, entity in entities.all() do
        if entity.body then
            local x, y = entity.body:getLinearVelocity()
            entity.body:applyForce(-x * drag_coefficient, -y * drag_coefficient)

            local w = entity.body:getAngularVelocity()
            entity.body:applyTorque(-w * drag_coefficient)
        end
    end
end

local function interpolate_position(dt)
    for _, entity in entities.all() do
        if entity.body and entity.interpolated_position then
            local x, y = entity.body:getPosition()

            local x_distance = x - entity.interpolated_position.x
            local y_distance = y - entity.interpolated_position.y

            entity.interpolated_position.x = entity.interpolated_position.x + x_distance * dt * 20.0
            entity.interpolated_position.y = entity.interpolated_position.y + y_distance * dt * 20.0

            -- entity.interpolated_position.x = x
            -- entity.interpolated_position.y = y
        end
    end
end

hooks.add("fixed_timestep", function(fixed_timestep)
    world:update(fixed_timestep, velocity_iterations, position_iterations)
    apply_drag(fixed_timestep)
    interpolate_position(fixed_timestep)
end)

messages.subscribe("update-body", function(peer, msg)
    local player_id = tonumber(msg.id);

    local entity = entities.get(tonumber(msg.id))

    if not entity then return end
    
    if entity.body then
        entity.body:setPosition(tonumber(msg.x), tonumber(msg.y))
        entity.body:setLinearVelocity(tonumber(msg.vx), tonumber(msg.vy))
        entity.body:setAngle(tonumber(msg.a))

        if entity.player then
            entity.body.applyForce(tonumber(msg.ax), tonumber(msg.ay))
        end
    end
end)

hooks.add("draw_world", function()
    local selected_entity_id = nil
    local selected_x, selected_y = 0, 0

    for ent_id, ent in entities.all() do
        if localplayer then
            local player = entities.get(localplayer)
            if player then
                if player.selected_entity.id then
                    if player.selected_entity.id == ent_id then
                        selected_entity_id = ent_id
                        selected_x = player.selected_entity.x
                        selected_y = player.selected_entity.y
                    end
                end
            end
        end

        if selected_entity_id then
            love.graphics.setColor({1, 0, 0})
        else
            love.graphics.setColor({1, 1, 1})
        end

        if ent.body and ent.interpolated_position then
            local x, y = ent.body:getPosition()
            -- local x = ent.interpolated_position.x
            -- local y = ent.interpolated_position.y
            
            for _, fixture in pairs(ent.body:getFixtures()) do
                local shape = fixture:getShape()
                
                if shape:getType() == "polygon" then
                    local verts = {ent.body:getWorldPoints(shape:getPoints())}

                    love.graphics.polygon("line", verts)
                elseif shape:getType() == "circle" and ent.radius then
                    love.graphics.circle("line", x, y, ent.radius)
                end
            end

            -- draw a little dot where a player has the body selected)
            if selected_entity_id then
                local point_x, point_y = ent.body:getWorldPoint(selected_x, selected_y)
                love.graphics.circle("fill", point_x, point_y, 2)
            end
        end
    end
end)

return {
    new_body    = new_body,
    spawnBox    = spawnBox,
    spawnCircle = spawnCircle
}
