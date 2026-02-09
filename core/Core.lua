-- Core.lua para LizeUI, complemento de ElvUI

local addonName = ...

local E, L, V, P, G = unpack(ElvUI)
local LizeUI = E:NewModule('LizeUI', 'AceHook-3.0', 'AceEvent-3.0')
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local LIZEUI_ICON_PATH = 'Interface\\AddOns\\LizeUI\\media\\textures\\icons\\lizeui.tga'

local function PrintMsg(msg)
    if E and E.Print then
        E:Print(msg)
    else
        print(msg)
    end
end

-- Addon Compartment (Dragonflight+): handler global declarado en el .toc.
-- Nota: la firma del handler cambió en 11.0; aceptamos varargs para compatibilidad.
if type(_G.LizeUI_OnAddonCompartmentClick) ~= 'function' then
    _G.LizeUI_OnAddonCompartmentClick = function(_addonNameFromMetadata, _buttonName, ...)
        if LizeUI and type(LizeUI.EnsureElvUIToggleOptions) == 'function' then
            LizeUI:EnsureElvUIToggleOptions()
        end

        if E and type(E.ToggleOptions) == 'function' then
            E:ToggleOptions(addonName)
            return
        end

        -- Fallback extremo: intenta abrir via slash handler si existe.
        local slash = _G.SlashCmdList and _G.SlashCmdList.ELVUI
        if type(slash) == 'function' then
            slash(addonName)
        end
    end
end

local function GetLSM()
    local libStub = _G.LibStub
    if type(libStub) ~= 'table' and type(libStub) ~= 'function' then return nil end

    -- LibStub normalmente es una tabla con __call, así que type(LibStub) == 'table'.
    local ok, lib = pcall(function()
        if type(libStub) == 'table' and type(libStub.GetLibrary) == 'function' then
            return libStub:GetLibrary('LibSharedMedia-3.0', true)
        end
        return libStub('LibSharedMedia-3.0', true)
    end)

    if not ok then return nil end
    return lib
end

