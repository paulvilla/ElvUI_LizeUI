-- Imports.lua: acciones de importación (ElvUI/WindTools/Plater/Details/WoW Edit Mode)

local _, ns = ...

local E = ns.E
local LizeUI = ns.LizeUI
local LT = ns.LT
local LTF = ns.LTF
local PrintMsg = ns.PrintMsg
local NormalizeImportString = ns.NormalizeImportString or function(s) return (type(s) == 'string' and s) or '' end

local function ShowReloadConfirm(message)
    if type(message) ~= 'string' or message == '' then return end

    local dialogs = _G.StaticPopupDialogs
    local show = _G.StaticPopup_Show
    if type(dialogs) ~= 'table' or type(show) ~= 'function' then
        -- Fallback si por algún motivo el sistema de popups no está disponible.
        PrintMsg(message .. ' (/reload)')
        return
    end

    local which = 'LIZEUI_RELOAD_UI_CONFIRM'

    dialogs[which] = dialogs[which] or {
        text = '%s',
        button1 = LT('POPUP_RELOAD_UI_RELOAD'),
        button2 = LT('POPUP_RELOAD_UI_CANCEL'),
        OnAccept = function()
            if type(_G.ReloadUI) == 'function' then
                _G.ReloadUI()
            end
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        preferredIndex = 3,
    }

    -- Por si el usuario forzó idioma en runtime, refrescamos labels.
    dialogs[which].button1 = LT('POPUP_RELOAD_UI_RELOAD')
    dialogs[which].button2 = LT('POPUP_RELOAD_UI_CANCEL')

    show(which, message)
end

local ADDON_PATH = ns.ADDON_PATH

local function GetImportBlock(key)
    local t = _G.LizeUI_Imports
    if type(t) ~= 'table' then return nil end
    local block = t[key]
    if type(block) ~= 'table' then return nil end
    return block
end

local function GetImportData(block)
    if type(block) ~= 'table' then return '' end
    if type(block.data) ~= 'string' then return '' end

    -- Cache muy simple por identidad del string (mismo contenido => mismo objeto en Lua, normalmente)
    if block.__lizeui_norm_src == block.data and type(block.__lizeui_norm_data) == 'string' then
        return block.__lizeui_norm_data
    end

    local normalized = NormalizeImportString(block.data)
    block.__lizeui_norm_src = block.data
    block.__lizeui_norm_data = normalized
    return normalized
end

local function HasImportString(block)
    local data = GetImportData(block)
    return type(data) == 'string' and data ~= ''
end

function LizeUI:ImportElvUI(key, label)
    key = (type(key) == 'string' and key ~= '') and key or 'elvui'
    label = (type(label) == 'string' and label ~= '') and label or 'ElvUI'

    local block = GetImportBlock(key)
    if not HasImportString(block) then
        PrintMsg(LTF('MSG_MISSING_IMPORT_STRING_FMT', label, key))
        return
    end

    if not (E and E.GetModule) then
        PrintMsg(LT('MSG_ELVUI_NOT_AVAILABLE'))
        return
    end

    local D = E:GetModule('Distributor', true)
    if not (D and D.ImportProfile) then
        PrintMsg(LT('MSG_ELVUI_DISTRIBUTOR_MISSING'))
        return
    end

    local data = GetImportData(block)

    local ok, resultOrErr = pcall(function()
        return D:ImportProfile(data)
    end)

    -- ImportProfile puede fallar sin lanzar error Lua (ElvUI lo imprime por su cuenta).
    -- En ese caso suele devolver nil/false; no debemos mostrar "importado".
    if ok and resultOrErr ~= nil and resultOrErr ~= false then
        PrintMsg(LTF('MSG_PROFILE_IMPORTED_FMT', label))

        -- Para ElvUI (en particular imports grandes como 3K/2K), suele ser recomendable /reload.
        if key == 'elvui_3k' or key == 'elvui_2k' or key == 'elvui_1k' or key == 'elvui' then
            ShowReloadConfirm(LT('POPUP_RELOAD_UI_TEXT_ELVUI'))
        end
        return
    end

    local reason
    if not ok then
        reason = tostring(resultOrErr)
    else
        reason = 'D:ImportProfile(data): returned ' .. tostring(resultOrErr)
    end
    PrintMsg(LTF('MSG_IMPORT_ERROR_FMT', label, reason))
end

