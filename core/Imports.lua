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

local function ShowDuplicateNamePrompt(kindLabel, name, onReplace, onKeep)
    kindLabel = (type(kindLabel) == 'string' and kindLabel ~= '') and kindLabel or LT('POPUP_DUPLICATE_KIND_PROFILE')
    name = (type(name) == 'string' and name ~= '') and name or ''
    if name == '' then return false end

    local message = LTF('POPUP_DUPLICATE_NAME_TEXT_FMT', kindLabel, name)
    local payload = { onReplace = onReplace, onKeep = onKeep }

    -- Preferir el sistema de popups de ElvUI para que se vea bien dentro del PluginInstaller.
    if E and type(E) == 'table' and type(E.StaticPopup_Show) == 'function' then
        E.PopupDialogs = E.PopupDialogs or {}
        local which = 'LIZEUI_IMPORT_DUPLICATE_NAME'

        if not E.PopupDialogs[which] then
            E.PopupDialogs[which] = {
                text = 'LizeUI',
                button1 = LT('POPUP_DUPLICATE_NAME_KEEP'),
                button2 = LT('POPUP_DUPLICATE_NAME_REPLACE'),
                OnShow = function(self, data)
                    if self then self.data = data end
                end,
                OnAccept = function(self, data)
                    data = data or (self and self.data)
                    if type(data) == 'table' and type(data.onKeep) == 'function' then
                        data.onKeep()
                    end
                end,
                OnCancel = function(self, data)
                    data = data or (self and self.data)
                    if type(data) == 'table' and type(data.onReplace) == 'function' then
                        data.onReplace()
                    end
                end,
                whileDead = 1,
                preferredIndex = 3,
                -- Seguridad: ESC no debe poder disparar "Sustituir".
                hideOnEscape = 0,
            }
        end

        E.PopupDialogs[which].text = message
        E.PopupDialogs[which].button1 = LT('POPUP_DUPLICATE_NAME_KEEP')
        E.PopupDialogs[which].button2 = LT('POPUP_DUPLICATE_NAME_REPLACE')

        E:StaticPopup_Show(which, nil, nil, payload)
        return true
    end

    local dialogs = _G.StaticPopupDialogs
    local show = _G.StaticPopup_Show
    if type(dialogs) ~= 'table' or type(show) ~= 'function' then
        -- Si no hay popups disponibles, por seguridad no tocamos nada.
        if type(onKeep) == 'function' then onKeep() end
        return false
    end

    local which = 'LIZEUI_IMPORT_DUPLICATE_NAME'
    dialogs[which] = dialogs[which] or {
        text = '%s',
        button1 = LT('POPUP_DUPLICATE_NAME_KEEP'),
        button2 = LT('POPUP_DUPLICATE_NAME_REPLACE'),
        OnAccept = function(self, data)
            data = data or (self and self.data)
            if type(data) == 'table' and type(data.onKeep) == 'function' then
                data.onKeep()
            end
        end,
        OnCancel = function(self, data)
            data = data or (self and self.data)
            if type(data) == 'table' and type(data.onReplace) == 'function' then
                data.onReplace()
            end
        end,
        timeout = 0,
        whileDead = 1,
        -- Seguridad: ESC no debe poder disparar "Sustituir".
        hideOnEscape = 0,
        preferredIndex = 3,
    }

    dialogs[which].button1 = LT('POPUP_DUPLICATE_NAME_KEEP')
    dialogs[which].button2 = LT('POPUP_DUPLICATE_NAME_REPLACE')

    show(which, message, nil, payload)
    return true
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

local function EnsureImportCopyWindow()
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

local function ShowImportCopyWindow(title, helpText, importString)
    local frame = EnsureImportCopyWindow()
    if not frame then return end

    if frame.title and type(frame.title.SetText) == 'function' then
        frame.title:SetText(LTF('COPYWIN_TITLE_FMT', title or ''))
    end

    if frame.help and type(frame.help.SetText) == 'function' then
        frame.help:SetText((type(helpText) == 'string' and helpText ~= '') and helpText or LT('COPYWIN_HELP'))
    end

    if frame.editBox and type(frame.editBox.SetText) == 'function' then
        frame.editBox:SetText((type(importString) == 'string') and importString or '')
    end

    frame:Show()
end

local function TryImportWeakAurasString(importString)
    local wa = _G.WeakAuras
    if type(wa) ~= 'table' then
        return false, 'not_loaded'
    end

    local candidates = { 'Import', 'ImportString', 'ImportFromString' }
    for _, method in ipairs(candidates) do
        local fn = wa[method]
        if type(fn) == 'function' then
            do
                local ok, err = pcall(function() return fn(importString) end)
                if ok then return true end
                if type(err) == 'string' then
                    -- intentar variante con self
                    local ok2, err2 = pcall(function() return fn(wa, importString) end)
                    if ok2 then return true end
                    err = err2 or err
                end
                return false, tostring(err)
            end
        end
    end

    return false, 'no_api'
end

local function TryLoadBlizzardCooldownViewer()
    -- LOD: el Cooldown Manager / Advanced Cooldown Settings está implementado por Blizzard.
    if _G.IsAddOnLoaded and _G.IsAddOnLoaded('Blizzard_CooldownViewer') then
        return true
    end

    if _G.C_AddOns and type(_G.C_AddOns.LoadAddOn) == 'function' then
        local ok = pcall(function() return _G.C_AddOns.LoadAddOn('Blizzard_CooldownViewer') end)
        if ok then
            return _G.IsAddOnLoaded and _G.IsAddOnLoaded('Blizzard_CooldownViewer') or true
        end
    end

    if type(_G.UIParentLoadAddOn) == 'function' then
        local ok = pcall(function() return _G.UIParentLoadAddOn('Blizzard_CooldownViewer') end)
        if ok then
            return _G.IsAddOnLoaded and _G.IsAddOnLoaded('Blizzard_CooldownViewer') or true
        end
    end

    return false
