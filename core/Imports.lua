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

function LizeUI:ImportElvUI(key, label, opts)
    key = (type(key) == 'string' and key ~= '') and key or 'elvui'
    label = (type(label) == 'string' and label ~= '') and label or 'ElvUI'

    local suppressReloadPrompt = false
    if type(opts) == 'boolean' then
        suppressReloadPrompt = opts
    elseif type(opts) == 'table' then
        suppressReloadPrompt = opts.suppressReloadPrompt == true or opts.noReloadPrompt == true
    end

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
        if not suppressReloadPrompt and (key == 'elvui_3k' or key == 'elvui_2k' or key == 'elvui_1k' or key == 'elvui') then
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

function LizeUI:ImportWindTools(opts)
    local suppressReloadPrompt = false
    if type(opts) == 'boolean' then
        suppressReloadPrompt = opts
    elseif type(opts) == 'table' then
        suppressReloadPrompt = opts.suppressReloadPrompt == true or opts.noReloadPrompt == true
    end

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
        if not suppressReloadPrompt then
            ShowReloadConfirm(LT('POPUP_RELOAD_UI_TEXT_WINDTOOLS'))
        end
    else
        PrintMsg(LTF('MSG_WINDTOOLS_IMPORT_ERROR_FMT', tostring(err)))
    end
end