function LizeUI:ImportWindTools()
    local block = GetImportBlock('windtools')
    if not HasImportString(block) then
        PrintMsg(LT('MSG_WINDTOOLS_MISSING_STRING'))
        return
    end

    local wt = _G.WindTools
    if type(wt) ~= 'table' then
        PrintMsg(LT('MSG_WINDTOOLS_NOT_LOADED'))
        return
    end

    local W, F = unpack(wt)
    if not (F and F.Profiles and F.Profiles.ImportByString) then
        PrintMsg(LT('MSG_WINDTOOLS_API_MISSING'))
        return
    end

    local data = GetImportData(block)
    local ok, err = pcall(function() F.Profiles.ImportByString(data) end)
    if ok then
        PrintMsg(LT('MSG_WINDTOOLS_IMPORTED_RELOADING'))
        ShowReloadConfirm(LT('POPUP_RELOAD_UI_TEXT_WINDTOOLS'))
    else
        PrintMsg(LTF('MSG_WINDTOOLS_IMPORT_ERROR_FMT', tostring(err)))
    end
end

function LizeUI:ImportPlater()
    local block = GetImportBlock('plater')
    if not HasImportString(block) then
        PrintMsg(LT('MSG_PLATER_MISSING_STRING'))
        return
    end

    local plater = _G.Plater
    if not (plater and plater.ImportAndSwitchProfile) then
        PrintMsg(LT('MSG_PLATER_API_MISSING'))
        return
    end

    local profileName = (type(block.profileName) == 'string' and block.profileName ~= '') and block.profileName or 'LizeUI'
    local data = GetImportData(block)

    local ok, err = pcall(function()
        plater.ImportAndSwitchProfile(profileName, data, false, false, true)
    end)

    if ok then
        PrintMsg(LT('MSG_PLATER_IMPORTED'))
        ShowReloadConfirm(LT('POPUP_RELOAD_UI_TEXT_PLATER'))
    else
        PrintMsg(LTF('MSG_PLATER_IMPORT_ERROR_FMT', tostring(err)))
    end
end