end

local function TryAutoImportCooldownViewerLayout(importString)
    importString = (type(importString) == 'string' and importString ~= '') and importString or ''
    if importString == '' then
        return false, 'empty_string'
    end

    TryLoadBlizzardCooldownViewer()

    -- Habilitar el sistema si existe CVar.
    if _G.C_CVar and type(_G.C_CVar.SetCVar) == 'function' then
        pcall(function() _G.C_CVar.SetCVar('cooldownViewerEnabled', '1') end)
    end

    local api = _G.C_CooldownViewer
    if api and type(api.IsCooldownViewerAvailable) == 'function' then
        local ok, available, reason = pcall(function() return api.IsCooldownViewerAvailable() end)
        if ok and available == false then
            return false, tostring(reason or 'not_available')
        end
    end

    -- Camino 1 (preferido): Layout Manager (importa strings tipo "1|...==" y crea layouts).
    local settings = _G.CooldownViewerSettings
    if settings and type(settings.GetLayoutManager) == 'function' then
        local okLM, layoutManager = pcall(function() return settings:GetLayoutManager() end)
        if okLM and layoutManager and type(layoutManager.CreateLayoutsFromSerializedData) == 'function' then
            local okImport, layoutIDs = pcall(function()
                return layoutManager:CreateLayoutsFromSerializedData(importString)
            end)

            if okImport and type(layoutIDs) == 'table' and next(layoutIDs) ~= nil then
                return true, 'CooldownViewerLayoutManager:CreateLayoutsFromSerializedData', layoutIDs
            end
        end
    end

    -- Camino 2: Dialog mixin (si está disponible, devuelve layoutIDs creados).
    local dialog = _G.CooldownViewerImportLayoutDialog
    if dialog and type(dialog.ProcessImportText) == 'function' then
        local okDialog = pcall(function() dialog:ProcessImportText(importString) end)
        if okDialog then
            local ids = dialog.importedLayoutIDs
            if type(ids) == 'table' and next(ids) ~= nil then
                return true, 'CooldownViewerImportLayoutDialog:ProcessImportText', ids
            end
        end
    end

    -- Camino 3 (fallback best-effort): datastore completo (solo si podemos verificar que lo aplicó).
    if api and type(api.SetLayoutData) == 'function' and type(api.GetLayoutData) == 'function' then
        local trimmed = importString:gsub('^%s+', ''):gsub('%s+$', '')

        local okSet = pcall(function() api.SetLayoutData(trimmed) end)
        if okSet then
            local okGet, after = pcall(function() return api.GetLayoutData() end)
            if okGet and type(after) == 'string' then
                after = after:gsub('^%s+', ''):gsub('%s+$', '')
                if after == trimmed then
                    return true, 'C_CooldownViewer.SetLayoutData', nil
                end
            end
        end
    end

    return false, 'no_api'
end

local function GetCooldownViewerLayoutManager()
    local settings = _G.CooldownViewerSettings
    if settings and type(settings.GetLayoutManager) == 'function' then
        local okLM, layoutManager = pcall(function() return settings:GetLayoutManager() end)
        if okLM and type(layoutManager) == 'table' then
            return layoutManager
        end
    end
    return nil
end

local function SnapshotCooldownViewerLayouts()
    local layoutManager = GetCooldownViewerLayoutManager()
    if not layoutManager then return nil end

    local layouts
    if type(layoutManager.GetLayouts) == 'function' then
        local ok, r1 = pcall(function() return layoutManager:GetLayouts() end)
        if ok and type(r1) == 'table' then layouts = r1 end
    end
    if not layouts and type(layoutManager.GetAllLayouts) == 'function' then
        local ok, r1 = pcall(function() return layoutManager:GetAllLayouts() end)
        if ok and type(r1) == 'table' then layouts = r1 end
    end
    if not layouts and type(layoutManager.GetLayoutList) == 'function' then
        local ok, r1 = pcall(function() return layoutManager:GetLayoutList() end)
        if ok and type(r1) == 'table' then layouts = r1 end
    end
    if not layouts and type(layoutManager.layouts) == 'table' then
        layouts = layoutManager.layouts
    end

    if type(layouts) ~= 'table' then
        return nil
    end

    local out = { names = {}, ids = {}, byName = {}, raw = layouts }

    local function Add(id, index, name, obj)
        if type(name) == 'string' and name ~= '' then
            out.names[name] = id
            out.byName[name] = { id = id, index = index, obj = obj }
        end
        if id ~= nil then
            out.ids[id] = name
        end
    end

    -- Primero iterar como array para capturar índices fiables.
    for i, v in ipairs(layouts) do
        if type(v) == 'table' then
            local id = v.layoutID or v.layoutId or v.id or v.ID or i
            local name = v.name or v.layoutName or v.title
            Add(id, i, name, v)
        elseif type(v) == 'string' then
            Add(i, i, v, nil)
        end
    end

    -- Luego pairs para capturar variantes no-array.
    for k, v in pairs(layouts) do
        if type(v) == 'table' then
            local id = v.layoutID or v.layoutId or v.id or v.ID or k
            local name = v.name or v.layoutName or v.title
            if type(name) == 'string' and (not out.byName[name]) then
                Add(id, (type(k) == 'number' and k) or nil, name, v)
            end
        elseif type(v) == 'string' then
            if type(k) == 'number' and (not out.byName[v]) then
                Add(k, k, v, nil)
            end
        end
    end

    return out
