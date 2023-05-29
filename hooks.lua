local hooks = {}

local function add(name, func)
    if not hooks[name] then
        hooks[name] = {}
    end

    table.insert(hooks[name], func)
end

local function call(hook, ...)
    if hooks[hook] then
        for _, hook in pairs(hooks[hook]) do
            hook(...)
        end
    end
end

return {
    add = add,
    call = call
}