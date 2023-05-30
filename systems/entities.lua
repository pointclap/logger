local entities = {}

local function dump()
    local function recursive(tbl)
        local s = ""
        for k, v in pairs(tbl) do
            if type(k) == "string" then
                s = s .. "\"" .. k .. "\": "
            else
                s = s .. k .. ": "
            end

            if type(v) == "table" then
                s = s .. " {"
                s = s .. recursive(v)
                s = s .. "}"
            elseif type(v) == "string" then
                s = s .. "\"" .. v .. "\""
            else
                s = s .. tostring(v)
            end
        end
        return s
    end

    log.trace(recursive(entities))
end

local function players()
    return function(entities, k)
        local v
        repeat
            k, v = next(entities, k)
        until k == nil or v.username
        return k, v
    end, entities, nil
end

local function all()
    return pairs(entities)
end

local function get(id)
    return entities[id]
end

return {
    get = get,
    all = all,
    players = players,
    entities = entities,
    dump = dump
}
