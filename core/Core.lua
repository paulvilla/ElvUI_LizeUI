-- Core.lua: orquestador principal (Initialize + features)

local _, ns = ...

local E = ns.E
local LizeUI = ns.LizeUI

local IsAddOnLoaded = ns.IsAddOnLoaded or _G.IsAddOnLoaded

-- Base de datos
LizeUIDB = LizeUIDB or { features = {} }

local function EnsureDefaults()
    LizeUIDB.features = LizeUIDB.features or {}
    if LizeUIDB.features.suppressRightClick == nil then LizeUIDB.features.suppressRightClick = true end
    if LizeUIDB.features.globalFadePersist == nil then LizeUIDB.features.globalFadePersist = true end
    if LizeUIDB.features.hidePetDemonBar == nil then LizeUIDB.features.hidePetDemonBar = true end
end

function LizeUI:ApplyFeature(key, enabled)
    if not self.Features then return end

    if key == 'suppressRightClick' then
        local f = self.Features.SuppressRightClick
        if f and f.SetEnabled then f:SetEnabled(enabled) end
    elseif key == 'globalFadePersist' then
        local f = self.Features.GlobalFadePersist
        if f and f.SetEnabled then f:SetEnabled(enabled) end
    elseif key == 'hidePetDemonBar' then
        local f = self.Features.HidePetDemonBar
        if f and f.SetEnabled then f:SetEnabled(enabled) end
    end
end

function LizeUI:EnableAll()
    EnsureDefaults()
    if not self.Features then return end

    self:ApplyFeature('suppressRightClick', LizeUIDB.features.suppressRightClick)
    self:ApplyFeature('globalFadePersist', LizeUIDB.features.globalFadePersist)
    self:ApplyFeature('hidePetDemonBar', LizeUIDB.features.hidePetDemonBar)
end

function LizeUI:DisableAll()
    if not self.Features then return end

    self:ApplyFeature('suppressRightClick', false)
    self:ApplyFeature('globalFadePersist', false)
    self:ApplyFeature('hidePetDemonBar', false)
end

function LizeUI:OptionsAddonLoaded(_, addon)
    if addon ~= 'ElvUI_Options' then return end
    self:InsertOptions()
    self:UnregisterEvent('ADDON_LOADED')
end

function LizeUI:Initialize()
    self:EnsureElvUIToggleOptions()
    EnsureDefaults()

    -- Ensure we always have a current locale table, even if the options UI is never opened.
    self:ApplyLanguageMode(self:GetLanguageMode())

    self:RegisterSlashCommands()

    if not self._lizeuiHooksDone then
        self._lizeuiHooksDone = true

        local ACD = E.Libs and E.Libs.AceConfigDialog
        if ACD and not ACD._LizeUI_Hooked then
            ACD._LizeUI_Hooked = true
            hooksecurefunc(ACD, 'Open', function(_, appName)
                if appName == 'ElvUI' then
                    C_Timer.After(0, function()
                        LizeUI:HideLegacyOptionsButton()
                        LizeUI:EnsureElvUIConfigTitleTagWithRetries()
                    end)
                end
            end)
        end
    end

    if IsAddOnLoaded and IsAddOnLoaded('ElvUI_Options') then
        self:InsertOptions()
    else
        self:RegisterEvent('ADDON_LOADED', 'OptionsAddonLoaded')
    end

    self:EnableAll()
end

E:RegisterModule(LizeUI:GetName())
