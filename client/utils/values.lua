KOJA.Client.percent = function(value, max)
    if not max or max == 0 then
        return 0
    end
    local percentage = (value * 100) / max
    return percentage > 100 and 100 or percentage < 0 and 0 or percentage
end

KOJA.Client.MathRound = function(num)
    return num % 1 >= 0.5 and math.ceil(num) or math.floor(num)
end