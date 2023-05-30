local log_levels = {
    trace = 1,
    debug = 2,
    info = 3,
    warn = 4,
    error = 5
}

local log_level_names = {"trace", "debug", "info", "warn", "error"}
local current_log_level = log_levels.debug

local original_print = print
local function log(level, ...)
    local caller = debug.getinfo(3);

    if current_log_level <= level then
        local now_date_time = os.date("!%Y-%m-%dT%H-%M-%S")
        original_print(log_level_names[level], now_date_time .. " " .. caller.short_src .. ":" .. caller.currentline ..
            ": " .. table.concat({...}, " "))
    end
end

-- override print, making it equivalent to log.info
print = function(...)
    log(log_levels.info, ...)
end

return {
    trace = function(...)
        log(log_levels.trace, ...)
    end,
    debug = function(...)
        log(log_levels.debug, ...)
    end,
    info = function(...)
        log(log_levels.info, ...)
    end,
    warn = function(...)
        log(log_levels.warn, ...)
    end,
    error = function(...)
        log(log_levels.error, ...)
    end
}