end

local function TryDeleteCooldownViewerLayoutByID(layoutID)
    if layoutID == nil then return false end

    local layoutManager = GetCooldownViewerLayoutManager()
    local function TryMethods(obj, methods, arg)
        if type(obj) ~= 'table' then return false end
        for _, methodName in ipairs(methods) do
            local fn = obj[methodName]
            if type(fn) == 'function' then
                local ok = pcall(function() fn(obj, arg) end)
                if ok then return true end
            end
        end
        return false
    end

    if layoutManager and TryMethods(layoutManager, {
        'DeleteLayout',
        'DeleteLayoutID',
        'DeleteLayoutByID',
        'RemoveLayout',
        'RemoveLayoutID',
        'RemoveLayoutByID',
    }, layoutID) then
        return true
    end

    local api = _G.C_CooldownViewer
    if type(api) == 'table' then
        local fn = api.DeleteLayout or api.DeleteLayoutID or api.DeleteLayoutByID or api.RemoveLayout
        if type(fn) == 'function' then
            local ok = pcall(function() fn(layoutID) end)
            if ok then return true end
        end
    end

    return false
end

local function TrySelectCooldownViewerLayoutArg(selected)
    if selected == nil then return false end

    local function TryMethods(obj, methods, arg)
        if type(obj) ~= 'table' then return false end
        for _, methodName in ipairs(methods) do
            local fn = obj[methodName]
            if type(fn) == 'function' then
                local ok, r1 = pcall(function() return fn(obj, arg) end)
                -- Consideramos fallo SOLO si devuelve explícitamente false.
                if ok and r1 ~= false then
                    return true
                end
            end
        end
        return false
    end

    -- 1) LayoutManager (preferido)
    local layoutManager = GetCooldownViewerLayoutManager()
    if layoutManager then
        if TryMethods(layoutManager, {
            'SetActiveLayout',
            'SetActiveLayoutID',
            'SetSelectedLayout',
            'SetSelectedLayoutID',
            'SelectLayout',
            'SelectLayoutID',
            'ActivateLayout',
            'ActivateLayoutID',
        }, selected) then
            return true
        end
    end

    -- 2) API global (si existe)
    local api = _G.C_CooldownViewer
    if api then
        -- Algunas APIs son funciones sueltas, no métodos.
        local function TryFn(fnName, arg)
            local fn = api[fnName]
            if type(fn) == 'function' then
                local ok, r1 = pcall(function() return fn(arg) end)
                return ok and r1 ~= false
            end
            return false
        end

        if TryFn('SetActiveLayout', selected)
            or TryFn('SetActiveLayoutID', selected)
            or TryFn('SelectLayout', selected)
            or TryFn('SelectLayoutID', selected)
            or TryFn('ActivateLayout', selected)
            or TryFn('ActivateLayoutID', selected) then
            return true
        end
    end

    -- 3) Dialog (si está presente)
    local dialog = _G.CooldownViewerImportLayoutDialog
    if dialog and TryMethods(dialog, {
        'SetActiveLayout',
        'SetActiveLayoutID',
        'SetSelectedLayout',
        'SetSelectedLayoutID',
        'SelectLayout',
        'SelectLayoutID',
    }, selected) then
        return true
    end

    return false
end

local function TrySelectCooldownViewerLayout(layoutIDs)
    if type(layoutIDs) ~= 'table' then
        return false
    end

    local selected
    for _, id in ipairs(layoutIDs) do
        if id ~= nil then selected = id end
    end
    if selected == nil then
        -- Si no es un array, intentar con pairs.
        for _, id in pairs(layoutIDs) do
            if id ~= nil then selected = id break end
        end
    end

    return TrySelectCooldownViewerLayoutArg(selected)
end

local function TrySelectCooldownViewerLayoutByName(name)
    if type(name) ~= 'string' or name == '' then return false end
    local snap = SnapshotCooldownViewerLayouts()
    if not snap or type(snap.byName) ~= 'table' then return false end

    local entry = snap.byName[name]
    if type(entry) ~= 'table' then return false end

    -- Orden: ID -> índice -> objeto
    if entry.id ~= nil and TrySelectCooldownViewerLayoutArg(entry.id) then return true end
    if entry.index ~= nil and TrySelectCooldownViewerLayoutArg(entry.index) then return true end
    if entry.obj ~= nil and TrySelectCooldownViewerLayoutArg(entry.obj) then return true end

    return false
end

