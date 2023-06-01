local right_open_path   = "assets/textures/right_open.png"
local right_point_path  = "assets/textures/right_point.png";
local right_closed_path = "assets/textures/right_closed.png";

-- Drawing images uses "Image"..
local right_open_image   = love.graphics.newImage(right_open_path)
local right_point_image  = love.graphics.newImage(right_point_path)
local right_closed_image = love.graphics.newImage(right_closed_path)

-- While hardware cursor uses "ImageData" object
local right_open_imagedata   = love.image.newImageData(right_open_path);
local right_point_imagedata  = love.image.newImageData(right_point_path);
local right_closed_imagedata = love.image.newImageData(right_closed_path);

local cursors = {
    open   = {
        image  = right_open_image,
        quad   = love.graphics.newQuad(0, 0, 32, 32, right_open_image),
        cursor = love.mouse.newCursor(right_open_imagedata, 15, 0)
    },

    point  = {
        image  = right_point_image,
        quad   = love.graphics.newQuad(0, 0, 32, 32, right_point_image),
        cursor = love.mouse.newCursor(right_point_imagedata, 15, 0)
    },

    closed = {
        image  = right_closed_image,
        quad   = love.graphics.newQuad(0, 0, 32, 32, right_closed_image),
        cursor = love.mouse.newCursor(right_closed_imagedata, 15, 0)
    }
}

return cursors