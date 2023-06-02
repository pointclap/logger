local function magnitude(x, y)
    return math.sqrt((x*x)+(y*y))
end

local function normalise(x, y)
    local m = magnitude(x, y)
    return x / m, y / m
end

local function dot(x1, y1, x2, y2)
    return (x1 * x2) + (y1 * y2)
end

local function distance(x1, y1, x2, y2)
    return math.sqrt(((x2 - x1)^2 + (y2 - y1)^2))
end

return {
    magnitude = function(...)
        return magnitude(...)
    end,

    normalise = function(...)
        return normalise(...)
    end,

    dot = function(...)
        return dot(...)
    end,

    distance = function(...)
        return distance(...)
    end
}