local function BuildLSMResourceList(mediaType, requiredPathNeedle)
    local LSM = GetLSM()
    if not (LSM and type(LSM.List) == 'function' and type(LSM.Fetch) == 'function') then
        return '- (LibSharedMedia-3.0 no disponible)'
    end

    local names = LSM:List(mediaType)
    if type(names) ~= 'table' then
        return '- (sin datos)'
    end

    local filtered = {}
    for _, name in ipairs(names) do
        local path = LSM:Fetch(mediaType, name, true)
        if type(path) == 'string' and path ~= '' and string.find(path, requiredPathNeedle, 1, true) then
            filtered[#filtered + 1] = name
        end
    end

    if #filtered == 0 then
        return '- (no hay elementos registrados)'
    end

    table.sort(filtered)

    return table.concat(filtered, ', ')
end

local function BuildPluginsLineText()
    local getMeta = C_AddOns and C_AddOns.GetAddOnMetadata
    local version = (type(getMeta) == 'function' and getMeta(addonName, 'Version')) or ''
    local author = (type(getMeta) == 'function' and getMeta(addonName, 'Author')) or ''
    if version == '' then version = '1.0.0' end
    if author == '' then author = 'Lizerius' end

    return ('|cff00c0faLizeUI|r |cffaaaaaaby|r |cff00ff00%s|r - |cffaaaaaaVersión:|r |cff00ff00%s|r'):format(author, version)
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

local function GradientText(text, r1, g1, b1, r2, g2, b2)
    if type(text) ~= 'string' or text == '' then return '' end

    local len = #text
    if len == 1 then
        return string.format('|cff%02x%02x%02x%s|r', r1, g1, b1, text)
    end

    local out = {}
    for i = 1, len do
        local ch = string.sub(text, i, i)
        if ch == ' ' then
            out[#out + 1] = ch
        else
            local t = (i - 1) / (len - 1)
            local r = math.floor((r1 + (r2 - r1) * t) + 0.5)
            local g = math.floor((g1 + (g2 - g1) * t) + 0.5)
            local b = math.floor((b1 + (b2 - b1) * t) + 0.5)
            out[#out + 1] = string.format('|cff%02x%02x%02x%s|r', r, g, b, ch)
        end
    end

    return table.concat(out)
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

    -- Degradado del nombre: azul -> morado (izquierda a derecha)
    local coloredName = GradientText(name, 0, 192, 250, 163, 53, 238)
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

local function EnsurePluginsLine()
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

local function GetImportBlock(key)
    local t = _G.LizeUI_Imports
    if type(t) ~= 'table' then return nil end
    local block = t[key]
    if type(block) ~= 'table' then return nil end
    return block
end

local function HasImportString(block)
    return block and type(block.data) == 'string' and block.data ~= ''
end

local function Import_ElvUI(key, label)
    key = (type(key) == 'string' and key ~= '') and key or 'elvui'
    label = (type(label) == 'string' and label ~= '') and label or 'ElvUI'

    local block = GetImportBlock(key)
    if not HasImportString(block) then
        PrintMsg(('LizeUI: Falta el string de import de %s (%s) en LizeUI/imports/Imports.lua'):format(label, key))
        return
    end

    if not (E and E.GetModule) then
        PrintMsg('LizeUI: ElvUI no está disponible para importar.')
        return
    end

    local D = E:GetModule('Distributor', true)
    if not (D and D.ImportProfile) then
        PrintMsg('LizeUI: No se encontró el módulo Distributor de ElvUI.')
        return
    end

    local ok, err = pcall(function() D:ImportProfile(block.data) end)
    if ok then
        PrintMsg(('LizeUI: Perfil importado en %s.'):format(label))
    else
        PrintMsg(('LizeUI: Error importando en %s: %s'):format(label, tostring(err)))
    end
end

local function Import_WindTools()
    local block = GetImportBlock('windtools')
    if not HasImportString(block) then
        PrintMsg('LizeUI: Falta el string de import de WindTools en LizeUI/imports/Imports.lua')
        return
    end

    local wt = _G.WindTools
    if type(wt) ~= 'table' then
        PrintMsg('LizeUI: WindTools no está cargado.')
        return
    end

    local W, F = unpack(wt)
    if not (F and F.Profiles and F.Profiles.ImportByString) then
        PrintMsg('LizeUI: No se encontró F.Profiles.ImportByString (WindTools).')
        return
    end

    local ok, err = pcall(function() F.Profiles.ImportByString(block.data) end)
    if ok then
        PrintMsg('LizeUI: Perfil importado en WindTools. Recargando interfaz...')

        if type(_G.ReloadUI) == 'function' then
            if _G.C_Timer and type(_G.C_Timer.After) == 'function' then
                _G.C_Timer.After(0.75, function() _G.ReloadUI() end)
            else
                _G.ReloadUI()
            end
        end
    else
        PrintMsg('LizeUI: Error importando en WindTools: ' .. tostring(err))
    end
end

local function Import_Plater()
    local block = GetImportBlock('plater')
    if not HasImportString(block) then
        PrintMsg('LizeUI: Falta el string de import de Plater en LizeUI/imports/Imports.lua')
        return
    end

    local plater = _G.Plater
    if not (plater and plater.ImportAndSwitchProfile) then
        PrintMsg('LizeUI: Plater no está cargado o no expone ImportAndSwitchProfile.')
        return
    end

    local profileName = (type(block.profileName) == 'string' and block.profileName ~= '') and block.profileName or 'LizeUI'

    local ok, err = pcall(function()
        plater.ImportAndSwitchProfile(profileName, block.data, false, false, true)
    end)

    if ok then
        PrintMsg('LizeUI: Perfil importado en Plater (sin /reload automático). Si algo no aplica, usa /reload.')
    else
        PrintMsg('LizeUI: Error importando en Plater: ' .. tostring(err))
    end
end

local function Import_BetterCooldownManager()
    local block = GetImportBlock('betterCooldownManager')
    if not HasImportString(block) then
        PrintMsg('LizeUI: Falta el string de import de BetterCooldownManager en LizeUI/imports/Imports.lua')
        return
    end

    local profileName = (type(block.profileName) == 'string' and block.profileName ~= '') and block.profileName or 'LizeUI'

    if not (_G.BCDMG and _G.BCDMG.ImportBCDM) then
        PrintMsg('LizeUI: No se encontró BCDMG:ImportBCDM (BetterCooldownManager).')
        return
    end

    local ok, err = pcall(function()
        _G.BCDMG:ImportBCDM(block.data, profileName)
    end)

    if ok then
        PrintMsg('LizeUI: Perfil importado en BetterCooldownManager.')
    else
        PrintMsg('LizeUI: Error importando en BetterCooldownManager: ' .. tostring(err))
    end
end

local function Import_Details()
    local block = GetImportBlock('details')
    if not HasImportString(block) then
        PrintMsg('LizeUI: Falta el string de import de Details en LizeUI/imports/Imports.lua')
        return
    end

    local details = _G.Details or _G._detalhes
    if type(details) ~= 'table' then
        PrintMsg('LizeUI: Details no está cargado.')
        return
    end

    local function SafeCall(label, fn)
        local ok, r1, r2, r3, r4 = pcall(fn)
        if not ok then
            return false, ('%s: %s'):format(label, tostring(r1))
        end
        return true, r1, r2, r3, r4
    end

    local function TryApplyDetailsProfile(profileName)
        local applied = false

        -- Muchas builds usan AceDB en details.db
        if details.db and type(details.db.SetProfile) == 'function' then
            -- Importante: NO crear un perfil vacío si el import no lo generó.
            local profiles = details.db.profiles
            local profileExists = (type(profiles) == 'table' and type(profiles[profileName]) == 'table')
            if profileExists then
                local ok = select(1, SafeCall('details.db:SetProfile', function() return details.db:SetProfile(profileName) end))
                applied = ok and true or applied
            end
        end

        -- Alternativas por si existe una API propia
        if not applied and type(details.ApplyProfile) == 'function' then
            applied = select(1, SafeCall('ApplyProfile', function() return details:ApplyProfile(profileName) end)) and true or applied
        elseif not applied and type(details.ChangeProfile) == 'function' then
            applied = select(1, SafeCall('ChangeProfile', function() return details:ChangeProfile(profileName) end)) and true or applied
        elseif not applied and type(details.SetProfile) == 'function' then
            applied = select(1, SafeCall('SetProfile', function() return details:SetProfile(profileName) end)) and true or applied
        elseif not applied and type(details.SwitchProfile) == 'function' then
            applied = select(1, SafeCall('SwitchProfile', function() return details:SwitchProfile(profileName) end)) and true or applied
        elseif not applied and type(details.LoadProfile) == 'function' then
            applied = select(1, SafeCall('LoadProfile', function() return details:LoadProfile(profileName) end)) and true or applied
        end

        -- Refrescos típicos (si existen) para que se note el cambio sin /reload
        if applied then
            if type(details.RefreshAllMainWindows) == 'function' then
                SafeCall('RefreshAllMainWindows', function() details:RefreshAllMainWindows() end)
            end
            if type(details.UpdateAllInstances) == 'function' then
                SafeCall('UpdateAllInstances', function() details:UpdateAllInstances() end)
            end
            if type(details.RefreshMainWindow) == 'function' then
                SafeCall('RefreshMainWindow', function() details:RefreshMainWindow() end)
            end
        end

        return applied
    end

    local desiredProfileName = (type(block.profileName) == 'string' and block.profileName ~= '') and block.profileName or 'LizeUI'
    local importedProfileName
    local importLabel
    local ok, r1, r2, r3, r4
    local err

    local dataLen = #block.data
    local head = string.sub(block.data, 1, 12)
    local tail = string.sub(block.data, math.max(1, dataLen - 11), dataLen)
    PrintMsg(('LizeUI: Details import string len=%d head=%s tail=%s'):format(dataLen, tostring(head), tostring(tail)))

    local function IsSuccessfulReturn(v)
        -- Muchas APIs devuelven true, o el nombre de perfil, o una tabla.
        -- Si devuelve nil/false, normalmente significa que la string no es válida.
        if v == nil or v == false then return false end
        return true
    end

    if type(details.ImportProfile) == 'function' then
        importLabel = 'ImportProfile'
        ok, r1, r2, r3, r4 = SafeCall(importLabel, function()
            return details:ImportProfile(block.data)
        end)

        if not ok then
            err = r1
        elseif IsSuccessfulReturn(r1) then
            importedProfileName = (type(r1) == 'string' and r1 ~= '') and r1 or desiredProfileName
        else
            ok = false
            err = importLabel .. ' devolvió ' .. tostring(r1) .. ' (string inválida o no soportada)'
        end

        -- Algunas versiones usan otra firma (p.ej. pasar nombre de perfil)
        if not ok then
            ok, r1, r2, r3, r4 = SafeCall(importLabel .. '(with profileName)', function()
                return details:ImportProfile(block.data, desiredProfileName)
            end)
            if not ok then
                err = r1
            elseif IsSuccessfulReturn(r1) then
                importedProfileName = (type(r1) == 'string' and r1 ~= '') and r1 or desiredProfileName
            else
                ok = false
                err = importLabel .. '(with profileName) devolvió ' .. tostring(r1) .. ' (string inválida o no soportada)'
            end
        end
    elseif type(details.ImportProfileFromString) == 'function' then
        importLabel = 'ImportProfileFromString'
        ok, r1, r2, r3, r4 = SafeCall(importLabel, function()
            return details:ImportProfileFromString(block.data)
        end)
        if not ok then
            err = r1
        elseif IsSuccessfulReturn(r1) then
            importedProfileName = (type(r1) == 'string' and r1 ~= '') and r1 or desiredProfileName
        else
            ok = false
            err = importLabel .. ' devolvió ' .. tostring(r1) .. ' (string inválida o no soportada)'
        end
    elseif type(details.ImportSettings) == 'function' then
        importLabel = 'ImportSettings'
        ok, r1, r2, r3, r4 = SafeCall(importLabel, function()
            return details:ImportSettings(block.data)
        end)
        if not ok then
            err = r1
        elseif not IsSuccessfulReturn(r1) then
            ok = false
            err = importLabel .. ' devolvió ' .. tostring(r1) .. ' (string inválida o no soportada)'
        end
    else
        PrintMsg('LizeUI: No se encontró una función de importación conocida en Details (ImportProfile/ImportProfileFromString/ImportSettings).')
        return
    end

    if not ok then
        PrintMsg('LizeUI: Error importando en Details: ' .. tostring(err))
        return
    end

    PrintMsg('LizeUI: Import Details OK (' .. tostring(importLabel) .. ').')

    -- Intentar cambiar al perfil importado para que el usuario vea el cambio inmediatamente.
    local profileToApply = importedProfileName or desiredProfileName
    local applied = TryApplyDetailsProfile(profileToApply)

    if applied then
        PrintMsg('LizeUI: Perfil activo en Details: ' .. tostring(profileToApply))
    else
        PrintMsg('LizeUI: Import hecho, pero no pude forzar el cambio de perfil en Details automáticamente. Si no ves cambios, selecciona el perfil "' .. tostring(profileToApply) .. '" dentro de Details.')
    end
end

-- Base de datos
LizeUIDB = LizeUIDB or { features = {} }

local function EnsureDefaults()
    LizeUIDB.features = LizeUIDB.features or {}
    if LizeUIDB.features.suppressRightClick == nil then LizeUIDB.features.suppressRightClick = true end
    if LizeUIDB.features.globalFadePersist == nil then LizeUIDB.features.globalFadePersist = true end
    if LizeUIDB.features.hidePetDemonBar == nil then LizeUIDB.features.hidePetDemonBar = true end
end

-- Opciones
local optionsTable = {
    type = "group",
    name = ('|T%s:14:14:0:0|t %s'):format(LIZEUI_ICON_PATH, GradientText('LizeUI', 0, 192, 250, 163, 53, 238)),
    icon = LIZEUI_ICON_PATH,
    iconCoords = { 0.08, 0.92, 0.08, 0.92 },
    order = 100,
    args = {
        infoBox = {
            order = 10,
            type = 'group',
            name = 'Información',
            inline = true,
            args = {
                desc = {
                    order = 1,
                    type = 'description',
                    name = 'Desde aquí puedes activar o desactivar funciones de LizeUI e importar perfiles para ElvUI y addons complementarios.\n\nNota: algunas opciones pueden requerir /reload para aplicarse por completo.',
                },
                spacer = {
                    order = 2,
                    type = 'description',
                    name = ' ',
                },
                suppressRightClick = {
                    order = 3,
                    type = 'toggle',
                    name = 'Suprimir click derecho (doble click)',
                    desc = 'Evita que un click derecho “suelto” corte el mouselook en combate (requiere recarga para efecto completo).',
                    get = function() return LizeUIDB.features.suppressRightClick end,
                    set = function(_, value)
                        LizeUIDB.features.suppressRightClick = value
                        LizeUI:ApplyFeature('suppressRightClick', value)
                    end,
                },
                globalFadePersist = {
                    order = 4,
                    type = 'toggle',
                    name = 'Global Fade Persist (vehículo)',
                    desc = 'Mantiene el fade global de barras de acción consistente en vehículo.',
                    get = function() return LizeUIDB.features.globalFadePersist end,
                    set = function(_, value)
                        LizeUIDB.features.globalFadePersist = value
                        LizeUI:ApplyFeature('globalFadePersist', value)
                    end,
                },
                hidePetDemonBar = {
                    order = 5,
                    type = 'toggle',
                    name = 'Ocultar marco de mascota/demonio',
                    desc = 'Oculta el marco de la mascota (demonio) si aparece.',
                    get = function() return LizeUIDB.features.hidePetDemonBar end,
                    set = function(_, value)
                        LizeUIDB.features.hidePetDemonBar = value
                        LizeUI:ApplyFeature('hidePetDemonBar', value)
                    end,
                },
            },
        },
        elvuiImportsBox = {
            order = 20,
            type = 'group',
            name = 'Importación LizeUI para ElvUI',
            inline = true,
            args = {
                desc = {
                    order = 1,
                    type = 'description',
                    name = 'A continuación podrás importar los perfiles de LizeUI en ElvUI según tu resolución.',
                },
                spacer = {
                    order = 2,
                    type = 'description',
                    name = ' ',
                },
                importElvui3k = {
                    order = 3,
                    type = 'execute',
                    name = 'LizeUI 3440x1440 (3K)',
                    confirm = true,
                    confirmText = '¿Importar el perfil de LizeUI en ElvUI (3K 3440x1440)?',
                    func = function() Import_ElvUI('elvui_4k', 'ElvUI (3K)') end,
                },
                importElvui2k = {
                    order = 4,
                    type = 'execute',
                    name = 'LizeUI 2560x1440 (2K)',
                    confirm = true,
                    confirmText = '¿Importar el perfil de LizeUI en ElvUI (2K 2560x1440)?',
                    func = function() Import_ElvUI('elvui_2k', 'ElvUI (2K)') end,
                },
                importElvui1k = {
                    order = 5,
                    type = 'execute',
                    name = 'LizeUI 1920x1080 (1K)',
                    confirm = true,
                    confirmText = '¿Importar el perfil de LizeUI en ElvUI (1K 1920x1080)?',
                    func = function() Import_ElvUI('elvui_1k', 'ElvUI (1K)') end,
                },
            },
        },
        addonImportsBox = {
            order = 30,
            type = 'group',
            name = 'Importación de Addons complementarios',
            inline = true,
            args = {
                desc = {
                    order = 1,
                    type = 'description',
                    name = 'A continuación podrás importar los perfiles de LizeUI en los addons correspondientes.',
                },
                spacer = {
                    order = 2,
                    type = 'description',
                    name = ' ',
                },
                importWindTools = {
                    order = 3,
                    type = 'execute',
                    name = 'Import WindTools',
                    confirm = true,
                    confirmText = '¿Importar el perfil de LizeUI en WindTools?',
                    func = function() Import_WindTools() end,
                },
                importPlater = {
                    order = 4,
                    type = 'execute',
                    name = 'Import Platers',
                    confirm = true,
                    confirmText = '¿Importar el perfil de LizeUI en Plater?',
                    func = function() Import_Plater() end,
                },
                importBCDM = {
                    order = 5,
                    type = 'execute',
                    name = 'Import BetterCooldownManager',
                    confirm = true,
                    confirmText = '¿Importar el perfil de LizeUI en BetterCooldownManager?',
                    func = function() Import_BetterCooldownManager() end,
                },
                importDetails = {
                    order = 6,
                    type = 'execute',
                    name = 'Import Details',
                    confirm = true,
                    confirmText = '¿Importar el perfil de LizeUI en Details?',
                    func = function() Import_Details() end,
                },
            },
        },
        otherImportsHeader = {
            order = 40,
            type = 'header',
            name = 'Información de otras importaciones',
        },
        otherImportsBox = {
            order = 41,
            type = 'group',
            name = ' ',
            inline = true,
            args = {
                desc = {
                    order = 1,
                    type = 'description',
                    name = 'LizeUI también integra recursos adicionales (texturas y fuentes) mediante SharedMedia. No se importan como “perfiles”, pero quedan disponibles para que otros addons los usen.',
                },
                spacer = {
                    order = 2,
                    type = 'description',
                    name = ' ',
                },
                texturesBox = {
                    order = 3,
                    type = 'group',
                    name = 'Texturas',
                    inline = true,
                    args = {
                        list = {
                            order = 1,
                            type = 'description',
                            name = function()
                                return BuildLSMResourceList('statusbar', 'Interface\\AddOns\\LizeUI\\media\\textures')
                            end,
                        },
                    },
                },
                fontsBox = {
                    order = 4,
                    type = 'group',
                    name = 'Fuentes',
                    inline = true,
                    args = {
                        list = {
                            order = 1,
                            type = 'description',
                            name = function()
                                return BuildLSMResourceList('font', 'Interface\\AddOns\\LizeUI\\media\\fonts')
                            end,
                        },
                    },
                },
            },
        },
    }
}

function LizeUI:InsertOptions()
    if not (E and E.Options and E.Options.args) then return end

    -- Insertar LizeUI como categoría principal (mismo nivel que General/ActionBars/etc.)
    E.Options.args[addonName] = optionsTable

    EnsurePluginsLine()

    -- Si las opciones ya están abiertas (o se abren justo ahora), aseguramos el tag del título.
    self:EnsureElvUIConfigTitleTagWithRetries()

    -- Hook opcional: si LibElvUIPlugin vuelve a reconstruir la lista al registrar plugins, reinsertamos.
    local libStub = _G.LibStub
    if (type(libStub) == 'table' or type(libStub) == 'function') and not self._lizeuiPluginHookDone then
        local EP
        if type(libStub) == 'table' and type(libStub.GetLibrary) == 'function' then
            EP = libStub:GetLibrary('LibElvUIPlugin-1.0', true)
        else
            EP = libStub('LibElvUIPlugin-1.0', true)
        end
        if EP and type(EP.RegisterPlugin) == 'function' then
            self._lizeuiPluginHookDone = true
            hooksecurefunc(EP, 'RegisterPlugin', function()
                EnsurePluginsLine()
            end)
        end
    end
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

function LizeUI:OptionsAddonLoaded(_, addon)
    if addon ~= 'ElvUI_Options' then return end
    self:InsertOptions()
    self:UnregisterEvent('ADDON_LOADED')
end

-- Funciones
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

-- Integración con ElvUI
function LizeUI:Initialize()
    self:EnsureElvUIToggleOptions()
    EnsureDefaults()

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

    if IsAddOnLoaded('ElvUI_Options') then
        self:InsertOptions()
    else
        self:RegisterEvent('ADDON_LOADED', 'OptionsAddonLoaded')
    end

    self:EnableAll()
end

E:RegisterModule(LizeUI:GetName())