local function GetLuxthosInternalEnglishName(key)
    if type(key) ~= 'string' or key == '' then return nil end

    local classToken, specToken = key:match('^([a-z]+)_([a-z]+)_luxthos$')
    if type(classToken) ~= 'string' or type(specToken) ~= 'string' then
        return nil
    end

    local CLASS_EN = {
        deathknight = 'Death Knight',
        demonhunter = 'Demon Hunter',
        druid = 'Druid',
        evoker = 'Evoker',
        hunter = 'Hunter',
        mage = 'Mage',
        monk = 'Monk',
        paladin = 'Paladin',
        priest = 'Priest',
        rogue = 'Rogue',
        shaman = 'Shaman',
        warlock = 'Warlock',
        warrior = 'Warrior',
    }

    local SPEC_EN = {
        assassination = 'Assassination',
        affliction = 'Affliction',
        augmentation = 'Augmentation',
        arcane = 'Arcane',
        arms = 'Arms',
        balance = 'Balance',
        beastmastery = 'Beast Mastery',
        blood = 'Blood',
        brewmaster = 'Brewmaster',
        demonology = 'Demonology',
        destruction = 'Destruction',
        devastation = 'Devastation',
        devourer = 'Devourer',
        discipline = 'Discipline',
        elemental = 'Elemental',
        enhancement = 'Enhancement',
        feral = 'Feral',
        fire = 'Fire',
        frost = 'Frost',
        fury = 'Fury',
        guardian = 'Guardian',
        havoc = 'Havoc',
        holy = 'Holy',
        marksmanship = 'Marksmanship',
        mistweaver = 'Mistweaver',
        outlaw = 'Outlaw',
        preservation = 'Preservation',
        protection = 'Protection',
        restoration = 'Restoration',
        retribution = 'Retribution',
        shadow = 'Shadow',
        subtlety = 'Subtlety',
        survival = 'Survival',
        unholy = 'Unholy',
        vengeance = 'Vengeance',
        windwalker = 'Windwalker',
    }

    local classEN = CLASS_EN[classToken]
    local specEN = SPEC_EN[specToken]
    if type(classEN) ~= 'string' or type(specEN) ~= 'string' then
        return nil
    end

    return ('WoW (Luxthos) - %s: %s'):format(classEN, specEN)
end

local function TryRenameCooldownViewerLayoutByID(layoutID, newName)
    if layoutID == nil or type(newName) ~= 'string' or newName == '' then return false end

    local layoutManager = GetCooldownViewerLayoutManager()

    local function TryMethods(obj, methods, id, name)
        if type(obj) ~= 'table' then return false end
        for _, methodName in ipairs(methods) do
            local fn = obj[methodName]
            if type(fn) == 'function' then
                local ok = pcall(function() fn(obj, id, name) end)
                if ok then return true end
            end
        end
        return false
    end

    if layoutManager and TryMethods(layoutManager, {
        'RenameLayout',
        'RenameLayoutID',
        'RenameLayoutByID',
        'SetLayoutName',
        'SetLayoutNameByID',
        'SetNameForLayout',
        'SetNameForLayoutID',
    }, layoutID, newName) then
        return true
    end

    local api = _G.C_CooldownViewer
    if type(api) == 'table' then
        local fn = api.RenameLayout or api.RenameLayoutID or api.SetLayoutName or api.SetLayoutNameByID
        if type(fn) == 'function' then
            local ok = pcall(function() fn(layoutID, newName) end)
            if ok then return true end
        end
    end

    return false
end

