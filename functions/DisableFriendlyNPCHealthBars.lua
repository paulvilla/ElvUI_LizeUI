local E = unpack(ElvUI)
local LizeUI = E:GetModule('LizeUI')

LizeUI.Features = LizeUI.Features or {}

local feature = LizeUI.Features.DisableFriendlyNPCHealthBars or {}
LizeUI.Features.DisableFriendlyNPCHealthBars = feature

local enabled = false
local hooked = false
local pending = false

local CVAR_NAMES = {
    -- Main toggle in Blizzard UI for friendly NPC nameplates
    'nameplateShowFriendlyNPCs',
    -- Related friendly nameplate categories that can get toggled by client bugs/addons
    'nameplateShowFriendlyPets',
    'nameplateShowFriendlyGuardians',
    'nameplateShowFriendlyTotems',
    'nameplateShowFriendlyMinions',
}

local CVAR_LOOKUP = {}
for i = 1, #CVAR_NAMES do
    CVAR_LOOKUP[CVAR_NAMES[i]] = true
end

local function SetCVarSafe(name, value)
    local setC = _G.C_CVar and _G.C_CVar.SetCVar
    local getC = _G.C_CVar and _G.C_CVar.GetCVar
    local setG = _G.SetCVar
    local getG = _G.GetCVar

    local getter = (type(getC) == 'function') and getC or ((type(getG) == 'function') and getG or nil)
    local setter = (type(setC) == 'function') and setC or ((type(setG) == 'function') and setG or nil)

    if type(setter) ~= 'function' then return false end

    local ok, cur = true, nil
    if type(getter) == 'function' then
        ok, cur = pcall(getter, name)
        if not ok then cur = nil end
    end

    if cur ~= nil and tostring(cur) == tostring(value) then
        return true
    end

    local ok2 = pcall(setter, name, tostring(value))
    return ok2 and true or false
end

local function Apply()
    if not enabled then return end

    if type(_G.InCombatLockdown) == 'function' and _G.InCombatLockdown() then
        pending = true
        return
    end

    pending = false

    -- Retail: friendly NPC nameplates.
    -- If the CVar is missing on a given client, SetCVar will fail and we keep going.
    for i = 1, #CVAR_NAMES do
        SetCVarSafe(CVAR_NAMES[i], 0)
    end
end

local function ApplyWithDelay()
    Apply()

    if enabled and _G.C_Timer and type(_G.C_Timer.After) == 'function' then
        _G.C_Timer.After(0.5, function()
            if enabled then
                Apply()
            end
        end)
    end
end

local function EnsureHook()
    if hooked then return end
    hooked = true

    local f = CreateFrame('Frame')
    f:RegisterEvent('PLAYER_ENTERING_WORLD')
    f:RegisterEvent('ZONE_CHANGED_NEW_AREA')
    f:RegisterEvent('PLAYER_REGEN_ENABLED')
    f:RegisterEvent('CVAR_UPDATE')
    f:SetScript('OnEvent', function(_, event, ...)
        if event == 'PLAYER_REGEN_ENABLED' then
            if pending then
                Apply()
            end
            return
        end

        if event == 'CVAR_UPDATE' then
            local cvarName = ...
            if type(cvarName) ~= 'string' or not CVAR_LOOKUP[cvarName] then return end
        end

        if event == 'PLAYER_ENTERING_WORLD' or event == 'ZONE_CHANGED_NEW_AREA' then
            ApplyWithDelay()
        else
            Apply()
        end
    end)
end

function feature:SetEnabled(state)
    enabled = (state == true)
    EnsureHook()

    if enabled then
        Apply()
    else
        pending = false
    end
end