function LizeUI:ImportWoWEditMode(key, label)
    key = (type(key) == 'string' and key ~= '') and key or 'wow_3k'
    label = (type(label) == 'string' and label ~= '') and label or 'WoW (Edit Mode)'

    local function EnsureCopyWindow()
        if _G.LizeUI_ImportCopyFrame and _G.LizeUI_ImportCopyFrame.editBox then
            return _G.LizeUI_ImportCopyFrame
        end

        local parent = (E and E.UIParent) or UIParent
        local frame = CreateFrame('Frame', 'LizeUI_ImportCopyFrame', parent, 'BackdropTemplate')
        frame:SetSize(720, 420)
        frame:SetPoint('CENTER')
        frame:SetFrameStrata('DIALOG')
        frame:Hide()
        frame:EnableMouse(true)
        frame:SetMovable(true)
        frame:RegisterForDrag('LeftButton')
        frame:SetScript('OnDragStart', frame.StartMoving)
        frame:SetScript('OnDragStop', frame.StopMovingOrSizing)

        if type(frame.SetTemplate) == 'function' then
            frame:SetTemplate('Transparent')
        elseif E and type(E.SetTemplate) == 'function' then
            E:SetTemplate(frame, 'Transparent')
        end

        local S = (E and type(E.GetModule) == 'function') and E:GetModule('Skins', true) or nil

        frame.header = CreateFrame('Frame', nil, frame, 'BackdropTemplate')
        frame.header:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 0)
        frame.header:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 0, 0)
        frame.header:SetHeight(24)
        if type(frame.header.SetTemplate) == 'function' then
            frame.header:SetTemplate('Default')
        elseif E and type(E.SetTemplate) == 'function' then
            E:SetTemplate(frame.header, 'Default')
        end

        frame.title = frame.header:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        frame.title:SetPoint('LEFT', frame.header, 'LEFT', 10, 0)
        frame.title:SetText('LizeUI')

        frame.closeButton = CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
        frame.closeButton:SetPoint('TOPRIGHT', frame.header, 'TOPRIGHT', 2, 2)
        if S and type(S.HandleCloseButton) == 'function' then
            pcall(function() S:HandleCloseButton(frame.closeButton) end)
        end

        frame.help = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
        frame.help:SetPoint('TOPLEFT', frame, 'TOPLEFT', 16, -34)
        frame.help:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -16, -34)
        frame.help:SetJustifyH('LEFT')
        frame.help:SetText(LT('COPYWIN_HELP'))

        frame.scrollBg = CreateFrame('Frame', nil, frame, 'BackdropTemplate')
        frame.scrollBg:SetPoint('TOPLEFT', frame, 'TOPLEFT', 16, -56)
        frame.scrollBg:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -16, 44)
        if type(frame.scrollBg.SetTemplate) == 'function' then
            frame.scrollBg:SetTemplate('Default')
        elseif E and type(E.SetTemplate) == 'function' then
            E:SetTemplate(frame.scrollBg, 'Default')
        end

        local scrollFrame = CreateFrame('ScrollFrame', nil, frame.scrollBg, 'UIPanelScrollFrameTemplate')
        scrollFrame:SetPoint('TOPLEFT', frame.scrollBg, 'TOPLEFT', 4, -4)
        scrollFrame:SetPoint('BOTTOMRIGHT', frame.scrollBg, 'BOTTOMRIGHT', -26, 4)

        if S and type(S.HandleScrollBar) == 'function' and scrollFrame.ScrollBar then
            pcall(function() S:HandleScrollBar(scrollFrame.ScrollBar) end)
        end

        local editBox = CreateFrame('EditBox', nil, scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetFontObject('ChatFontNormal')
        editBox:SetWidth(660)
        editBox:SetAutoFocus(false)
        editBox:EnableMouse(true)
        editBox:SetTextInsets(8, 8, 8, 8)
        editBox:SetScript('OnEscapePressed', function() frame:Hide() end)

        scrollFrame:SetScrollChild(editBox)

        frame.editBox = editBox
        frame.scrollFrame = scrollFrame

        frame.selectAll = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
        frame.selectAll:SetSize(140, 22)
        frame.selectAll:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 16, 14)
        frame.selectAll:SetText(LT('COPYWIN_SELECT_ALL'))
        frame.selectAll:SetScript('OnClick', function()
            editBox:SetFocus()
            editBox:HighlightText()
        end)

        frame.close = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
        frame.close:SetSize(100, 22)
        frame.close:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -16, 14)
        frame.close:SetText(LT('COPYWIN_CLOSE'))
        frame.close:SetScript('OnClick', function() frame:Hide() end)

        if S and type(S.HandleButton) == 'function' then
            pcall(function() S:HandleButton(frame.selectAll) end)
            pcall(function() S:HandleButton(frame.close) end)
        end

        frame:SetScript('OnShow', function()
            if _G.C_Timer and type(_G.C_Timer.After) == 'function' then
                _G.C_Timer.After(0, function()
                    if frame:IsShown() then
                        editBox:SetFocus()
                        editBox:HighlightText()
                    end
                end)
            end
        end)

        _G.LizeUI_ImportCopyFrame = frame
        return frame
    end

    local block = GetImportBlock(key)
    if not HasImportString(block) then
        PrintMsg(LTF('MSG_MISSING_IMPORT_STRING_FMT', label, key))
        return
    end

    if _G.C_AddOns and type(_G.C_AddOns.LoadAddOn) == 'function' then
        pcall(function() _G.C_AddOns.LoadAddOn('Blizzard_EditMode') end)
    elseif type(_G.UIParentLoadAddOn) == 'function' then
        pcall(function() _G.UIParentLoadAddOn('Blizzard_EditMode') end)
    end

    local layoutString = GetImportData(block)
    layoutString = layoutString:gsub('^%s+', ''):gsub('%s+$', '')

    local function OpenEditModeUI()
        if _G.EditModeManagerFrame and type(_G.EditModeManagerFrame.Show) == 'function' then
            pcall(function() _G.EditModeManagerFrame:Show() end)
        end
        if _G.EditModeManagerFrame and type(_G.EditModeManagerFrame.EnterEditMode) == 'function' then
            pcall(function() _G.EditModeManagerFrame:EnterEditMode() end)
        end
    end

    -- Nota: la auto-importación de Edit Mode es inestable entre builds/parches.
    -- Por eso sólo mostramos la ventana de copiado y abrimos Edit Mode para que el usuario importe manualmente.
    OpenEditModeUI()

    local copyFrame = EnsureCopyWindow()
    copyFrame.title:SetText(LTF('COPYWIN_TITLE_FMT', label))
    copyFrame.editBox:SetText(layoutString)
    copyFrame.editBox:SetCursorPosition(0)
    copyFrame:Show()

    PrintMsg(LT('MSG_WOW_COPY_PASTE_HELP'))
end

function LizeUI:ImportBetterCooldownManager()
    local block = GetImportBlock('betterCooldownManager')
    if not HasImportString(block) then
        PrintMsg(LT('MSG_BCDM_MISSING_STRING'))
        return
    end

    local profileName = (type(block.profileName) == 'string' and block.profileName ~= '') and block.profileName or 'LizeUI'
    local data = GetImportData(block)

    if not (_G.BCDMG and _G.BCDMG.ImportBCDM) then
        PrintMsg(LT('MSG_BCDM_API_MISSING'))
        return
    end

    local ok, err = pcall(function()
        _G.BCDMG:ImportBCDM(data, profileName)
    end)

    if ok then
        PrintMsg(LT('MSG_BCDM_IMPORTED'))
    else
        PrintMsg(LTF('MSG_BCDM_IMPORT_ERROR_FMT', tostring(err)))
    end
end

