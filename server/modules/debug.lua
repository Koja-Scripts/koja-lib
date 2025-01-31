KOJA.Server.Print = function(level, debug, ...)
    local printLevel = {
        success = 1,
        error = 2,
        warn = 3,
        info = 4,
        debug = 5,
    }

    local levelPrefixes = {
        [1] = '^2[SUCCESS]',
        [2] = '^1[ERROR]',
        [3] = '^3[WARN]',
        [4] = '^4[INFO]',
        [5] = '^6[DEBUG]'
    }

    local function handleException(reason, value)
        if type(value) == 'function' then return tostring(value) end
        return reason
    end

    local jsonOptions = { sort_keys = true, indent = true, exception = handleException }

    if not printLevel[level] then
        level = 'info'
    end

    if KOJA.Debug or not debug then
        local args = { ... }

        for i = 1, #args do
            local arg = args[i]
            args[i] = type(arg) == 'table' and json.encode(arg, jsonOptions) or tostring(arg)
        end

        print(levelPrefixes[printLevel[level]],'^7', table.concat(args, '\t'))
    end
end