function LizeUI:ImportPlater(opts)
    local suppressReloadPrompt = false
    if type(opts) == 'boolean' then
        suppressReloadPrompt = opts
    elseif type(opts) == 'table' then
        suppressReloadPrompt = opts.suppressReloadPrompt == true or opts.noReloadPrompt == true
    end

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
        if not suppressReloadPrompt then
            ShowReloadConfirm(LT('POPUP_RELOAD_UI_TEXT_PLATER'))
        end
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

    PrintMsg(LTF('MSG_WOW_IMPORTING_FMT', label, #layoutString))

    local function SnapshotLayouts()
        local api = _G.C_EditMode
        if not (api and type(api) == 'table' and type(api.GetLayouts) == 'function') then return nil end

        local ok, layoutInfo = pcall(function() return api.GetLayouts() end)
        if not ok or type(layoutInfo) ~= 'table' then return nil end

        local layouts = (type(layoutInfo.layouts) == 'table') and layoutInfo.layouts or nil
        if type(layouts) ~= 'table' then return nil end

        local names = {}
        local ids = {}
        for i, v in ipairs(layouts) do
            if type(v) == 'table' then
                local name = v.layoutName or v.name
                if type(name) == 'string' and name ~= '' then
                    names[name] = i
                end

                local id = v.layoutID or v.layoutId or v.id
                if id ~= nil then
                    ids[id] = i
                    ids[tostring(id)] = i
                end
            end
        end

        return {
            count = #layouts,
            names = names,
            ids = ids,
        }
    end

    local function FindNewLayoutIndex(beforeSnap, layoutInfoAfter)
        if not (beforeSnap and type(beforeSnap) == 'table') then return nil end
        if not (layoutInfoAfter and type(layoutInfoAfter) == 'table' and type(layoutInfoAfter.layouts) == 'table') then return nil end

        local layouts = layoutInfoAfter.layouts

        -- Mejor caso: detectar por layoutID nuevo.
        if type(beforeSnap.ids) == 'table' then
            for i, v in ipairs(layouts) do
                if type(v) == 'table' then
                    local id = v.layoutID or v.layoutId or v.id
                    if id ~= nil and not beforeSnap.ids[id] and not beforeSnap.ids[tostring(id)] then
                        return i
                    end
                end
            end
        end

        -- Fallback: detectar por nombre nuevo (aunque el nombre no sea el deseado).
        if type(beforeSnap.names) == 'table' then
            for i, v in ipairs(layouts) do
                if type(v) == 'table' then
                    local name = v.layoutName or v.name
                    if type(name) == 'string' and name ~= '' and not beforeSnap.names[name] then
                        return i
                    end
                end
            end
        end

        -- Último fallback: si aumentó el count, asumir el último.
        if type(beforeSnap.count) == 'number' and #layouts > beforeSnap.count then
            return #layouts
        end

        return nil
    end

    local function MakeUniqueLayoutName(baseName, snapshot)
        baseName = (type(baseName) == 'string' and baseName ~= '') and baseName or 'LizeUI'
        if not snapshot or type(snapshot.names) ~= 'table' then return baseName end
        if not snapshot.names[baseName] then return baseName end

        local i = 2
        while snapshot.names[(baseName .. ' (' .. i .. ')')] do
            i = i + 1
        end
        return baseName .. ' (' .. i .. ')'
    end

    local function TryAutoImportEditModeLayout(str, desiredName)
        local api = _G.C_EditMode
        if not (api and type(api) == 'table') then
            return false, LT('REASON_EDITMODE_API_UNAVAILABLE')
        end

        local before = SnapshotLayouts()
        local finalName = MakeUniqueLayoutName(desiredName, before)

        local apiUsed
        local layoutID
        local createdName
        local errors = {}

        local function Try(labelAttempt, fn)
            local ok, r1, r2, r3 = pcall(fn)
            if not ok then
                errors[#errors + 1] = labelAttempt .. ': ' .. tostring(r1)
                return false, nil, nil, nil
            end
            return true, r1, r2, r3
        end

        local function DetectImportResult(beforeSnap, expectedName)
            local afterSnap = SnapshotLayouts()
            local importedIndex = afterSnap and afterSnap.names and expectedName and afterSnap.names[expectedName] or nil
            local countIncreased = (beforeSnap and afterSnap and type(beforeSnap.count) == 'number' and type(afterSnap.count) == 'number')
                and (afterSnap.count > beforeSnap.count)
                or false
            return afterSnap, importedIndex, countIncreased
        end

        local function TryApplyEditModeChanges()
            if _G.InCombatLockdown and _G.InCombatLockdown() then return end
            local frame = _G.EditModeManagerFrame
            if not frame then return end

            local show = _G.ShowUIPanel
            local hide = _G.HideUIPanel
            if type(show) == 'function' and type(hide) == 'function' then
                pcall(function()
                    show(frame)
                    hide(frame)
                end)
            end
        end

        local function NormalizeLayoutsWithPresets(layoutInfo)
            if not (layoutInfo and type(layoutInfo) == 'table' and type(layoutInfo.layouts) == 'table') then return layoutInfo end
            local mgr = _G.EditModePresetLayoutManager
            if not (mgr and type(mgr.GetCopyOfPresetLayouts) == 'function') then return layoutInfo end

            local ok, preset = pcall(function() return mgr:GetCopyOfPresetLayouts() end)
            if not ok or type(preset) ~= 'table' or #preset == 0 then return layoutInfo end

            local combined = preset
            if type(_G.tAppendAll) == 'function' then
                _G.tAppendAll(combined, layoutInfo.layouts)
            else
                for _, v in ipairs(layoutInfo.layouts) do
                    table.insert(combined, v)
                end
            end
            layoutInfo.layouts = combined
            return layoutInfo
        end

        local function FindLayoutIndexByName(layoutInfo, wantedName)
            if not (layoutInfo and type(layoutInfo) == 'table' and type(layoutInfo.layouts) == 'table') then return nil end
            if type(wantedName) ~= 'string' or wantedName == '' then return nil end
            for i, v in ipairs(layoutInfo.layouts) do
                if type(v) == 'table' then
                    local n = v.layoutName or v.name
                    if n == wantedName then
                        return i
                    end
                end
            end
            return nil
        end

        local function ForceSelectLayoutByName(name)
            if type(api.GetLayouts) ~= 'function' or type(api.SaveLayouts) ~= 'function' then return false end
            local ok, li = pcall(function() return api.GetLayouts() end)
            if not ok or type(li) ~= 'table' then return false end

            li = NormalizeLayoutsWithPresets(li)
            local idx = FindLayoutIndexByName(li, name)
            if not idx then return false end

            li.activeLayout = idx
            pcall(function() api.SaveLayouts(li) end)
            if type(api.SetActiveLayout) == 'function' then
                pcall(function() api.SetActiveLayout(idx) end)
            end
            TryApplyEditModeChanges()
            return true
        end

        local function TryConvertAndSave()
            local convert = api.ConvertStringToLayoutInfo
                or (_G.EditModeManagerFrame and _G.EditModeManagerFrame.ConvertStringToLayoutInfo)
            if type(convert) ~= 'function' then
                return false, nil
            end

            apiUsed = 'ConvertStringToLayoutInfo+SaveLayouts'
            local okConv, importedLayout = Try('ConvertStringToLayoutInfo(str)', function()
                if convert == api.ConvertStringToLayoutInfo then
                    return convert(str)
                end
                return convert(_G.EditModeManagerFrame, str)
            end)

            if not okConv or type(importedLayout) ~= 'table' then
                errors[#errors + 1] = 'ConvertStringToLayoutInfo: returned ' .. tostring(importedLayout)
                return false, nil
            end

            if type(api.GetLayouts) ~= 'function' or type(api.SaveLayouts) ~= 'function' then
                errors[#errors + 1] = 'SaveLayouts/GetLayouts not available'
                return false, nil
            end

            local okGet, layoutInfo = Try('GetLayouts()', function() return api.GetLayouts() end)
            if not okGet or type(layoutInfo) ~= 'table' or type(layoutInfo.layouts) ~= 'table' then
                errors[#errors + 1] = 'GetLayouts: returned invalid layoutInfo'
                return false, nil
            end

            createdName = finalName

            local function ShallowCopy(t)
                if type(t) ~= 'table' then return t end
                local out = {}
                for k, v in pairs(t) do out[k] = v end
                return out
            end

            local function BuildNewLayoutFromTemplate(template, imported)
                local base
                if type(_G.CopyTable) == 'function' and type(template) == 'table' then
                    base = _G.CopyTable(template)
                else
                    base = ShallowCopy(template)
                end

                if type(base) ~= 'table' then
                    base = {}
                end

                if type(imported) == 'table' then
                    for k, v in pairs(imported) do
                        if k ~= 'layoutName' and k ~= 'name' and k ~= 'layoutType' then
                            base[k] = v
                        end
                    end
                end

                base.layoutName = createdName
                base.name = createdName
                if base.layoutType == nil and _G.Enum and _G.Enum.EditModeLayoutType then
                    base.layoutType = _G.Enum.EditModeLayoutType.Character
                end

                -- Evitar conflictos si el template trae un layoutID.
                if base.layoutID ~= nil then base.layoutID = nil end
                if base.layoutId ~= nil then base.layoutId = nil end
                if base.id ~= nil then base.id = nil end

                return base
            end

            local templateLayout = layoutInfo.layouts and layoutInfo.layouts[1]
            local newLayout = BuildNewLayoutFromTemplate(templateLayout, importedLayout)

            table.insert(layoutInfo.layouts, newLayout)
            local newIndex = #layoutInfo.layouts
            layoutInfo.activeLayout = newIndex

            if _G.EditModeManagerFrame and type(_G.EditModeManagerFrame.ReconcileWithModern) == 'function' then
                pcall(function() _G.EditModeManagerFrame:ReconcileWithModern(newLayout) end)
                -- Algunas builds pueden tocar el nombre durante el reconcile.
                newLayout.layoutName = createdName
                newLayout.name = createdName
            end

            local okSave = select(1, Try('SaveLayouts(layoutInfo)', function() api.SaveLayouts(layoutInfo) end))
            if not okSave then
                errors[#errors + 1] = 'SaveLayouts failed'
                return false, nil
            end

            -- Verificar que realmente se creó el layout; si no, considerarlo fallo.
            local actualName
            local targetIndex = newIndex
            local okGet2, layoutInfo2 = Try('GetLayouts(after save)', function() return api.GetLayouts() end)
            if okGet2 and type(layoutInfo2) == 'table' and type(layoutInfo2.layouts) == 'table' then
                local afterSnap = SnapshotLayouts()
                local created = (before and afterSnap and type(before.count) == 'number' and type(afterSnap.count) == 'number')
                    and (afterSnap.count > before.count)
                    or false

                targetIndex = FindNewLayoutIndex(before, layoutInfo2) or targetIndex
                if not created and not targetIndex then
                    errors[#errors + 1] = 'SaveLayouts: layout not created (count did not increase)'
                    return false, nil
                end

                if type(layoutInfo2.layouts[targetIndex]) == 'table' then
                    local row = layoutInfo2.layouts[targetIndex]
                    actualName = row.layoutName or row.name

                    -- Persistir selección del layout activo.
                    layoutInfo2.activeLayout = targetIndex

                    if type(actualName) == 'string' and actualName ~= '' and actualName ~= createdName then
                        row.layoutName = createdName
                        row.name = createdName

                        -- Si existe una API de renombrado, intentarla también (por compatibilidad entre builds).
                        if type(api.SetLayoutName) == 'function' then
                            pcall(function() api.SetLayoutName(targetIndex, createdName) end)
                            pcall(function() api.SetLayoutName(createdName, targetIndex) end)
                        end
                        if type(api.RenameLayout) == 'function' then
                            pcall(function() api.RenameLayout(targetIndex, createdName) end)
                            pcall(function() api.RenameLayout(createdName, targetIndex) end)
                        end
                        if _G.EditModeManagerFrame and type(_G.EditModeManagerFrame.RenameLayout) == 'function' then
                            pcall(function() _G.EditModeManagerFrame:RenameLayout(targetIndex, createdName) end)
                            pcall(function() _G.EditModeManagerFrame:RenameLayout(createdName, targetIndex) end)
                        end

                        pcall(function() api.SaveLayouts(layoutInfo2) end)

                        local okGet3, layoutInfo3 = Try('GetLayouts(after rename)', function() return api.GetLayouts() end)
                        if okGet3 and type(layoutInfo3) == 'table' and type(layoutInfo3.layouts) == 'table' and type(layoutInfo3.layouts[targetIndex]) == 'table' then
                            local row3 = layoutInfo3.layouts[targetIndex]
                            actualName = row3.layoutName or row3.name or actualName
                        end
                    end

                    -- Guardar selección activa incluso si el nombre ya coincidía.
                    pcall(function() api.SaveLayouts(layoutInfo2) end)
                end
            end

            if type(api.SetActiveLayout) == 'function' then
                pcall(function() api.SetActiveLayout(targetIndex) end)
            end

            -- En algunas builds el índice que espera SetActiveLayout incluye presets.
            -- Intentamos selección por nombre usando el layoutInfo combinado (presets + editable).
            ForceSelectLayoutByName(createdName)
            if type(actualName) == 'string' and actualName ~= '' and actualName ~= createdName then
                ForceSelectLayoutByName(actualName)
            end

            return true, targetIndex, actualName
        end

        if type(api.ImportLayout) == 'function' then
            apiUsed = 'C_EditMode.ImportLayout'

            local okCall, r1 = Try('ImportLayout(str, name)', function() return api.ImportLayout(str, finalName) end)
            if okCall then layoutID = r1 end
            if okCall and r1 == nil then errors[#errors + 1] = 'ImportLayout(str, name): returned nil' end

            if not okCall or r1 == nil then
                okCall, r1 = Try('ImportLayout(name, str)', function() return api.ImportLayout(finalName, str) end)
                if okCall then layoutID = r1 end
                if okCall and r1 == nil then errors[#errors + 1] = 'ImportLayout(name, str): returned nil' end
            end

            if not okCall or r1 == nil then
                okCall, r1 = Try('ImportLayout(str)', function() return api.ImportLayout(str) end)
                if okCall then layoutID = r1 end
                if okCall and r1 == nil then errors[#errors + 1] = 'ImportLayout(str): returned nil' end
            end
        elseif _G.EditModeManagerFrame and type(_G.EditModeManagerFrame.ImportLayout) == 'function' then
            apiUsed = 'EditModeManagerFrame:ImportLayout'

            local okCall, r1 = Try('Frame:ImportLayout(str, name)', function()
                return _G.EditModeManagerFrame:ImportLayout(str, finalName)
            end)
            if okCall then layoutID = r1 end
            if okCall and r1 == nil then errors[#errors + 1] = 'Frame:ImportLayout(str, name): returned nil' end

            if not okCall or r1 == nil then
                okCall, r1 = Try('Frame:ImportLayout(str)', function() return _G.EditModeManagerFrame:ImportLayout(str) end)
                if okCall then layoutID = r1 end
                if okCall and r1 == nil then errors[#errors + 1] = 'Frame:ImportLayout(str): returned nil' end
            end
        else
            local okSaved, newIndex, actualName = TryConvertAndSave()
            if okSaved then
                -- Si el nombre real difiere, devolvemos el nombre real para logging/diagnóstico.
                return true, apiUsed, newIndex, (type(actualName) == 'string' and actualName ~= '' and actualName) or createdName
            end
            local reason = (#errors > 0) and table.concat(errors, ' | ') or LT('REASON_EDITMODE_API_UNAVAILABLE')
            return false, reason
        end

        local _, importedIndex, countIncreased = DetectImportResult(before, finalName)

        -- Si no aparece por nombre pero sí aumentó el contador, intentar detectar el nuevo layout y activarlo.
        if not importedIndex and countIncreased and type(api.GetLayouts) == 'function' then
            local okAfter, layoutInfoAfter = Try('GetLayouts(after ImportLayout)', function() return api.GetLayouts() end)
            if okAfter and type(layoutInfoAfter) == 'table' and type(layoutInfoAfter.layouts) == 'table' then
                importedIndex = FindNewLayoutIndex(before, layoutInfoAfter)
            end
        end

        -- Si podemos, activamos el layout recién importado.
        if type(api.SetActiveLayout) == 'function' then
            if importedIndex then
                pcall(function() api.SetActiveLayout(importedIndex) end)
                -- Intentar también selección por nombre (maneja índice con presets).
                ForceSelectLayoutByName(finalName)
            end
        end

        -- Determinar éxito: si el layout aparece por nombre, o si aumentó el contador, o si devolvió un ID/índice.
        if importedIndex or countIncreased or layoutID ~= nil then
            return true, apiUsed or 'unknown', layoutID, finalName
        end

        -- Si ImportLayout existe pero no devolvió nada (ni apareció layout), probar estrategia Convert+Save.
        local okSaved, newIndex, actualName = TryConvertAndSave()
        if okSaved then
            return true, apiUsed or 'unknown', newIndex, (type(actualName) == 'string' and actualName ~= '' and actualName) or createdName or finalName
        end

        local reason = (#errors > 0) and table.concat(errors, ' | ') or 'unknown'
        return false, reason
    end

    -- Intentar auto-importar primero (si la API lo permite). Si falla, fallback al copy/paste.
    local baseName = 'LizeUI'
    if key == 'wow_3k' then
        baseName = 'LizeUI_3K'
    elseif key == 'wow_2k' then
        baseName = 'LizeUI_2K'
    end

    local okAuto, apiOrReason, layoutID, savedName = TryAutoImportEditModeLayout(layoutString, baseName)
    if okAuto then
        if layoutID ~= nil then
            PrintMsg(LTF('MSG_WOW_LAYOUT_IMPORTED_API_ID_FMT', label, tostring(apiOrReason), tostring(layoutID)))
        else
            PrintMsg(LTF('MSG_WOW_LAYOUT_IMPORTED_API_FMT', label, tostring(apiOrReason)))
        end
        if type(savedName) == 'string' and savedName ~= '' then
            PrintMsg(LTF('MSG_WOW_LAYOUT_SAVED_NAME_FMT', savedName))
        end
        PrintMsg(LT('MSG_WOW_VISUAL_HINT'))
        return
    end

    PrintMsg(LTF('MSG_WOW_AUTO_IMPORT_FAILED_FMT', label, tostring(apiOrReason)))
    -- No abrir Edit Mode ni ventana de copiado automáticamente.
    -- Si el usuario quiere fallback manual, se lo indicamos por chat.
    PrintMsg(LT('MSG_WOW_COPY_PASTE_HELP'))
    return
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
