tiles = {}
canvas = nil

local world_image = love.graphics.newImage("assets/textures/tiny-town.png");
tile_templates = {
    image = world_image,
    tiles = {
        shortgrass = love.graphics.newQuad(    0,   0, 16, 16, world_image),
        longgrass  = love.graphics.newQuad(   16,   0, 16, 16, world_image),
        flowers    = love.graphics.newQuad(   32,   0, 16, 16, world_image),
        coin       = love.graphics.newQuad(  144, 112, 16, 16, world_image)
    }
}

local function init()
    if SERVER then
        -- generate world icons
        --  1<=x<= 6 : short grass
        --  7<=x<= 9 : long grass
        --     x =10 : flowers
        local min, max = -4, 4
        for i = min, max do
            for k = min, max do
                local newtile = {}
                newtile.position = {
                    x = k * (max - min),
                    y = i * (max - min)
                }
                local n = math.random(1, 10)
                if n == 10 then
                    newtile.type = "flowers"
                elseif n >= 7 and n <= 9 then
                    newtile.type = "longgrass"
                else
                    newtile.type = "shortgrass"
                end

                table.insert(tiles, newtile)
            end
        end

        log.debug("finished generating world!")
    else
        canvas = love.graphics.newCanvas(512, 512)
        love.graphics:clear(0.2, 0.3, 0.9, 1)
    end
end

messages.subscribe("update-tile", function(peer, msg)
    if SERVER then return end

    local id = tonumber(msg.id)
    local newtile = {}
    newtile.position = {
        x = tonumber(msg.x),
        y = tonumber(msg.y)
    }
    newtile.type = msg.type
    tiles[id] = newtile

    -- update the canvas
    local quad = tile_templates.tiles[newtile.type]
    local x, y, w, h = quad:getViewport()

    love.graphics.setCanvas(canvas)
    print("pos: (" .. newtile.position.x .. ", " .. newtile.position.y .. ")")
    love.graphics.draw(tile_templates.image, quad, newtile.position.x - w / 2, newtile.position.y - h / 2)
    love.graphics.setCanvas()
end)

local function draw() 
    if SERVER then return end

    local width, height = canvas:getDimensions()
    love.graphics.draw(tile_templates.image, tile_templates.tiles["coin"], 0, 0)
    love.graphics.draw(canvas, -width / 2, -height / 2)
end

return {
    tiles = tiles,
    canvas = canvas,
    init = init,
    draw = draw
}