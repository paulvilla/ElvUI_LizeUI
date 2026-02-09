-- Locale.lua: utilidades de idioma y helpers de strings

local _, ns = ...

local E = ns.E
local LizeUI = ns.LizeUI

local function LT(key)
    local t = _G.LizeUI_L
    local v = (type(t) == 'table') and t[key] or nil
    return (type(v) == 'string' and v ~= '') and v or key
end

local function LTF(key, ...)
    local fmt = LT(key)
    if select('#', ...) == 0 then return fmt end
    return string.format(fmt, ...)
end

local function BuildActiveLocale(mode)
    local locales = _G.LizeUI_Locales
    if type(locales) ~= 'table' then
        return _G.LizeUI_L or {}
    end

    local en = locales.enUS
    local es = locales.esES

    -- Fallbacks if files are older / missing
    if type(en) ~= 'table' then
        en = _G.LizeUI_L or {}
    end

    local desired = mode
    if desired == nil or desired == 'auto' or desired == '' then
        local loc = (_G.GetLocale and _G.GetLocale()) or 'enUS'
        if loc == 'esES' or loc == 'esMX' then
            desired = 'esES'
        else
            desired = 'enUS'
        end
    end

    -- Build a fresh active table: start from enUS, then overlay esES when requested.
    local active = {}
    for k, v in pairs(en) do
        if type(k) == 'string' and type(v) == 'string' then
            active[k] = v
        end
    end

    if desired == 'esES' and type(es) == 'table' then
        for k, v in pairs(es) do
            if type(k) == 'string' and type(v) == 'string' then
                active[k] = v
            end
        end
    end

    return active
end

function LizeUI:ApplyLanguageMode(mode)
    _G.LizeUI_L = BuildActiveLocale(mode)
end

function LizeUI:RefreshOptionsUI()
    if not (E and E.Options and E.Options.args) then return end

    -- Rebuild the options table so the UI text matches the active locale.
    self:InsertOptions()

    local ACD = E.Libs and E.Libs.AceConfigDialog
    if ACD and type(ACD.Refresh) == 'function' then
        pcall(function() ACD:Refresh('ElvUI') end)
    end
end

function LizeUI:SetLanguageMode(mode)
    -- mode: nil/'auto' | 'enUS' | 'esES'
    LizeUIDB = LizeUIDB or {}
    LizeUIDB.languageMode = mode
    self:ApplyLanguageMode(mode)
    self:RefreshOptionsUI()
end

function LizeUI:GetLanguageMode()
    if type(LizeUIDB) == 'table' then
        return LizeUIDB.languageMode
    end
    return nil
end

ns.LT = LT
ns.LTF = LTF
