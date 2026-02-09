-- Core.lua: orquestador principal (Initialize + features)

local _, ns = ...

local E = ns.E
local LizeUI = ns.LizeUI
local LT = ns.LT
local LTF = ns.LTF
local PrintMsg = ns.PrintMsg

local IsAddOnLoaded = ns.IsAddOnLoaded or _G.IsAddOnLoaded

-- Base de datos
LizeUIDB = LizeUIDB or { features = {} }

local function EnsureDefaults()
    LizeUIDB.features = LizeUIDB.features or {}
    if LizeUIDB.features.suppressRightClick == nil then LizeUIDB.features.suppressRightClick = true end
    if LizeUIDB.features.globalFadePersist == nil then LizeUIDB.features.globalFadePersist = true end
    if LizeUIDB.features.hidePetDemonBar == nil then LizeUIDB.features.hidePetDemonBar = true end
    if LizeUIDB.features.disableFriendlyNPCHealthBars == nil then LizeUIDB.features.disableFriendlyNPCHealthBars = false end

    if LizeUIDB.requiredAddonsPromptAccepted == nil then
        LizeUIDB.requiredAddonsPromptAccepted = false
    end
end

function LizeUI:SuppressElvUIInstallerOnFirstRun()
    if type(LizeUIDB) ~= 'table' then return end

    if type(self.IsInstallerCompletedForChar) == 'function' and self:IsInstallerCompletedForChar() then
        return
    end

    if type(E) ~= 'table' or type(E.private) ~= 'table' then return end

    -- Solo en instalaciones nuevas (si el usuario está actualizando ElvUI, no interferimos).
    if E.private.install_complete == nil or E.private.install_complete == 0 then
        if E.version ~= nil then
            E.private.install_complete = E.version
        else
            -- Fallback: cualquier valor truthy evita el check típico en builds antiguas.
            E.private.install_complete = true
        end
    end

    -- Por si el frame se crea/enseña antes o después, lo ocultamos.
    local f = _G.ElvUIInstallFrame or E.InstallFrame
    if f and f.Hide then
        pcall(f.Hide, f)
    end
end

local function NormalizeEnableState(state)
    if type(state) == 'number' then return state end
    if type(state) == 'boolean' then return state and 1 or 0 end
    if type(state) == 'string' then return tonumber(state) end
    return nil
end

local function GetAddOnEnableStateSafe(addonFolder)
    local char = (_G.UnitName and _G.UnitName('player')) or nil

    -- Retail moderno: C_AddOns.GetAddOnEnableState(addonName, characterName)
    local getStateC = C_AddOns and C_AddOns.GetAddOnEnableState
    if type(getStateC) == 'function' then
        local ok, state = pcall(getStateC, addonFolder, char)
        local n = ok and NormalizeEnableState(state) or nil
        if n ~= nil then return n end

        ok, state = pcall(getStateC, addonFolder, nil)
        n = ok and NormalizeEnableState(state) or nil
        if n ~= nil then return n end

        ok, state = pcall(getStateC, addonFolder)
        n = ok and NormalizeEnableState(state) or nil
        if n ~= nil then return n end
    end

    -- API legacy: GetAddOnEnableState(characterName, addonName)
    local getStateG = _G.GetAddOnEnableState
    if type(getStateG) == 'function' then
        local ok, state = pcall(getStateG, char, addonFolder)
        local n = ok and NormalizeEnableState(state) or nil
        if n ~= nil then return n end

        ok, state = pcall(getStateG, nil, addonFolder)
        n = ok and NormalizeEnableState(state) or nil
        if n ~= nil then return n end
    end

    return nil
end

local function IsAddOnLoadedSafe(addonFolder)
    local isLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or _G.IsAddOnLoaded
    if type(isLoaded) ~= 'function' then return nil end

    local ok, loaded = pcall(isLoaded, addonFolder)
    if not ok then return nil end

    if type(loaded) == 'boolean' then return loaded end
    if type(loaded) == 'number' then return loaded ~= 0 end
    return loaded and true or false
end

local function GetAddonStatus(addonFolder)
    local getInfo = (C_AddOns and C_AddOns.GetAddOnInfo) or _G.GetAddOnInfo
    if type(getInfo) ~= 'function' then
        return nil
    end

    local ok, r1, r2, r3, r4, r5 = pcall(getInfo, addonFolder)
    if not ok then return nil end

    local name, loadable, reason
    if type(r1) == 'table' then
        local t = r1
        name = t.name or t.Name or addonFolder
        loadable = t.loadable
        reason = t.reason
    else
        name = r1
        loadable = r4
        reason = r5
    end

    if reason == 'MISSING' or type(name) ~= 'string' or name == '' then
        return 'missing'
    end

    -- Enable state (instalado pero desactivado vs activado)
    local state = GetAddOnEnableStateSafe(addonFolder)
    if state ~= nil then
        if state > 0 then return 'ok' end
        return 'inactive'
    end

    -- Si está cargado, OK.
    local loaded = IsAddOnLoadedSafe(addonFolder)
    if loaded == true then return 'ok' end

    if reason == 'DISABLED' then
        return 'inactive'
    end

    if loadable == true then
        return 'ok'
    end

    return 'inactive'
end

function LizeUI:MaybePromptImportantAddons()
    -- Popup legacy eliminado a petición: ya no se usa.
    return
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
    elseif key == 'disableFriendlyNPCHealthBars' then
        local f = self.Features.DisableFriendlyNPCHealthBars
        if f and f.SetEnabled then f:SetEnabled(enabled) end
    end
end

function LizeUI:EnableAll()
    EnsureDefaults()
    if not self.Features then return end

    self:ApplyFeature('suppressRightClick', LizeUIDB.features.suppressRightClick)
    self:ApplyFeature('globalFadePersist', LizeUIDB.features.globalFadePersist)
    self:ApplyFeature('hidePetDemonBar', LizeUIDB.features.hidePetDemonBar)
    self:ApplyFeature('disableFriendlyNPCHealthBars', LizeUIDB.features.disableFriendlyNPCHealthBars)
end

function LizeUI:DisableAll()
    if not self.Features then return end

    self:ApplyFeature('suppressRightClick', false)
    self:ApplyFeature('globalFadePersist', false)
    self:ApplyFeature('hidePetDemonBar', false)
    self:ApplyFeature('disableFriendlyNPCHealthBars', false)
end

function LizeUI:OptionsAddonLoaded(_, addon)
    if addon ~= 'ElvUI_Options' then return end
    self:InsertOptions()
    self:UnregisterEvent('ADDON_LOADED')
end

function LizeUI:Initialize()
    self:EnsureElvUIToggleOptions()
    EnsureDefaults()

    -- En primera entrada, evita que salga el instalador de ElvUI.
    self:SuppressElvUIInstallerOnFirstRun()

    if _G.C_Timer and type(_G.C_Timer.After) == 'function' then
        _G.C_Timer.After(0, function()
            if LizeUI and LizeUI.SuppressElvUIInstallerOnFirstRun then
                LizeUI:SuppressElvUIInstallerOnFirstRun()
            end
        end)
    end

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

    if _G.C_Timer and type(_G.C_Timer.After) == 'function' then
        _G.C_Timer.After(3, function()
            if LizeUI and LizeUI.ShowInstallWindow then
                LizeUI:ShowInstallWindow(false)
            end
        end)
    else
        self:ShowInstallWindow(false)
    end

    self:EnableAll()
end

E:RegisterModule(LizeUI:GetName())
