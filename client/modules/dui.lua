---@class DuiInstance
---@field id string
---@field url string
---@field handle long
---@field txd string
---@field txn string
local DuiInstance = {}
DuiInstance.__index = DuiInstance

local currentId = 0
local duis = {}

DuiInstance.new = function(handle, duiHandle, txd, txn, id, url)
    local self = setmetatable({}, DuiInstance)
    self.id = id
    self.handle = handle
    self.duiHandle = duiHandle
    self.txd = txd
    self.txn = txn
    self.url = url

    if Config.Debug then
        print(('[KOJA] DuiInstance %s created with URL: %s'):format(self.id, self.url))
    end

    return self
end

function DuiInstance:getHandle()
    return self.handle
end

function DuiInstance:getTextureDict()
    return self.txd
end

function DuiInstance:getTextureName()
    return self.txn
end

function DuiInstance:replaceTexture(originalTxd, originalTxn)
    AddReplaceTexture(originalTxd, originalTxn, self.txd, self.txn)
end

function DuiInstance:removeReplaceTexture(originalTxd, originalTxn)
    RemoveReplaceTexture(originalTxd, originalTxn)
end

function DuiInstance:setUrl(newUrl)
    self.url = newUrl
    SetDuiUrl(self.handle, newUrl)
end

function DuiInstance:destroy()
    SetDuiUrl(self.handle, "about:blank")
    DestroyDui(self.handle)

    if Config.Debug then
        print(('[KOJA] DuiInstance %s destroyed'):format(self.id))
    end

    duis[self.id] = nil
end

function DuiInstance:sendMessage(message)
    SendDuiMessage(self.handle, json.encode(message))
    if Config.Debug then
        print("Dui "..self.id.." message sent with data: ", json.encode(message))
    end
end

--- @param opts { url: string, width?: number, height?: number}
--- @return DuiInstance

KOJA.Client.CreateDui = function(opts)
    local url = opts.url
    local width = opts.width or 1280
    local height = opts.height or 720

    local time = GetGameTimer()
    local id = ("koja_dui_%s_%s"):format(time, currentId)
    currentId = currentId + 1

    local dictName = ("koja_dui_dict_%s"):format(id)
    local txtName = ("koja_dui_txt_%s"):format(id)

    local handle = CreateDui(url, width, height)
    local duiObj = GetDuiHandle(handle)

    local txd = CreateRuntimeTxd(dictName)
    CreateRuntimeTextureFromDuiHandle(txd, txtName, duiObj)

    local instance = DuiInstance.new(handle, duiObj, dictName, txtName, id, url)
    duis[id] = instance

    return instance
end

-- local thisResource = GetCurrentResourceName()
-- local url = ("nui://%s/html/index.html"):format(thisResource)

-- CreateThread(function()
--     local testcoords = vector3(-66.6088, -1744.0963, 29.3141)

--     local width, height = GetActiveScreenResolution()

--     local dui = KOJA.Client.CreateDui({
--         url = url,
--         width = width,
--         height = height
--     })

--     dui:setUrl(url)

--     local txd, txn = dui.txd, dui.txn

--     dui:sendMessage({
--         type = "toggle-triangle",
--         display = true
--     })

--     while true do
--         Wait(0)
--         SetDrawOrigin(testcoords.x, testcoords.y, testcoords.z, 0)
--         DrawSprite(txd, txn, 0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
--         ClearDrawOrigin()
--     end
-- end)

