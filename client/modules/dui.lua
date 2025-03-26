---@class DuiInstance
---@field id string
---@field url string
---@field handle long
---@field txd string
---@field txn string
KOJA.Client.DuiInstance = KOJA.Client.DuiInstance or {}
KOJA.Client.DuiInstance.__index = KOJA.Client.DuiInstance

local currentId = 0
local duis = {}

KOJA.Client.DuiInstance.new = function(handle, duiHandle, txd, txn, id, url)
    local self = setmetatable({}, KOJA.Client.DuiInstance)
    self.id = id
    self.handle = handle
    self.duiHandle = duiHandle
    self.txd = txd
    self.txn = txn
    self.url = url

    if Config.Debug then
        print(('[KOJA] DuiInstance %s created with URL: %s'):format(self.id, self.url))
    end

    self.setUrl = function(self, newUrl)
        self.url = newUrl
        SetDuiUrl(self.handle, newUrl)
    end

    self.sendMessage = function(self, message)
        SendDuiMessage(self.handle, json.encode(message))
        if Config.Debug then
            print(('[KOJA-LIB] DuiInstance %s message sent with data: %s'):format(self.id, message))
        end
    end

    self.getHandle = function(self)
        return self.handle
    end

    self.getTextureDict = function(self)
        return self.txd
    end

    self.getTextureName = function(self)
        return self.txn
    end

    self.replaceTexture = function(self, originalTxd, originalTxn)
        AddReplaceTexture(originalTxd, originalTxn, self.txd, self.txn)
    end

    self.removeReplaceTexture = function(self, originalTxd, originalTxn)
        RemoveReplaceTexture(originalTxd, originalTxn)
    end

    self.destroy = function(self)
        SetDuiUrl(self.handle, "about:blank")
        DestroyDui(self.handle)

        if Config.Debug then
            print(('[KOJA-LIB] DuiInstance %s destroyed'):format(self.id))
        end

        duis[self.id] = nil
    end

    return self
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

    local instance = KOJA.Client.DuiInstance.new(handle, duiObj, dictName, txtName, id, url)
    duis[id] = instance

    return instance
end
