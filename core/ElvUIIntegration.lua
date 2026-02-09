-- ElvUIIntegration.lua: integración con opciones de ElvUI (ACD, title tag, plugins line)

local addonName, ns = ...

local E = ns.E
local LizeUI = ns.LizeUI
local LT = ns.LT
local LTF = ns.LTF
local GradientText = ns.GradientText

local ADDON_PATH = ns.ADDON_PATH
local LIZEUI_ICON_PATH = ns.LIZEUI_ICON_PATH

local function BuildPluginsLineText()
    local getMeta = C_AddOns and C_AddOns.GetAddOnMetadata
    local version = (type(getMeta) == 'function' and getMeta(addonName, 'Version')) or ''
    local author = (type(getMeta) == 'function' and getMeta(addonName, 'Author')) or ''

    return string.format(LT('CFG_LINE_FMT'), author, version)
end

local function InsertPluginsLine()
    if not (E and E.Options and E.Options.args) then return false end

    local plugins = E.Options.args.plugins or E.Options.args.Plugins
    if not (plugins and type(plugins) == 'table') then return false end

    plugins.args = plugins.args or {}

    -- Algunas versiones reconstruyen esta tabla; evitamos duplicados y limpiamos el bloque antiguo.
    if plugins.args.lizeuiInfo then
        plugins.args.lizeuiInfo = nil
    end

    local desiredKey = 'lizeuiLine'

    -- Orden: intentamos colocarlo justo después del header de LibElvUIPlugin si existe.
    local order = 20
    for _, v in pairs(plugins.args) do
        if type(v) == 'table' and (v.type == 'header' or v.type == 'description') then
            local n = v.name
            if type(n) == 'string' and string.find(n, 'LibElvUIPlugin', 1, true) then
                if type(v.order) == 'number' then
                    order = v.order + 1
                end
                break
            end
        end
    end

    plugins.args[desiredKey] = {
        order = order,
        type = 'description',
        fontSize = 'medium',
        name = BuildPluginsLineText,
    }

    return true
end

function LizeUI:EnsurePluginsLine()
    if InsertPluginsLine() then return end

    if not (_G.C_Timer and type(_G.C_Timer.After) == 'function') then return end

    local tries = 0
    local function Retry()
        tries = tries + 1
        if InsertPluginsLine() then return end
        if tries < 5 then
            _G.C_Timer.After(1, Retry)
        end
    end

    _G.C_Timer.After(1, Retry)
end

local function GetAddonDisplayNameAndVersion()
    local getMeta = C_AddOns and C_AddOns.GetAddOnMetadata

    local title = (type(getMeta) == 'function' and getMeta(addonName, 'Title')) or addonName or 'LizeUI'
    if type(title) ~= 'string' or title == '' then title = addonName or 'LizeUI' end

    -- Quitar códigos de color por si el Title los trae.
    title = title:gsub('|c%x%x%x%x%x%x%x%x', ''):gsub('|r', '')

    local version = (type(getMeta) == 'function' and getMeta(addonName, 'Version')) or ''
    if type(version) ~= 'string' or version == '' then version = '1.0.0' end

    return title, version
end

local function TryGetElvUIOptionsFrame()
    local frame
    if E and E.Config_GetWindow then
        frame = E:Config_GetWindow()
    end
    if not frame then
        local ACD = E and E.Libs and E.Libs.AceConfigDialog
        frame = ACD and ACD.OpenFrames and ACD.OpenFrames.ElvUI
    end
    -- AceConfigDialog a veces guarda un wrapper con .frame
    if frame and type(frame) == 'table' and frame.frame and type(frame.frame.GetChildren) == 'function' then
        return frame.frame
    end
    return frame
end

local function IsVersionTitleText(text)
    if type(text) ~= 'string' or text == '' then return false end
    return string.find(text, 'Versión', 1, true) or string.find(text, 'Version', 1, true)
end

