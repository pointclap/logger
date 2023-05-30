local hooks = {}

local function add(name, func)
    if not hooks[name] then
        hooks[name] = {}
    end

    local caller = debug.getinfo(2);
    table.insert(hooks[name], {
        definition = caller,
        func = func
    })
end

local function call(hook_name, ...)
    if hooks[hook_name] then
        for _, hook in pairs(hooks[hook_name]) do
            log.trace("calling hook \"" .. hook_name .. "\" in " .. hook.definition.short_src .. ":" .. hook.definition.currentline )
            hook.func(...)
        end
    end
end

return {
    add = add,
    call = call
}