function LizeUI:ImportDetails()
    local block = GetImportBlock('details')
    if not HasImportString(block) then
        PrintMsg(LT('MSG_DETAILS_MISSING_STRING'))
        return
    end

    local data = GetImportData(block)

    local details = _G.Details or _G._detalhes
    if type(details) ~= 'table' then
        PrintMsg(LT('MSG_DETAILS_NOT_LOADED'))
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
            applied = select(1, SafeCall('ApplyProfile', function() details:ApplyProfile(profileName) end)) and true or applied
        elseif not applied and type(details.ChangeProfile) == 'function' then
            applied = select(1, SafeCall('ChangeProfile', function() details:ChangeProfile(profileName) end)) and true or applied
        elseif not applied and type(details.SetProfile) == 'function' then
            applied = select(1, SafeCall('SetProfile', function() details:SetProfile(profileName) end)) and true or applied
        elseif not applied and type(details.SwitchProfile) == 'function' then
            applied = select(1, SafeCall('SwitchProfile', function() details:SwitchProfile(profileName) end)) and true or applied
        elseif not applied and type(details.LoadProfile) == 'function' then
            applied = select(1, SafeCall('LoadProfile', function() details:LoadProfile(profileName) end)) and true or applied
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
    local ok, r1
    local err

    local dataLen = #data
    local head = string.sub(data, 1, 12)
    local tail = string.sub(data, math.max(1, dataLen - 11), dataLen)
    PrintMsg(LTF('MSG_DETAILS_STRING_INFO_FMT', dataLen, tostring(head), tostring(tail)))

    local function IsSuccessfulReturn(v)
        -- Muchas APIs devuelven true, o el nombre de perfil, o una tabla.
        -- Si devuelve nil/false, normalmente significa que la string no es válida.
        if v == nil or v == false then return false end
        return true
    end

    if type(details.ImportProfile) == 'function' then
        importLabel = 'ImportProfile'
        ok, r1 = SafeCall(importLabel, function()
            return details:ImportProfile(data)
        end)

        if not ok then
            err = r1
        elseif IsSuccessfulReturn(r1) then
            importedProfileName = (type(r1) == 'string' and r1 ~= '') and r1 or desiredProfileName
        else
            ok = false
            err = LTF('MSG_DETAILS_RETURNED_INVALID_FMT', importLabel, tostring(r1))
        end

        -- Algunas versiones usan otra firma (p.ej. pasar nombre de perfil)
        if not ok then
            ok, r1 = SafeCall(importLabel .. '(with profileName)', function()
                return details:ImportProfile(data, desiredProfileName)
            end)
            if not ok then
                err = r1
            elseif IsSuccessfulReturn(r1) then
                importedProfileName = (type(r1) == 'string' and r1 ~= '') and r1 or desiredProfileName
            else
                ok = false
                err = LTF('MSG_DETAILS_RETURNED_INVALID_FMT', importLabel .. '(with profileName)', tostring(r1))
            end
        end
    elseif type(details.ImportProfileFromString) == 'function' then
        importLabel = 'ImportProfileFromString'
        ok, r1 = SafeCall(importLabel, function()
            return details:ImportProfileFromString(data)
        end)
        if not ok then
            err = r1
        elseif IsSuccessfulReturn(r1) then
            importedProfileName = (type(r1) == 'string' and r1 ~= '') and r1 or desiredProfileName
        else
            ok = false
            err = LTF('MSG_DETAILS_RETURNED_INVALID_FMT', importLabel, tostring(r1))
        end
    elseif type(details.ImportSettings) == 'function' then
        importLabel = 'ImportSettings'
        ok, r1 = SafeCall(importLabel, function()
            return details:ImportSettings(data)
        end)
        if not ok then
            err = r1
        elseif not IsSuccessfulReturn(r1) then
            ok = false
            err = LTF('MSG_DETAILS_RETURNED_INVALID_FMT', importLabel, tostring(r1))
        end
    else
        PrintMsg(LT('MSG_DETAILS_NO_IMPORT_API'))
        return
    end

    if not ok then
        PrintMsg(LTF('MSG_DETAILS_IMPORT_ERROR_FMT', tostring(err)))
        return
    end

    PrintMsg(LTF('MSG_DETAILS_IMPORT_OK_FMT', tostring(importLabel)))

    -- Intentar cambiar al perfil importado para que el usuario vea el cambio inmediatamente.
    local profileToApply = importedProfileName or desiredProfileName
    local applied = TryApplyDetailsProfile(profileToApply)

    if applied then
        PrintMsg(LTF('MSG_DETAILS_ACTIVE_PROFILE_FMT', tostring(profileToApply)))
    else
        PrintMsg(LTF('MSG_DETAILS_IMPORT_DONE_NOT_APPLIED_FMT', tostring(profileToApply)))
    end
end
