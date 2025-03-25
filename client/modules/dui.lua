---@class DuiInstance
---@field handle long
---@field txd string
---@field txn string
local DuiInstance = {}
DuiInstance.__index = DuiInstance

DuiInstance.new = function(handle, txd, txn)
    local self = setmetatable({}, DuiInstance)
    self.handle = handle
    self.txd = txd
    self.txn = txn
    return self
end

DuiInstance.getHandle = function(self)
    return self.handle
end

DuiInstance.getTextureDict = function(self)
    return self.txd
end

DuiInstance.getTextureName = function(self)
    return self.txn
end

DuiInstance.replaceTexture = function(self, originalTxd, originalTxn)
    AddReplaceTexture(originalTxd, originalTxn, self.txd, self.txn)
end

DuiInstance.removeReplaceTexture = function(self, originalTxd, originalTxn)
    RemoveReplaceTexture(originalTxd, originalTxn)
end

DuiInstance.setUrl = function(self, newUrl)
    SetDuiUrl(self.handle, newUrl)
end

DuiInstance.destroy = function(self)
    SetDuiUrl(self.handle, "about:blank")
    DestroyDui(self.handle)
end

--- @param opts { url: string, width?: number, height?: number, debugName?: string }
--- @return DuiInstance
KOJA.Client.CreateDui = function(opts)
    local url = opts.url
    local width = opts.width or 1280
    local height = opts.height or 720
    local debugName = opts.debugName or ("dui_" .. GetGameTimer())

    local handle = CreateDui(url, width, height)
    local duiObj = GetDuiHandle(handle)

    local txd = CreateRuntimeTxd(debugName)
    local txn = "duiTex"

    CreateRuntimeTextureFromDuiHandle(txd, txn, duiObj)

    return DuiInstance.new(handle, txd, txn)
end

-- CreateThread(function()
--     local pos = vector3(-66.6088, -1744.0963, 29.3141)

--     local dui = KOJA.Client.CreateDui({
--         url = "https://http.cat/404",
--         width = 512,
--         height = 512,
--         debugName = "dui_stable_ui"
--     })

--     local txd = dui:getTextureDict()
--     local txn = dui:getTextureName()

--     while true do
--         Wait(0)

--         local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)

--         if onScreen then
--             local resX, resY = GetActiveScreenResolution()

--             local width = 50 / resX
--             local height = 50 / resY
--             DrawSprite(
--                 txd,
--                 txn,
--                 screenX,
--                 screenY,
--                 width,
--                 height,
--                 0.0,
--                 255, 255, 255, 255
--             )
--         end
--     end
-- end)