function LizeUI:ImportLuxthos(key, label)
    key = (type(key) == 'string' and key ~= '') and key or ''
    label = (type(label) == 'string' and label ~= '') and label or 'WoW'

    local block = GetImportBlock(key)
    if not HasImportString(block) then
        PrintMsg(LTF('MSG_MISSING_IMPORT_STRING_FMT', label, key))
        return
    end

    local data = GetImportData(block)
    data = data:gsub('^%s+', ''):gsub('%s+$', '')

    -- Nombre interno estable (inglés), independientemente del idioma del cliente.
    -- La UI (botones/textos) puede seguir localizada usando `label`.
    local desiredLayoutName = GetLuxthosInternalEnglishName(key) or label

    local function DoLuxthosImport(skipDuplicateCheck)
        if not skipDuplicateCheck and type(desiredLayoutName) == 'string' and desiredLayoutName ~= '' then
            local snap = SnapshotCooldownViewerLayouts()
            if snap and type(snap.names) == 'table' and snap.names[desiredLayoutName] ~= nil then
                local existingID = snap.names[desiredLayoutName]
                ShowDuplicateNamePrompt(LT('POPUP_DUPLICATE_KIND_LAYOUT'), desiredLayoutName, function()
                    -- Sustituir: borrar existente (si podemos) y luego importar.
                    TryDeleteCooldownViewerLayoutByID(existingID)
                    DoLuxthosImport(true)
                end, function()
                    -- Cargar existente: seleccionar/activar.
                    if not TrySelectCooldownViewerLayoutByName(desiredLayoutName) then
                        TrySelectCooldownViewerLayout({ existingID })
                    end
                    PrintMsg(LTF('MSG_DUPLICATE_KEEP_SELECTED_FMT', LT('POPUP_DUPLICATE_KIND_LAYOUT'), desiredLayoutName))
                end)
                return true
            end
        end

        -- Intentar auto-import directo (Cooldown Manager). Si falla, fallback a copy/paste.
        PrintMsg(LTF('MSG_WOW_IMPORTING_FMT', label, #data))

        local ok, apiUsed, layoutIDsOrNil = TryAutoImportCooldownViewerLayout(data)
        if ok then
            -- Si el import creó layouts con IDs, intentar seleccionar el más reciente.
            if type(layoutIDsOrNil) == 'table' then
                -- Renombrar el layout importado al nombre interno estable (si es posible).
                local selected
                for _, id in ipairs(layoutIDsOrNil) do
                    if id ~= nil then selected = id end
                end
                if selected == nil then
                    for _, id in pairs(layoutIDsOrNil) do
                        if id ~= nil then selected = id break end
                    end
                end

                if selected ~= nil and type(desiredLayoutName) == 'string' and desiredLayoutName ~= '' then
                    TryRenameCooldownViewerLayoutByID(selected, desiredLayoutName)
                end
            end

            if not TrySelectCooldownViewerLayout(layoutIDsOrNil) and type(desiredLayoutName) == 'string' and desiredLayoutName ~= '' then
                -- Fallback: buscar el layout por nombre y seleccionarlo.
                local snap = SnapshotCooldownViewerLayouts()
                local id = snap and snap.names and snap.names[desiredLayoutName]
                if id ~= nil then
                    TrySelectCooldownViewerLayout({ id })
                end
            end
            return true
        end

        PrintMsg(LTF('MSG_WOW_AUTO_IMPORT_FAILED_FMT', label, tostring(apiUsed)))
        ShowImportCopyWindow(label, LT('COPYWIN_HELP_COOLDOWN_MANAGER'), data)
        return true
    end

    DoLuxthosImport(false)
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

    local function DefaultElvUIProfileNameForKey(k)
        if k == 'elvui_3k' then return 'LizeUI_3K' end
        if k == 'elvui_2k' then return 'LizeUI_2K' end
        if k == 'elvui_1k' then return 'LizeUI_1K' end
        return 'LizeUI'
    end

    local profileName = (type(block.profileName) == 'string' and block.profileName ~= '') and block.profileName
        or DefaultElvUIProfileNameForKey(key)

    local function GetElvUIProfilesTable()
        if E and type(E.data) == 'table' and type(E.data.profiles) == 'table' then
            return E.data.profiles
        end
        if E and E.db and type(E.db.profiles) == 'table' then
            return E.db.profiles
        end
        if type(_G.ElvDB) == 'table' and type(_G.ElvDB.profiles) == 'table' then
            return _G.ElvDB.profiles
        end
        return nil
    end

    local function ElvUIProfileExists(name)
        local profiles = GetElvUIProfilesTable()
        return type(profiles) == 'table' and type(profiles[name]) == 'table'
    end

    local function SelectElvUIProfile(name)
        if E and type(E.data) == 'table' and type(E.data.SetProfile) == 'function' then
            pcall(function() E.data:SetProfile(name) end)
            return
        end
        if E and type(E.db) == 'table' and type(E.db.SetProfile) == 'function' then
            pcall(function() E.db:SetProfile(name) end)
            return
        end
    end

    local function DeleteElvUIProfile(name)
        if E and type(E.data) == 'table' and type(E.data.DeleteProfile) == 'function' then
            pcall(function() E.data:DeleteProfile(name, true) end)
            return
        end

        if E and type(E.db) == 'table' and type(E.db.DeleteProfile) == 'function' then
            pcall(function() E.db:DeleteProfile(name, true) end)
            return
        end

        local profiles = GetElvUIProfilesTable()
        if type(profiles) == 'table' then
            profiles[name] = nil
        end
    end

    local data = GetImportData(block)

    if ElvUIProfileExists(profileName) then
        ShowDuplicateNamePrompt(LT('POPUP_DUPLICATE_KIND_PROFILE'), profileName, function()
            DeleteElvUIProfile(profileName)
            local ok, resultOrErr = pcall(function()
                return D:ImportProfile(data)
            end)

            if ok and resultOrErr ~= nil and resultOrErr ~= false then
                PrintMsg(LTF('MSG_PROFILE_IMPORTED_FMT', label))
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
        end, function()
            SelectElvUIProfile(profileName)
            PrintMsg(LTF('MSG_DUPLICATE_KEEP_SELECTED_FMT', LT('POPUP_DUPLICATE_KIND_PROFILE'), profileName))
        end)
        return
    end

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

    local profileName = (type(block.profileName) == 'string' and block.profileName ~= '') and block.profileName or 'LizeUI'
    local function WindToolsProfileExists(name)
        if W and W.db and type(W.db.profiles) == 'table' and type(W.db.profiles[name]) == 'table' then
            return true
        end
        return false
    end

    local function SelectWindToolsProfile(name)
        if W and W.db and type(W.db.SetProfile) == 'function' then
            pcall(function() W.db:SetProfile(name) end)
            return
        end
        if F and F.Profiles and type(F.Profiles.SetProfile) == 'function' then
            pcall(function() F.Profiles.SetProfile(name) end)
            return
        end
        if F and F.Profiles and type(F.Profiles.SwitchProfile) == 'function' then
            pcall(function() F.Profiles.SwitchProfile(name) end)
        end
    end

    local function DeleteWindToolsProfile(name)
        if W and W.db and type(W.db.DeleteProfile) == 'function' then
            pcall(function() W.db:DeleteProfile(name, true) end)
            return
        end
        if W and W.db and type(W.db.profiles) == 'table' then
            W.db.profiles[name] = nil
        end
    end

    local function DoWindToolsImport()
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

    if WindToolsProfileExists(profileName) then
        ShowDuplicateNamePrompt(LT('POPUP_DUPLICATE_KIND_PROFILE'), profileName, function()
            DeleteWindToolsProfile(profileName)
            DoWindToolsImport()
        end, function()
            SelectWindToolsProfile(profileName)
            PrintMsg(LTF('MSG_DUPLICATE_KEEP_SELECTED_FMT', LT('POPUP_DUPLICATE_KIND_PROFILE'), profileName))
        end)
        return
    end

    DoWindToolsImport()
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

    local function PlaterProfileExists(name)
        if plater and plater.db and type(plater.db.profiles) == 'table' and type(plater.db.profiles[name]) == 'table' then
            return true
        end
        if type(_G.PlaterDB) == 'table' and type(_G.PlaterDB.profiles) == 'table' and type(_G.PlaterDB.profiles[name]) == 'table' then
            return true
        end
        return false
    end

    local function SelectPlaterProfile(name)
        if plater and plater.db and type(plater.db.SetProfile) == 'function' then
            pcall(function() plater.db:SetProfile(name) end)
            return
        end
        if plater and type(plater.SwitchProfile) == 'function' then
            pcall(function() plater:SwitchProfile(name) end)
        end
    end

    local function DeletePlaterProfile(name)
        if plater and plater.db and type(plater.db.DeleteProfile) == 'function' then
            pcall(function() plater.db:DeleteProfile(name, true) end)
            return
        end
        if plater and plater.db and type(plater.db.profiles) == 'table' then
            plater.db.profiles[name] = nil
        end
        if type(_G.PlaterDB) == 'table' and type(_G.PlaterDB.profiles) == 'table' then
            _G.PlaterDB.profiles[name] = nil
        end
    end

    local function DoPlaterImport()
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

    if PlaterProfileExists(profileName) then
        ShowDuplicateNamePrompt(LT('POPUP_DUPLICATE_KIND_PROFILE'), profileName, function()
            DeletePlaterProfile(profileName)
            DoPlaterImport()
        end, function()
            SelectPlaterProfile(profileName)
            PrintMsg(LTF('MSG_DUPLICATE_KEEP_SELECTED_FMT', LT('POPUP_DUPLICATE_KIND_PROFILE'), profileName))
        end)
        return
    end

    DoPlaterImport()
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

    local function TryAutoImportEditModeLayout(str, desiredName, opts)
        opts = (type(opts) == 'table') and opts or {}
        local duplicateAction = (type(opts.duplicateAction) == 'string' and opts.duplicateAction ~= '') and opts.duplicateAction or 'unique'

        local api = _G.C_EditMode
        if not (api and type(api) == 'table') then
            return false, LT('REASON_EDITMODE_API_UNAVAILABLE')
        end

        local before = SnapshotLayouts()
        local existsIndex = before and before.names and desiredName and before.names[desiredName] or nil

        local apiUsed

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

        local function DeleteLayoutByName(name)
            if type(name) ~= 'string' or name == '' then return false end
            if type(api.DeleteLayout) == 'function' then
                local okDel = pcall(function() api.DeleteLayout(name) end)
                if okDel then return true end
            end
            if type(api.RemoveLayout) == 'function' then
                local okDel = pcall(function() api.RemoveLayout(name) end)
                if okDel then return true end
            end

            if type(api.GetLayouts) ~= 'function' or type(api.SaveLayouts) ~= 'function' then
                return false
            end

            local ok, layoutInfo = pcall(function() return api.GetLayouts() end)
            if not ok or type(layoutInfo) ~= 'table' or type(layoutInfo.layouts) ~= 'table' then
                return false
            end

            local idx
            for i, v in ipairs(layoutInfo.layouts) do
                if type(v) == 'table' then
                    local n = v.layoutName or v.name
                    if n == name then
                        idx = i
                        break
                    end
                end
            end
            if not idx then return false end

            table.remove(layoutInfo.layouts, idx)

            if type(layoutInfo.activeLayout) == 'number' then
                if layoutInfo.activeLayout == idx then
                    layoutInfo.activeLayout = math.max(1, math.min(layoutInfo.activeLayout, #layoutInfo.layouts))
                elseif layoutInfo.activeLayout > idx then
                    layoutInfo.activeLayout = layoutInfo.activeLayout - 1
                end
            end

            local okSave = pcall(function() api.SaveLayouts(layoutInfo) end)
            if okSave then
                TryApplyEditModeChanges()
            end
            return okSave and true or false
        end

        if existsIndex and duplicateAction == 'keep' then
            apiUsed = 'existing'
            local selected = ForceSelectLayoutByName(desiredName)
            if selected then
                return true, apiUsed, existsIndex, desiredName
            end
            return false, LT('REASON_EDITMODE_API_UNAVAILABLE')
        end

        if existsIndex and duplicateAction == 'replace' then
            DeleteLayoutByName(desiredName)
            before = SnapshotLayouts()
            existsIndex = before and before.names and desiredName and before.names[desiredName] or nil
        end

        local finalName = desiredName
        if (not existsIndex) or duplicateAction == 'replace' then
            finalName = desiredName
        else
            finalName = MakeUniqueLayoutName(desiredName, before)
        end
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
                    base.layoutType = _G.Enum.EditModeLayoutType.Account
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

    local function HandleAutoResult(okAuto, apiOrReason, layoutID, savedName)
        if okAuto then
            if tostring(apiOrReason) == 'existing' then
                PrintMsg(LTF('MSG_DUPLICATE_KEEP_SELECTED_FMT', LT('POPUP_DUPLICATE_KIND_LAYOUT'), baseName))
            else
                if layoutID ~= nil then
                    PrintMsg(LTF('MSG_WOW_LAYOUT_IMPORTED_API_ID_FMT', label, tostring(apiOrReason), tostring(layoutID)))
                else
                    PrintMsg(LTF('MSG_WOW_LAYOUT_IMPORTED_API_FMT', label, tostring(apiOrReason)))
                end
                if type(savedName) == 'string' and savedName ~= '' then
                    PrintMsg(LTF('MSG_WOW_LAYOUT_SAVED_NAME_FMT', savedName))
                end
            end
            PrintMsg(LT('MSG_WOW_VISUAL_HINT'))
            return true
        end

        PrintMsg(LTF('MSG_WOW_AUTO_IMPORT_FAILED_FMT', label, tostring(apiOrReason)))
        PrintMsg(LT('MSG_WOW_COPY_PASTE_HELP'))
        return false
    end

    local snap = SnapshotLayouts()
    if snap and type(snap.names) == 'table' and snap.names[baseName] then
        ShowDuplicateNamePrompt(LT('POPUP_DUPLICATE_KIND_LAYOUT'), baseName, function()
            local okAuto, apiOrReason, layoutID, savedName = TryAutoImportEditModeLayout(layoutString, baseName, { duplicateAction = 'replace' })
            HandleAutoResult(okAuto, apiOrReason, layoutID, savedName)
        end, function()
            local okAuto, apiOrReason, layoutID, savedName = TryAutoImportEditModeLayout(layoutString, baseName, { duplicateAction = 'keep' })
            HandleAutoResult(okAuto, apiOrReason, layoutID, savedName)
        end)
        return
    end

    local okAuto, apiOrReason, layoutID, savedName = TryAutoImportEditModeLayout(layoutString, baseName, { duplicateAction = 'unique' })
    HandleAutoResult(okAuto, apiOrReason, layoutID, savedName)
    return
end

function LizeUI:ImportBetterCooldownManager(variant)
    local key = nil
    if type(variant) == 'string' then
        local v = string.lower(variant)
        if v == 'all' or v == 'default' then
            key = 'betterCooldownManager_all'
        elseif v == 'mana' or v == 'resources' then
            key = 'betterCooldownManager_mana'
        elseif v == 'no-mana' or v == 'no_mana' or v == 'nomana' or v == 'class' or v == 'classbar' then
            key = 'betterCooldownManager_no_mana'
        elseif GetImportBlock(v) then
            key = v
        end
    end

    if key == nil then
        -- Preferir la variante "all" si existe; fallback al key antiguo.
        local tryAll = GetImportBlock('betterCooldownManager_all')
        if tryAll and HasImportString(tryAll) then
            key = 'betterCooldownManager_all'
        else
            key = 'betterCooldownManager'
        end
    end

    local block = GetImportBlock(key)
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

    local bcm = _G.BCDMG

    local function BCDMProfileExists(name)
        if bcm and bcm.db and type(bcm.db.profiles) == 'table' and type(bcm.db.profiles[name]) == 'table' then
            return true
        end
        return false
    end

    local function SelectBCDMProfile(name)
        if bcm and bcm.db and type(bcm.db.SetProfile) == 'function' then
            pcall(function() bcm.db:SetProfile(name) end)
        end
    end

    local function DeleteBCDMProfile(name)
        if bcm and bcm.db and type(bcm.db.DeleteProfile) == 'function' then
            pcall(function() bcm.db:DeleteProfile(name, true) end)
            return
        end
        if bcm and bcm.db and type(bcm.db.profiles) == 'table' then
            bcm.db.profiles[name] = nil
        end
    end

    local function DoBCDMImport()
        local ok, err = pcall(function()
            bcm:ImportBCDM(data, profileName)
        end)

        if ok then
            PrintMsg(LT('MSG_BCDM_IMPORTED'))
            SelectBCDMProfile(profileName)
        else
            PrintMsg(LTF('MSG_BCDM_IMPORT_ERROR_FMT', tostring(err)))
        end
    end

    if BCDMProfileExists(profileName) then
        ShowDuplicateNamePrompt(LT('POPUP_DUPLICATE_KIND_PROFILE'), profileName, function()
            DeleteBCDMProfile(profileName)
            DoBCDMImport()
        end, function()
            SelectBCDMProfile(profileName)
            PrintMsg(LTF('MSG_DUPLICATE_KEEP_SELECTED_FMT', LT('POPUP_DUPLICATE_KIND_PROFILE'), profileName))
        end)
        return
    end

    DoBCDMImport()
end

function LizeUI:ImportDetails()
    local block = GetImportBlock('details')
    if not HasImportString(block) then
        PrintMsg(LT('MSG_DETAILS_MISSING_STRING'))
        return
    end

    local details = _G.Details or _G._detalhes
    if type(details) ~= 'table' then
        PrintMsg(LT('MSG_DETAILS_NOT_LOADED'))
        return
    end

    local data = GetImportData(block)

    local function SafeCall(label, fn)
        local ok, r1, r2, r3, r4 = pcall(fn)
        if not ok then
            return false, ('%s: %s'):format(label, tostring(r1))
        end
        return true, r1, r2, r3, r4
    end

    local function GetDetailsProfilesTable()
        if details and type(details) == 'table' then
            if details.db and type(details.db.profiles) == 'table' then
                return details.db.profiles
            end
            if type(details.database) == 'table' and type(details.database.profiles) == 'table' then
                return details.database.profiles
            end
        end

        if type(_G._detalhes_database) == 'table' and type(_G._detalhes_database.profiles) == 'table' then
            return _G._detalhes_database.profiles
        end

        return nil
    end

    local function FindDetailsProfileDB()
        local function IsAceDBLike(db)
            return type(db) == 'table' and type(db.GetProfiles) == 'function' and type(db.SetProfile) == 'function'
        end

        if IsAceDBLike(details and details.db) then return details.db end
        if IsAceDBLike(details and details.database) then return details.database end
        if IsAceDBLike(details and details.profileDB) then return details.profileDB end
        if IsAceDBLike(details and details.ProfileDB) then return details.ProfileDB end
        if IsAceDBLike(details and details.profile_db) then return details.profile_db end

        -- Heurística: buscar en campos de Details una db tipo AceDB (máx profundidad 2)
        if type(details) == 'table' then
            for _, v in pairs(details) do
                if IsAceDBLike(v) then
                    return v
                end
            end
            for _, v in pairs(details) do
                if type(v) == 'table' then
                    for _, vv in pairs(v) do
                        if IsAceDBLike(vv) then
                            return vv
                        end
                    end
                end
            end
        end

        return nil
    end

    local function DeepFindProfileName(root, name, maxDepth)
        if type(root) ~= 'table' or type(name) ~= 'string' or name == '' then
            return false
        end

        maxDepth = (type(maxDepth) == 'number' and maxDepth > 0) and maxDepth or 4
        local visited = {}

        local function Scan(tbl, depth)
            if depth > maxDepth or type(tbl) ~= 'table' then return false end
            if visited[tbl] then return false end
            visited[tbl] = true

            -- Match directo por clave
            if rawget(tbl, name) ~= nil then
                return true
            end

            for k, v in pairs(tbl) do
                if type(v) == 'string' then
                    -- Algunas estructuras guardan listas de nombres como strings.
                    if v == name then
                        return true
                    end
                elseif type(v) == 'table' then
                    -- Algunas estructuras guardan perfiles como entradas con campo "name".
                    local vn = rawget(v, 'name') or rawget(v, 'profile_name') or rawget(v, 'profile') or rawget(v, 'profileName')
                    if vn == name then
                        return true
                    end

                    -- Atajo para claves comunes
                    if k == 'profiles' or k == 'profile' or k == 'profile_data' or k == 'saved_profiles' or k == 'profiles_saved' then
                        if rawget(v, name) ~= nil then
                            return true
                        end
                    end

                    if Scan(v, depth + 1) then
                        return true
                    end
                end
            end

            return false
        end

        return Scan(root, 0)
    end

    local function DetailsProfileExists(name)
        if type(name) ~= 'string' or name == '' then return false end

        local profiles = GetDetailsProfilesTable()
        if type(profiles) == 'table' and rawget(profiles, name) ~= nil then
            return true
        end

        -- Fallback: usar AceDB (en Details puede no ser details.db)
        local profileDB = FindDetailsProfileDB()
        if profileDB and type(profileDB.GetProfiles) == 'function' then
            local ok, list = pcall(function()
                local t = {}
                profileDB:GetProfiles(t)
                return t
            end)
            if ok and type(list) == 'table' then
                for _, n in ipairs(list) do
                    if n == name then return true end
                end
            end
        end

        -- Último recurso: buscar el nombre en la base de datos de Details (hay variantes entre builds).
        if type(_G._detalhes_database) == 'table' and DeepFindProfileName(_G._detalhes_database, name, 4) then
            return true
        end
        if details and type(details.database) == 'table' and DeepFindProfileName(details.database, name, 4) then
            return true
        end
        if details and details.db and type(details.db) == 'table' and DeepFindProfileName(details.db, name, 3) then
            return true
        end

        return false
    end

    local function TryApplyDetailsProfile(profileName)
        local applied = false

        -- Muchas builds usan AceDB en details.db
        if details.db and type(details.db.SetProfile) == 'function' then
            -- Importante: NO crear un perfil vacío si el import no lo generó.
            if DetailsProfileExists(profileName) then
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

    local function SelectDetailsProfile(name)
        TryApplyDetailsProfile(name)
    end

    local function DeleteDetailsProfile(name)
        local profileDB = FindDetailsProfileDB()
        if profileDB and type(profileDB.DeleteProfile) == 'function' then
            pcall(function() profileDB:DeleteProfile(name, true) end)
            return
        end
        if details.db and type(details.db.DeleteProfile) == 'function' then
            pcall(function() details.db:DeleteProfile(name, true) end)
            return
        end

        local profiles = GetDetailsProfilesTable()
        if type(profiles) == 'table' then
            profiles[name] = nil
        end
    end

    local importedProfileName
    local importLabel
    local ok, r1
    local err

    local function IsSuccessfulReturn(v)
        -- Muchas APIs devuelven true, o el nombre de perfil, o una tabla.
        -- Si devuelve nil/false, normalmente significa que la string no es válida.
        if v == nil or v == false then return false end
        return true
    end

    local function DoDetailsImport()
        importedProfileName = nil
        importLabel = nil
        ok, r1 = nil, nil
        err = nil

        local dataLen = #data
        local head = string.sub(data, 1, 12)
        local tail = string.sub(data, math.max(1, dataLen - 11), dataLen)
        PrintMsg(LTF('MSG_DETAILS_STRING_INFO_FMT', dataLen, tostring(head), tostring(tail)))

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

    if DetailsProfileExists(desiredProfileName) then
        ShowDuplicateNamePrompt(LT('POPUP_DUPLICATE_KIND_PROFILE'), desiredProfileName, function()
            DeleteDetailsProfile(desiredProfileName)
            DoDetailsImport()
        end, function()
            SelectDetailsProfile(desiredProfileName)
            PrintMsg(LTF('MSG_DUPLICATE_KEEP_SELECTED_FMT', LT('POPUP_DUPLICATE_KIND_PROFILE'), desiredProfileName))
        end)
        return
    end

    DoDetailsImport()
end
