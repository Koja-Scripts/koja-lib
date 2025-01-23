exports("sendNotify", function(data)
    Koja.Client.SendNotify({
        type = data.type,
        icon = data.icon,
        color = data.color,
        title = data.title,
        desc = data.desc,
        time = 5000
    })
end)