local function FindTitleFontString(root)
    if not root then return nil end

    local maxFramesToScan = 250
    local scanned = 0

    local queue = { root }
    local seen = {}

    while #queue > 0 do
        local frame = table.remove(queue, 1)
        if frame and not seen[frame] then
            seen[frame] = true
            scanned = scanned + 1
            if scanned > maxFramesToScan then break end

            if type(frame.GetRegions) == 'function' then
                local regions = { frame:GetRegions() }
                for _, r in ipairs(regions) do
                    if r and type(r.GetObjectType) == 'function' and r:GetObjectType() == 'FontString' then
                        local text = (type(r.GetText) == 'function' and r:GetText()) or nil
                        if IsVersionTitleText(text) then
                            return r
                        end
                    end
                end
            end

            if type(frame.GetChildren) == 'function' then
                local children = { frame:GetChildren() }
                for _, c in ipairs(children) do
                    if c and not seen[c] then
                        queue[#queue + 1] = c
                    end
                end
            end
        end
    end

    return nil
end

local function InjectLizeUITagIntoTitle(titleText)
    if type(titleText) ~= 'string' or titleText == '' then return titleText end

    local name, version = GetAddonDisplayNameAndVersion()

    local iconTag = '|T' .. LIZEUI_ICON_PATH .. ':14:14:0:0|t'

    -- Evitar duplicados aunque el nombre tenga colores/gradiente.
    if string.find(titleText, name, 1, true) and string.find(titleText, version, 1, true) then
        return titleText
    end

    -- Si ya está el icono embebido (o la ruta), no reinserta.
    if string.find(titleText, LIZEUI_ICON_PATH, 1, true) or string.find(titleText, iconTag, 1, true) then
        return titleText
    end

    -- Degradado del nombre: azul -> violeta (izquierda a derecha)
    local coloredName = GradientText(name, 0, 192, 250, 130, 85, 255)
    local tag = ('+ %s %s %s'):format(iconTag, coloredName, version)

    if string.find(titleText, tag, 1, true) then
        return titleText
    end

    -- El usuario quiere que LizeUI vaya al final (después de WindTools si existe).
    return titleText .. ' ' .. tag
end

function LizeUI:EnsureElvUIConfigTitleTag()
    local frame = TryGetElvUIOptionsFrame()
    if not frame then return end

    local titleFS = (frame.title and type(frame.title.SetText) == 'function' and frame.title)
        or (frame.TitleText and type(frame.TitleText.SetText) == 'function' and frame.TitleText)
        or (frame.titleText and type(frame.titleText.SetText) == 'function' and frame.titleText)
        or FindTitleFontString(frame)

    if not titleFS then return end

    local old = (type(titleFS.GetText) == 'function' and titleFS:GetText()) or ''
    local newText = InjectLizeUITagIntoTitle(old)
    if newText and newText ~= old then
        titleFS:SetText(newText)
    end
end

function LizeUI:EnsureElvUIConfigTitleTagWithRetries()
    self:EnsureElvUIConfigTitleTag()

    if not (_G.C_Timer and type(_G.C_Timer.After) == 'function') then return end

    local tries = 0
    local function Retry()
        tries = tries + 1
        self:EnsureElvUIConfigTitleTag()
        if tries < 20 then
            _G.C_Timer.After(0.5, Retry)
        end
    end

    _G.C_Timer.After(0.5, Retry)
end

function LizeUI:HideLegacyOptionsButton()
    -- Por si quedó un botón viejo creado por versiones anteriores
    local frame
    if E.Config_GetWindow then
        frame = E:Config_GetWindow()
    end

    if not frame then
        local ACD = E.Libs and E.Libs.AceConfigDialog
        frame = ACD and ACD.OpenFrames and ACD.OpenFrames.ElvUI
    end

    if frame and frame.bottomHolder and frame.bottomHolder.LizeUI_Button then
        frame.bottomHolder.LizeUI_Button:Hide()
    end
end

function LizeUI:EnsureElvUIToggleOptions()
    if type(E.ToggleOptions) == 'function' then return end

    local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
    local EnableAddOn = C_AddOns.EnableAddOn
    local LoadAddOn = C_AddOns.LoadAddOn
    local GetAddOnInfo = C_AddOns.GetAddOnInfo

    function E:ToggleOptions(msg)
        if self.AlertCombat and self:AlertCombat() then
            self.ShowOptions = true
            return
        end

        if not IsAddOnLoaded('ElvUI_Options') then
            local _, _, _, _, reason = GetAddOnInfo('ElvUI_Options')
            if reason == 'MISSING' then
                if self.Print then
                    self:Print('|cffff0000Error|r -- Addon "ElvUI_Options" not found.')
                end
                return
            end

            EnableAddOn('ElvUI_Options', self.myguid)
            LoadAddOn('ElvUI_Options')

            if LizeUI and LizeUI.InsertOptions then
                LizeUI:InsertOptions()
            end
        end

        local ACD = self.Libs and self.Libs.AceConfigDialog
        if not ACD then return end

        local openFrames = ACD.OpenFrames
        local isOpen = openFrames and openFrames.ElvUI

        if isOpen and ACD.Close then
            ACD:Close('ElvUI')
        elseif ACD.Open then
            ACD:Open('ElvUI')
        end

        if msg and msg ~= '' and ACD.SelectGroup then
            local a, b, c, d = strsplit(',', msg)
            if a and b and c and d then
                ACD:SelectGroup('ElvUI', a, b, c, d)
            elseif a and b and c then
                ACD:SelectGroup('ElvUI', a, b, c)
            elseif a and b then
                ACD:SelectGroup('ElvUI', a, b)
            elseif a then
                ACD:SelectGroup('ElvUI', a)
            end
        end
    end
end
