-- Installer.lua: lógica del instalador (PluginInstaller de ElvUI)

local _, ns = ...

local E = ns.E
local LizeUI = ns.LizeUI
local LT = ns.LT
local PrintMsg = ns.PrintMsg
local ADDON_PATH = ns.ADDON_PATH

local S = (E and type(E.GetModule) == 'function') and E:GetModule('Skins', true) or nil

local OK_ICON = ADDON_PATH .. 'media\\textures\\icons\\ok.tga'
local ERROR_ICON = ADDON_PATH .. 'media\\textures\\icons\\error.tga'
local NO_ACTIVE_ICON = ADDON_PATH .. 'media\\textures\\icons\\no-active.tga'

local COPY_URL_POPUP = 'LIZEUI_EDITBOX'

local function EnsureCopyUrlPopup()
    if not (E and type(E) == 'table') then return false end
    E.PopupDialogs = E.PopupDialogs or {}
    if E.PopupDialogs[COPY_URL_POPUP] then return true end

    E.PopupDialogs[COPY_URL_POPUP] = {
        text = 'LizeUI',
        button1 = _G.OKAY,
        hasEditBox = 1,
        OnShow = function(self, data)
            if not (self and self.EditBox and data) then return end
            self.EditBox:SetAutoFocus(false)
            self.EditBox.width = self.EditBox:GetWidth()
            self.EditBox:Width(280)
            self.EditBox:AddHistoryLine('text')
            self.EditBox.temptxt = data
            self.EditBox:SetText(data)
            self.EditBox:HighlightText()
            self.EditBox:SetJustifyH('CENTER')
        end,
        OnHide = function(self)
            if not (self and self.EditBox) then return end
            self.EditBox:Width(self.EditBox.width or 50)
            self.EditBox.width = nil
            self.temptxt = nil
        end,
        EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
        EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
        EditBoxOnTextChanged = function(self)
            if not (self and self.temptxt) then return end
            if self:GetText() ~= self.temptxt then
                self:SetText(self.temptxt)
            end
            self:HighlightText()
            self:ClearFocus()
        end,
        OnAccept = E.noop,
        whileDead = 1,
        preferredIndex = 3,
        hideOnEscape = 1,
    }

    return true
end

local function ShowCopyUrl(url, label)
    if type(url) ~= 'string' or url == '' then return end

    local popupText
    local fmt = LT('INSTALL_DEPS_COPY_TEXT_FMT')
    if type(fmt) == 'string' and fmt:find('%%s') then
        popupText = string.format(fmt, label or 'LizeUI')
    else
        popupText = tostring(label or 'LizeUI')
    end

    if EnsureCopyUrlPopup() and E and type(E.StaticPopup_Show) == 'function' then
        if E.PopupDialogs and E.PopupDialogs[COPY_URL_POPUP] then
            E.PopupDialogs[COPY_URL_POPUP].text = popupText
        end
        E:StaticPopup_Show(COPY_URL_POPUP, nil, nil, url)
        return
    end

    local show = _G.StaticPopup_Show
    if type(show) == 'function' then
        if _G.StaticPopupDialogs and _G.StaticPopupDialogs[COPY_URL_POPUP] then
            _G.StaticPopupDialogs[COPY_URL_POPUP].text = popupText
        end
        show(COPY_URL_POPUP, url)
    end
end

local function NormalizeEnableState(state)
    if type(state) == 'number' then return state end
    if type(state) == 'boolean' then return state and 1 or 0 end
    if type(state) == 'string' then return tonumber(state) end
    return nil
end

local function GetAddOnInfoSafe(addonFolder)
    local getInfo = (C_AddOns and C_AddOns.GetAddOnInfo) or _G.GetAddOnInfo
    if type(getInfo) ~= 'function' then return nil end

    local ok, r1, r2, r3, r4, r5, r6 = pcall(getInfo, addonFolder)
    if not ok then return nil end

    if type(r1) == 'table' then
        local t = r1
        local name = t.name or t.Name or addonFolder
        local title = t.title or t.Title
        local notes = t.notes or t.Notes
        local loadable = t.loadable
        local reason = t.reason
        local security = t.security
        return name, title, notes, loadable, reason, security
    end

    return r1, r2, r3, r4, r5, r6
end

local function GetAddOnEnableStateSafe(addonFolder)
    local char = (_G.UnitName and _G.UnitName('player')) or nil

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
    local name, _, _, loadable, reason = GetAddOnInfoSafe(addonFolder)
    if (type(reason) == 'string' and reason == 'MISSING') or type(name) ~= 'string' or name == '' then
        return 'missing'
    end

    local state = GetAddOnEnableStateSafe(addonFolder)
    if state ~= nil then
        if state > 0 then return 'ok' end
        return 'inactive'
    end

    local loaded = IsAddOnLoadedSafe(addonFolder)
    if loaded == true then return 'ok' end

    if type(reason) == 'string' and reason == 'DISABLED' then
        return 'inactive'
    end

    if loadable == true then
        return 'ok'
    end

    return 'inactive'
end

local function StatusIcon(addonFolder)
    local status = GetAddonStatus(addonFolder)
    if status == 'ok' then return OK_ICON end
    if status == 'inactive' then return NO_ACTIVE_ICON end
    return ERROR_ICON
end

-- Logo grande para el instalador
local BIG_LOGO = (type(ADDON_PATH) == 'string' and ADDON_PATH ~= '')
    and (ADDON_PATH .. 'media\\textures\\icons\\lizeui_grande.tga')
    or nil

local function EnsureInstallDefaults()
    if type(_G.LizeUIDB) ~= 'table' then
        _G.LizeUIDB = {}
    end

    if _G.LizeUIDB.welcomePromptAccepted == nil then
        _G.LizeUIDB.welcomePromptAccepted = false
    end

    -- Debug del instalador (imprime una sola vez por sesión cuando está activado)
    if _G.LizeUIDB.debugInstaller == nil then
        _G.LizeUIDB.debugInstaller = false
    end
end

local function ApplyUIScale(value, applyNow)
    if type(value) ~= 'number' then return end
    if not (E and type(E) == 'table') then return end
    if not (E.global and E.global.general) then return end

    E.global.general.UIScale = value

    if applyNow and type(E.PixelScaleChanged) == 'function' then
        pcall(E.PixelScaleChanged, E)
    end
end

local function HideScaleControls(f)
    if not f then return end
    if f.LizeUIScaleSlider and type(f.LizeUIScaleSlider.Hide) == 'function' then
        f.LizeUIScaleSlider:Hide()
    end
end

local function EnsureScaleControls(f)
    if not f then return end
    if f.LizeUIScaleSlider then return end

    local slider = CreateFrame('Slider', nil, f)
    f.LizeUIScaleSlider = slider

    slider:SetOrientation('HORIZONTAL')
    if type(slider.Height) == 'function' then
        slider:Height(15)
        slider:Width(400)
    else
        slider:SetHeight(15)
        slider:SetWidth(400)
    end

    if type(slider.SetHitRectInsets) == 'function' then
        slider:SetHitRectInsets(0, 0, -10, 0)
    end

    slider:ClearAllPoints()
    slider:Point('CENTER', f, 'CENTER', 0, 60)

    if S and type(S.HandleSliderFrame) == 'function' then
        S:HandleSliderFrame(slider)
    end

    slider.Min = slider:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
    slider.Min:Point('RIGHT', slider, 'LEFT', -3, 0)
    slider.Max = slider:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
    slider.Max:Point('LEFT', slider, 'RIGHT', 3, 0)
    slider.Cur = slider:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
    slider.Cur:Point('BOTTOM', slider, 'TOP', 0, 10)
    if type(slider.Cur.FontTemplate) == 'function' then
        slider.Cur:FontTemplate(nil, 22)
    end

    slider.Min:SetText('')
    slider.Max:SetText('')
    slider.Cur:SetText('')

    slider:Hide()
end

function LizeUI:ShowInstallWindow(force)
    EnsureInstallDefaults()

    if not force and _G.LizeUIDB.welcomePromptAccepted == true then return end
    if self._lizeuiWelcomeShown and not force then return end

    if type(_G.InCombatLockdown) == 'function' and _G.InCombatLockdown() then
        return
    end

    local PI = (E and type(E.GetModule) == 'function') and E:GetModule('PluginInstaller', true) or nil
    if not (PI and type(PI.Queue) == 'function') then
        return
    end

    self._lizeuiWelcomeShown = true

    -- Marcamos como aceptado al abrir (para que no moleste repetidamente).
    if not force then
        _G.LizeUIDB.welcomePromptAccepted = true
    end

    local function Page1()
        local f = _G.PluginInstallFrame
        if not f then return end

        local ok, err = pcall(function()
            HideScaleControls(f)
            local function ForceVisible(fs)
                if not fs then return end
                if type(fs.Show) == 'function' then fs:Show() end
                if type(fs.SetAlpha) == 'function' then fs:SetAlpha(1) end
                if type(fs.SetDrawLayer) == 'function' then fs:SetDrawLayer('OVERLAY', 5) end
                if type(fs.SetTextColor) == 'function' then fs:SetTextColor(1, 1, 1) end
            end

            -- Logo arriba
            if BIG_LOGO and f.tutorialImage then
                f.tutorialImage:SetTexture(BIG_LOGO)
                if type(f.tutorialImage.SetDrawLayer) == 'function' then
                    f.tutorialImage:SetDrawLayer('ARTWORK', 0)
                end
                if type(f.tutorialImage.SetVertexColor) == 'function' then
                    f.tutorialImage:SetVertexColor(1, 1, 1)
                end
                if type(f.tutorialImage.SetAlpha) == 'function' then
                    f.tutorialImage:SetAlpha(1)
                end
                f.tutorialImage:ClearAllPoints()
                if type(f.tutorialImage.Size) == 'function' then
                    f.tutorialImage:Size(256, 128)
                else
                    f.tutorialImage:SetSize(256, 128)
                end
                f.tutorialImage:Point('TOP', f, 'TOP', 0, -30)
                f.tutorialImage:Show()
            end

            if f.tutorialImage2 and type(f.tutorialImage2.Hide) == 'function' then
                f.tutorialImage2:Hide()
            end

            if f.SubTitle then
                f.SubTitle:ClearAllPoints()
                if f.tutorialImage and f.tutorialImage:IsShown() then
                    f.SubTitle:Point('TOP', f.tutorialImage, 'BOTTOM', 0, -10)
                else
                    f.SubTitle:Point('TOP', 0, -40)
                end
                ForceVisible(f.SubTitle)
            end

            -- Un poco más de alto para que no quede todo tan justo
            if type(f.Size) == 'function' then
                f:Size(550, 420)
            elseif type(f.SetSize) == 'function' then
                f:SetSize(550, 420)
            end

            if f.Desc1 then
                f.Desc1:ClearAllPoints()
                -- Más alto para aprovechar el espacio (y evitar que el texto “se salga”)
                f.Desc1:Point('TOPLEFT', 20, -185)
                if type(f.Desc1.Width) == 'function' then
                    f.Desc1:Width(f:GetWidth() - 40)
                elseif type(f.Desc1.SetWidth) == 'function' then
                    f.Desc1:SetWidth(f:GetWidth() - 40)
                end
                if type(f.Desc1.FontTemplate) == 'function' then
                    f.Desc1:FontTemplate(nil, 13)
                end
                if type(f.Desc1.SetJustifyH) == 'function' then
                    f.Desc1:SetJustifyH('CENTER')
                end
                if type(f.Desc1.SetJustifyV) == 'function' then
                    f.Desc1:SetJustifyV('TOP')
                end
                ForceVisible(f.Desc1)
            end

            if f.SubTitle then f.SubTitle:SetText(LT('INSTALL_SUBTITLE')) end
            if f.Desc1 then f.Desc1:SetText(LT('INSTALL_DESC1')) end

            -- Sin botones en esta página
            if f.Option1 then f.Option1:SetScript('OnClick', nil) f.Option1:Hide() end
            if f.Option2 then f.Option2:SetScript('OnClick', nil) f.Option2:Hide() end
            if f.Option3 then f.Option3:SetScript('OnClick', nil) f.Option3:Hide() end
            if f.Option4 then f.Option4:SetScript('OnClick', nil) f.Option4:Hide() end

            -- Ocultar UI custom de la Page4 (si existe)
            if f.LizeUIDepsList then f.LizeUIDepsList:Hide() end
            if f.LizeUIFinishButton then f.LizeUIFinishButton:Hide() end
            if f.LizeUIRecsList then f.LizeUIRecsList:Hide() end

            -- En esta página usamos un solo bloque de texto (evita overflow vertical)
            if f.Desc2 then f.Desc2:SetText('') if type(f.Desc2.Hide) == 'function' then f.Desc2:Hide() end end
            if f.Desc3 then f.Desc3:SetText('') if type(f.Desc3.Hide) == 'function' then f.Desc3:Hide() end end
            if f.Desc4 then f.Desc4:SetText('') if type(f.Desc4.Hide) == 'function' then f.Desc4:Hide() end end
        end)

        -- Diagnóstico (una sola vez por sesión)
        if not ok then
            if not self._lizeuiInstallPage1ErrorPrinted then
                self._lizeuiInstallPage1ErrorPrinted = true
                local msg = 'LizeUI: Installer Page1 error: ' .. tostring(err)
                if PrintMsg then
                    PrintMsg(msg)
                elseif _G.print then
                    _G.print(msg)
                end
            end
            return
        end

        if _G.LizeUIDB and _G.LizeUIDB.debugInstaller == true and not self._lizeuiInstallPage1DebugPrinted then
            self._lizeuiInstallPage1DebugPrinted = true

            local function FSInfo(fs)
                if not fs then return 'nil' end
                local txt = (type(fs.GetText) == 'function') and fs:GetText() or nil
                local len = (type(txt) == 'string') and #txt or 0
                local shown = (type(fs.IsShown) == 'function') and fs:IsShown() or false
                local a = (type(fs.GetAlpha) == 'function') and fs:GetAlpha() or -1
                return string.format('shown=%s alpha=%.2f len=%d', tostring(shown), tonumber(a) or -1, len)
            end

            local msg = 'LizeUI: Installer Page1 debug: SubTitle(' .. FSInfo(f.SubTitle) .. ') Desc1(' .. FSInfo(f.Desc1) .. ')'
            if PrintMsg then
                PrintMsg(msg)
            elseif _G.print then
                _G.print(msg)
            end
        end
    end

    local function Page2()
        local f = _G.PluginInstallFrame
        if not f then return end

        local ok, err = pcall(function()
            local function StripKLabelSuffix(s)
                if type(s) ~= 'string' then return s end
                -- Convierte "... (3K)" -> "..." (mantenemos la resolución ya incluida en el texto)
                s = s:gsub('%s*%(%s*[123]%s*[Kk]%s*%)%s*$', '')
                return s
            end

            local function ForceVisible(fs)
                if not fs then return end
                if type(fs.Show) == 'function' then fs:Show() end
                if type(fs.SetAlpha) == 'function' then fs:SetAlpha(1) end
                if type(fs.SetDrawLayer) == 'function' then fs:SetDrawLayer('OVERLAY', 5) end
                if type(fs.SetTextColor) == 'function' then fs:SetTextColor(1, 1, 1) end
            end

            -- Mantenemos el logo de la página 1
            if BIG_LOGO and f.tutorialImage then
                f.tutorialImage:SetTexture(BIG_LOGO)
                if type(f.tutorialImage.SetDrawLayer) == 'function' then
                    f.tutorialImage:SetDrawLayer('ARTWORK', 0)
                end
                if type(f.tutorialImage.SetVertexColor) == 'function' then
                    f.tutorialImage:SetVertexColor(1, 1, 1)
                end
                if type(f.tutorialImage.SetAlpha) == 'function' then
                    f.tutorialImage:SetAlpha(1)
                end
                f.tutorialImage:ClearAllPoints()
                if type(f.tutorialImage.Size) == 'function' then
                    f.tutorialImage:Size(256, 128)
                else
                    f.tutorialImage:SetSize(256, 128)
                end
                f.tutorialImage:Point('TOP', f, 'TOP', 0, -30)
                f.tutorialImage:Show()
            end
            if f.tutorialImage2 and type(f.tutorialImage2.Hide) == 'function' then
                f.tutorialImage2:Hide()
            end

            if f.SubTitle then
                f.SubTitle:ClearAllPoints()
                if f.tutorialImage and f.tutorialImage:IsShown() then
                    f.SubTitle:Point('TOP', f.tutorialImage, 'BOTTOM', 0, -10)
                else
                    f.SubTitle:Point('TOP', 0, -40)
                end
                ForceVisible(f.SubTitle)
            end

            if type(f.Size) == 'function' then
                f:Size(550, 420)
            elseif type(f.SetSize) == 'function' then
                f:SetSize(550, 420)
            end

            if f.Desc1 then
                f.Desc1:ClearAllPoints()
                if f.SubTitle and type(f.SubTitle.IsShown) == 'function' and f.SubTitle:IsShown() then
                    f.Desc1:Point('TOP', f.SubTitle, 'BOTTOM', 0, -10)
                else
                    f.Desc1:Point('TOP', 0, -185)
                end
                if type(f.Desc1.Width) == 'function' then
                    f.Desc1:Width(f:GetWidth() - 40)
                elseif type(f.Desc1.SetWidth) == 'function' then
                    f.Desc1:SetWidth(f:GetWidth() - 40)
                end
                if type(f.Desc1.FontTemplate) == 'function' then
                    f.Desc1:FontTemplate(nil, 13)
                end
                if type(f.Desc1.SetJustifyH) == 'function' then
                    f.Desc1:SetJustifyH('CENTER')
                end
                if type(f.Desc1.SetJustifyV) == 'function' then
                    f.Desc1:SetJustifyV('TOP')
                end
                ForceVisible(f.Desc1)
            end

            -- Solo un bloque de texto en esta página
            if f.Desc2 then f.Desc2:SetText('') if type(f.Desc2.Hide) == 'function' then f.Desc2:Hide() end end
            if f.Desc3 then f.Desc3:SetText('') if type(f.Desc3.Hide) == 'function' then f.Desc3:Hide() end end
            if f.Desc4 then f.Desc4:SetText('') if type(f.Desc4.Hide) == 'function' then f.Desc4:Hide() end end

            if f.SubTitle then f.SubTitle:SetText(LT('OPT_ELVUI_IMPORTS_TITLE')) end
            if f.Desc1 then f.Desc1:SetText(LT('OPT_ELVUI_IMPORTS_DESC')) end

            -- Ocultar UI custom de la Page4 (si existe)
            if f.LizeUIDepsList then f.LizeUIDepsList:Hide() end
            if f.LizeUIFinishButton then f.LizeUIFinishButton:Hide() end
            if f.LizeUIRecsList then f.LizeUIRecsList:Hide() end

            -- Botones de importación
            if f.Option1 then
                f.Option1:Show()
                f.Option1:SetText(StripKLabelSuffix(LT('OPT_ELVUI_3K_BUTTON')))
                f.Option1:SetEnabled(true)
                f.Option1:SetScript('OnClick', function()
                    if LizeUI and LizeUI.ImportElvUI then
                        -- Sin popup de /reload durante el instalador; lo hacemos al finalizar.
                        LizeUI:ImportElvUI('elvui_3k', 'ElvUI (3K)', true)
                    end
                end)
            end

            if f.Option2 then
                -- El PluginInstaller de ElvUI tiene OnShow/OnHide que recolocan y cambian tamaños.
                -- En esta página gestionamos el layout nosotros.
                f.Option2:SetScript('OnShow', nil)
                f.Option2:SetScript('OnHide', nil)
                f.Option2:Show()
                f.Option2:SetText(StripKLabelSuffix(LT('OPT_ELVUI_2K_BUTTON')))
                f.Option2:SetEnabled(true)
                f.Option2:SetScript('OnClick', function()
                    if LizeUI and LizeUI.ImportElvUI then
                        LizeUI:ImportElvUI('elvui_2k', 'ElvUI (2K)', true)
                    end
                end)
            end

            if f.Option3 then
                f.Option3:SetScript('OnShow', nil)
                f.Option3:SetScript('OnHide', nil)
                f.Option3:Show()
                f.Option3:SetText(StripKLabelSuffix(LT('OPT_ELVUI_1K_BUTTON')))
                f.Option3:SetEnabled(false)
                f.Option3:SetScript('OnClick', nil)
            end

            if f.Option4 then
                f.Option4:SetScript('OnClick', nil)
                f.Option4:Hide()
            end

            -- Botones ~1/3 más grandes para que el texto respire mejor
            local function SizeBtn(btn, w, h)
                if not btn then return end
                if type(btn.Size) == 'function' then
                    btn:Size(w, h)
                elseif type(btn.SetSize) == 'function' then
                    btn:SetSize(w, h)
                elseif type(btn.Width) == 'function' and type(btn.Height) == 'function' then
                    btn:Width(w)
                    btn:Height(h)
                end
            end

            -- Mismo tamaño para que queden alineados, centrados y consistentes.
            local w, h, spacing = 170, 30, 4
            SizeBtn(f.Option1, w, h)
            SizeBtn(f.Option2, w, h)
            SizeBtn(f.Option3, w, h)

            -- Centrar el grupo de 3 botones
            if f.Option1 and f.Option2 and f.Option3 then
                f.Option1:ClearAllPoints()
                f.Option2:ClearAllPoints()
                f.Option3:ClearAllPoints()

                f.Option2:Point('BOTTOM', f, 'BOTTOM', 0, 45)
                f.Option1:Point('RIGHT', f.Option2, 'LEFT', -spacing, 0)
                f.Option3:Point('LEFT', f.Option2, 'RIGHT', spacing, 0)
            end
        end)

        if not ok then
            if not self._lizeuiInstallPage2ErrorPrinted then
                self._lizeuiInstallPage2ErrorPrinted = true
                local msg = 'LizeUI: Installer Page2 error: ' .. tostring(err)
                if PrintMsg then
                    PrintMsg(msg)
                elseif _G.print then
                    _G.print(msg)
                end
            end
        end
    end

    local function Page3()
        local f = _G.PluginInstallFrame
        if not f then return end

        local ok, err = pcall(function()
            HideScaleControls(f)

            local function ForceVisible(fs)
                if not fs then return end
                if type(fs.Show) == 'function' then fs:Show() end
                if type(fs.SetAlpha) == 'function' then fs:SetAlpha(1) end
                if type(fs.SetDrawLayer) == 'function' then fs:SetDrawLayer('OVERLAY', 5) end
                if type(fs.SetTextColor) == 'function' then fs:SetTextColor(1, 1, 1) end
            end

            -- Logo consistente
            if BIG_LOGO and f.tutorialImage then
                f.tutorialImage:SetTexture(BIG_LOGO)
                if type(f.tutorialImage.SetDrawLayer) == 'function' then
                    f.tutorialImage:SetDrawLayer('ARTWORK', 0)
                end
                if type(f.tutorialImage.SetVertexColor) == 'function' then
                    f.tutorialImage:SetVertexColor(1, 1, 1)
                end
                if type(f.tutorialImage.SetAlpha) == 'function' then
                    f.tutorialImage:SetAlpha(1)
                end
                f.tutorialImage:ClearAllPoints()
                if type(f.tutorialImage.Size) == 'function' then
                    f.tutorialImage:Size(256, 128)
                else
                    f.tutorialImage:SetSize(256, 128)
                end
                f.tutorialImage:Point('TOP', f, 'TOP', 0, -30)
                f.tutorialImage:Show()
            end
            if f.tutorialImage2 and type(f.tutorialImage2.Hide) == 'function' then
                f.tutorialImage2:Hide()
            end

            if f.SubTitle then
                f.SubTitle:ClearAllPoints()
                if f.tutorialImage and f.tutorialImage:IsShown() then
                    f.SubTitle:Point('TOP', f.tutorialImage, 'BOTTOM', 0, -10)
                else
                    f.SubTitle:Point('TOP', 0, -40)
                end
                ForceVisible(f.SubTitle)
            end

            if type(f.Size) == 'function' then
                f:Size(550, 420)
            elseif type(f.SetSize) == 'function' then
                f:SetSize(550, 420)
            end

            if f.Desc1 then
                f.Desc1:ClearAllPoints()
                if f.SubTitle and type(f.SubTitle.IsShown) == 'function' and f.SubTitle:IsShown() then
                    f.Desc1:Point('TOP', f.SubTitle, 'BOTTOM', 0, -10)
                else
                    f.Desc1:Point('TOP', 0, -185)
                end
                if type(f.Desc1.Width) == 'function' then
                    f.Desc1:Width(f:GetWidth() - 40)
                elseif type(f.Desc1.SetWidth) == 'function' then
                    f.Desc1:SetWidth(f:GetWidth() - 40)
                end
                if type(f.Desc1.FontTemplate) == 'function' then
                    f.Desc1:FontTemplate(nil, 13)
                end
                if type(f.Desc1.SetJustifyH) == 'function' then
                    f.Desc1:SetJustifyH('CENTER')
                end
                if type(f.Desc1.SetJustifyV) == 'function' then
                    f.Desc1:SetJustifyV('TOP')
                end
                ForceVisible(f.Desc1)
            end

            -- Solo un bloque de texto en esta página
            if f.Desc2 then f.Desc2:SetText('') if type(f.Desc2.Hide) == 'function' then f.Desc2:Hide() end end
            if f.Desc3 then f.Desc3:SetText('') if type(f.Desc3.Hide) == 'function' then f.Desc3:Hide() end end
            if f.Desc4 then f.Desc4:SetText('') if type(f.Desc4.Hide) == 'function' then f.Desc4:Hide() end end

            if f.SubTitle then f.SubTitle:SetText(LT('OPT_WOW_IMPORTS_TITLE')) end
            local important = LT('OPT_WOW_IMPORTS_IMPORTANT')
            local desc = LT('OPT_WOW_IMPORTS_DESC')
            if f.Desc1 then
                if type(important) == 'string' and important ~= '' and type(desc) == 'string' and desc ~= '' then
                    f.Desc1:SetText(important .. '\n\n' .. desc)
                elseif type(desc) == 'string' and desc ~= '' then
                    f.Desc1:SetText(desc)
                else
                    f.Desc1:SetText(important or '')
                end
            end

            -- Ocultar UI custom de otras páginas (si existe)
            if f.LizeUIDepsList then f.LizeUIDepsList:Hide() end
            if f.LizeUIFinishButton then f.LizeUIFinishButton:Hide() end
            if f.LizeUIRecsList then f.LizeUIRecsList:Hide() end

            -- Botones de importación (WoW Edit Mode)
            if f.Option1 then
                f.Option1:Show()
                f.Option1:SetText(LT('OPT_WOW_3K_BUTTON'))
                f.Option1:SetEnabled(true)
                f.Option1:SetScript('OnClick', function()
                    if LizeUI and LizeUI.ImportWoWEditMode then
                        LizeUI:ImportWoWEditMode('wow_3k', 'WoW (3K)')
                    end
                end)
            end

            if f.Option2 then
                f.Option2:SetScript('OnShow', nil)
                f.Option2:SetScript('OnHide', nil)
                f.Option2:Show()
                f.Option2:SetText(LT('OPT_WOW_2K_BUTTON'))
                f.Option2:SetEnabled(true)
                f.Option2:SetScript('OnClick', function()
                    if LizeUI and LizeUI.ImportWoWEditMode then
                        LizeUI:ImportWoWEditMode('wow_2k', 'WoW (2K)')
                    end
                end)
            end

            if f.Option3 then
                f.Option3:SetScript('OnShow', nil)
                f.Option3:SetScript('OnHide', nil)
                f.Option3:Show()
                f.Option3:SetText(LT('OPT_WOW_1K_BUTTON'))
                f.Option3:SetEnabled(false)
                f.Option3:SetScript('OnClick', nil)
            end

            if f.Option4 then
                f.Option4:SetScript('OnClick', nil)
                f.Option4:Hide()
            end

            local function SizeBtn(btn, w, h)
                if not btn then return end
                if type(btn.Size) == 'function' then
                    btn:Size(w, h)
                elseif type(btn.SetSize) == 'function' then
                    btn:SetSize(w, h)
                elseif type(btn.Width) == 'function' and type(btn.Height) == 'function' then
                    btn:Width(w)
                    btn:Height(h)
                end
            end

            local w, h, spacing = 170, 30, 4
            SizeBtn(f.Option1, w, h)
            SizeBtn(f.Option2, w, h)
            SizeBtn(f.Option3, w, h)

            if f.Option1 and f.Option2 and f.Option3 then
                f.Option1:ClearAllPoints()
                f.Option2:ClearAllPoints()
                f.Option3:ClearAllPoints()

                f.Option2:Point('BOTTOM', f, 'BOTTOM', 0, 45)
                f.Option1:Point('RIGHT', f.Option2, 'LEFT', -spacing, 0)
                f.Option3:Point('LEFT', f.Option2, 'RIGHT', spacing, 0)
            end
        end)

        if not ok then
            if not self._lizeuiInstallPage3ErrorPrinted then
                self._lizeuiInstallPage3ErrorPrinted = true
                local msg = 'LizeUI: Installer Page3 error: ' .. tostring(err)
                if PrintMsg then
                    PrintMsg(msg)
                elseif _G.print then
                    _G.print(msg)
                end
            end
        end
    end

    local function Page4()
        local f = _G.PluginInstallFrame
        if not f then return end

        local ok, err = pcall(function()
            local function ForceVisible(fs)
                if not fs then return end
                if type(fs.Show) == 'function' then fs:Show() end
                if type(fs.SetAlpha) == 'function' then fs:SetAlpha(1) end
                if type(fs.SetDrawLayer) == 'function' then fs:SetDrawLayer('OVERLAY', 5) end
                if type(fs.SetTextColor) == 'function' then fs:SetTextColor(1, 1, 1) end
            end

            -- No usamos los botones inferiores del PluginInstaller en esta página.
            if f.Option1 then f.Option1:SetScript('OnClick', nil) f.Option1:Hide() end
            if f.Option2 then f.Option2:SetScript('OnClick', nil) f.Option2:Hide() end
            if f.Option3 then f.Option3:SetScript('OnClick', nil) f.Option3:Hide() end
            if f.Option4 then f.Option4:SetScript('OnClick', nil) f.Option4:Hide() end

            -- Quitar el botón final custom (el final será en Page4)
            if f.LizeUIFinishButton then f.LizeUIFinishButton:Hide() end
            if f.LizeUIRecsList then f.LizeUIRecsList:Hide() end

            -- Logo consistente
            if BIG_LOGO and f.tutorialImage then
                f.tutorialImage:SetTexture(BIG_LOGO)
                if type(f.tutorialImage.SetDrawLayer) == 'function' then
                    f.tutorialImage:SetDrawLayer('ARTWORK', 0)
                end
                if type(f.tutorialImage.SetVertexColor) == 'function' then
                    f.tutorialImage:SetVertexColor(1, 1, 1)
                end
                if type(f.tutorialImage.SetAlpha) == 'function' then
                    f.tutorialImage:SetAlpha(1)
                end
                f.tutorialImage:ClearAllPoints()
                if type(f.tutorialImage.Size) == 'function' then
                    f.tutorialImage:Size(256, 128)
                else
                    f.tutorialImage:SetSize(256, 128)
                end
                f.tutorialImage:Point('TOP', f, 'TOP', 0, -30)
                f.tutorialImage:Show()
            end
            if f.tutorialImage2 and type(f.tutorialImage2.Hide) == 'function' then
                f.tutorialImage2:Hide()
            end

            if f.SubTitle then
                f.SubTitle:ClearAllPoints()
                if f.tutorialImage and f.tutorialImage:IsShown() then
                    f.SubTitle:Point('TOP', f.tutorialImage, 'BOTTOM', 0, -10)
                else
                    f.SubTitle:Point('TOP', 0, -40)
                end
                ForceVisible(f.SubTitle)
            end

            if type(f.Size) == 'function' then
                f:Size(550, 420)
            elseif type(f.SetSize) == 'function' then
                f:SetSize(550, 420)
            end

            if f.Desc1 then
                f.Desc1:ClearAllPoints()
                f.Desc1:Point('TOPLEFT', 20, -185)
                if type(f.Desc1.Width) == 'function' then
                    f.Desc1:Width(f:GetWidth() - 40)
                elseif type(f.Desc1.SetWidth) == 'function' then
                    f.Desc1:SetWidth(f:GetWidth() - 40)
                end
                if type(f.Desc1.FontTemplate) == 'function' then
                    f.Desc1:FontTemplate(nil, 13)
                end
                if type(f.Desc1.SetJustifyH) == 'function' then
                    f.Desc1:SetJustifyH('CENTER')
                end
                if type(f.Desc1.SetJustifyV) == 'function' then
                    f.Desc1:SetJustifyV('TOP')
                end
                ForceVisible(f.Desc1)
            end

            if f.Desc2 then f.Desc2:SetText('') if type(f.Desc2.Hide) == 'function' then f.Desc2:Hide() end end
            if f.Desc3 then f.Desc3:SetText('') if type(f.Desc3.Hide) == 'function' then f.Desc3:Hide() end end
            if f.Desc4 then f.Desc4:SetText('') if type(f.Desc4.Hide) == 'function' then f.Desc4:Hide() end end

            if f.SubTitle then f.SubTitle:SetText(LT('INSTALL_DEPS_SUBTITLE')) end
            if f.Desc1 then f.Desc1:SetText(LT('INSTALL_DEPS_DESC1')) end

            -- Contenedor para la lista vertical
            if not f.LizeUIDepsList then
                local list = CreateFrame('Frame', nil, f)
                f.LizeUIDepsList = list
                list:SetPoint('TOPLEFT', f, 'TOPLEFT', 20, -232)
                list:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -20, -232)
                list:SetHeight(120)

                list.rows = {}

                local function CreateRow(i)
                    local row = CreateFrame('Frame', nil, list)
                    row:SetHeight(24)
                    row:SetPoint('TOPLEFT', list, 'TOPLEFT', 0, -(i - 1) * 26)
                    row:SetPoint('TOPRIGHT', list, 'TOPRIGHT', 0, -(i - 1) * 26)

                    row.icon = row:CreateTexture(nil, 'ARTWORK')
                    row.icon:SetSize(14, 14)
                    row.icon:SetPoint('LEFT', row, 'LEFT', 0, 0)

                    row.text = row:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
                    row.text:SetJustifyH('LEFT')
                    row.text:SetPoint('LEFT', row.icon, 'RIGHT', 8, 0)
                    row.text:SetPoint('RIGHT', row, 'RIGHT', -200, 0)

                    row.importBtn = CreateFrame('Button', nil, row, 'UIPanelButtonTemplate')
                    row.importBtn:SetSize(90, 20)
                    row.importBtn:SetText(LT('INSTALL_DEPS_IMPORT'))
                    row.importBtn:SetPoint('RIGHT', row, 'RIGHT', -96, 0)
                    if S and type(S.HandleButton) == 'function' then
                        S:HandleButton(row.importBtn)
                    end

                    row.dlBtn = CreateFrame('Button', nil, row, 'UIPanelButtonTemplate')
                    row.dlBtn:SetSize(90, 20)
                    row.dlBtn:SetText(LT('INSTALL_DEPS_DOWNLOAD'))
                    row.dlBtn:SetPoint('RIGHT', row, 'RIGHT', 0, 0)
                    if S and type(S.HandleButton) == 'function' then
                        S:HandleButton(row.dlBtn)
                    end

                    return row
                end

                for i = 1, 4 do
                    list.rows[i] = CreateRow(i)
                end
            end

            f.LizeUIDepsList:Show()

            local deps = {
                {
                    category = 'mandatory',
                    folder = 'ElvUI_WindTools',
                    label = 'ElvUI_WindTools',
                    url = 'https://www.curseforge.com/wow/addons/elvui-windtools',
                    import = function()
                        if LizeUI and LizeUI.ImportWindTools then
                            LizeUI:ImportWindTools(true)
                        end
                    end,
                },
                {
                    category = 'important',
                    folder = 'Plater',
                    label = 'Plater',
                    url = 'https://www.curseforge.com/wow/addons/plater-nameplates',
                    import = function()
                        if LizeUI and LizeUI.ImportPlater then
                            LizeUI:ImportPlater(true)
                        end
                    end,
                },
                {
                    category = 'important',
                    folder = 'BetterCooldownManager',
                    label = 'BetterCooldownManager',
                    url = 'https://www.curseforge.com/wow/addons/bettercooldownmanager',
                    import = function()
                        if LizeUI and LizeUI.ImportBetterCooldownManager then
                            LizeUI:ImportBetterCooldownManager()
                        end
                    end,
                },
                {
                    category = 'important',
                    folder = 'Details',
                    label = 'Details!',
                    url = 'https://www.curseforge.com/wow/addons/details',
                    import = function()
                        if LizeUI and LizeUI.ImportDetails then
                            LizeUI:ImportDetails()
                        end
                    end,
                },
            }

            for i = 1, 4 do
                local row = f.LizeUIDepsList.rows[i]
                local d = deps[i]

                row.importBtn:SetText(LT('INSTALL_DEPS_IMPORT'))
                row.dlBtn:SetText(LT('INSTALL_DEPS_DOWNLOAD'))

                local cat = d.category
                local catLabel = ''
                if cat == 'mandatory' then
                    catLabel = LT('INSTALL_DEPS_TAG_MANDATORY')
                elseif cat == 'important' then
                    catLabel = LT('INSTALL_DEPS_TAG_IMPORTANT')
                end

                row.icon:SetTexture(StatusIcon(d.folder))
                if type(catLabel) == 'string' and catLabel ~= '' then
                    row.text:SetText(('(%s) %s'):format(catLabel, d.label))
                else
                    row.text:SetText(d.label)
                end

                row.dlBtn:SetScript('OnClick', function()
                    ShowCopyUrl(d.url, d.label)
                end)

                if type(d.import) == 'function' then
                    row.importBtn:Show()
                    row.importBtn:SetScript('OnClick', d.import)

                    local st = GetAddonStatus(d.folder)
                    row.importBtn:SetEnabled(st == 'ok')
                else
                    row.importBtn:Show()
                    row.importBtn:SetEnabled(false)
                    row.importBtn:SetScript('OnClick', nil)
                end
            end
        end)

        if not ok then
            if not self._lizeuiInstallPage4ErrorPrinted then
                self._lizeuiInstallPage4ErrorPrinted = true
                local msg = 'LizeUI: Installer Page4 error: ' .. tostring(err)
                if PrintMsg then
                    PrintMsg(msg)
                elseif _G.print then
                    _G.print(msg)
                end
            end
        end
    end

    local function Page5()
        local f = _G.PluginInstallFrame
        if not f then return end

        local ok, err = pcall(function()
            HideScaleControls(f)
            local function ForceVisible(fs)
                if not fs then return end
                if type(fs.Show) == 'function' then fs:Show() end
                if type(fs.SetAlpha) == 'function' then fs:SetAlpha(1) end
                if type(fs.SetDrawLayer) == 'function' then fs:SetDrawLayer('OVERLAY', 5) end
                if type(fs.SetTextColor) == 'function' then fs:SetTextColor(1, 1, 1) end
            end

            if type(f.Size) == 'function' then
                f:Size(550, 420)
            elseif type(f.SetSize) == 'function' then
                f:SetSize(550, 420)
            end

            if f.LizeUIDepsList then f.LizeUIDepsList:Hide() end
            if f.LizeUIFinishButton then f.LizeUIFinishButton:Hide() end
            if f.LizeUIRecsList then f.LizeUIRecsList:Hide() end

            -- Logo consistente
            if BIG_LOGO and f.tutorialImage then
                f.tutorialImage:SetTexture(BIG_LOGO)
                if type(f.tutorialImage.SetDrawLayer) == 'function' then
                    f.tutorialImage:SetDrawLayer('ARTWORK', 0)
                end
                if type(f.tutorialImage.SetVertexColor) == 'function' then
                    f.tutorialImage:SetVertexColor(1, 1, 1)
                end
                if type(f.tutorialImage.SetAlpha) == 'function' then
                    f.tutorialImage:SetAlpha(1)
                end
                f.tutorialImage:ClearAllPoints()
                if type(f.tutorialImage.Size) == 'function' then
                    f.tutorialImage:Size(256, 128)
                else
                    f.tutorialImage:SetSize(256, 128)
                end
                f.tutorialImage:Point('TOP', f, 'TOP', 0, -30)
                f.tutorialImage:Show()
            end
            if f.tutorialImage2 and type(f.tutorialImage2.Hide) == 'function' then
                f.tutorialImage2:Hide()
            end

            if f.SubTitle then
                f.SubTitle:ClearAllPoints()
                if f.tutorialImage and f.tutorialImage:IsShown() then
                    f.SubTitle:Point('TOP', f.tutorialImage, 'BOTTOM', 0, -10)
                else
                    f.SubTitle:Point('TOP', 0, -40)
                end
                ForceVisible(f.SubTitle)
            end

            if f.Desc1 then
                f.Desc1:ClearAllPoints()
                f.Desc1:Point('TOPLEFT', 20, -185)
                if type(f.Desc1.Width) == 'function' then
                    f.Desc1:Width(f:GetWidth() - 40)
                elseif type(f.Desc1.SetWidth) == 'function' then
                    f.Desc1:SetWidth(f:GetWidth() - 40)
                end
                if type(f.Desc1.FontTemplate) == 'function' then
                    f.Desc1:FontTemplate(nil, 13)
                end
                if type(f.Desc1.SetJustifyH) == 'function' then
                    f.Desc1:SetJustifyH('CENTER')
                end
                if type(f.Desc1.SetJustifyV) == 'function' then
                    f.Desc1:SetJustifyV('TOP')
                end
                ForceVisible(f.Desc1)
            end

            if f.Desc2 then f.Desc2:SetText('') if type(f.Desc2.Hide) == 'function' then f.Desc2:Hide() end end
            if f.Desc3 then f.Desc3:SetText('') if type(f.Desc3.Hide) == 'function' then f.Desc3:Hide() end end
            if f.Desc4 then f.Desc4:SetText('') if type(f.Desc4.Hide) == 'function' then f.Desc4:Hide() end end

            if f.SubTitle then f.SubTitle:SetText(LT('INSTALL_RECS_SUBTITLE')) end
            if f.Desc1 then f.Desc1:SetText(LT('INSTALL_RECS_DESC1')) end

            -- No usamos los botones inferiores del PluginInstaller en esta página.
            if f.Option1 then f.Option1:SetScript('OnClick', nil) f.Option1:Hide() end
            if f.Option2 then f.Option2:SetScript('OnClick', nil) f.Option2:Hide() end
            if f.Option3 then f.Option3:SetScript('OnClick', nil) f.Option3:Hide() end
            if f.Option4 then f.Option4:SetScript('OnClick', nil) f.Option4:Hide() end

            -- Contenedor para la lista de recomendados
            if not f.LizeUIRecsList then
                local list = CreateFrame('Frame', nil, f)
                f.LizeUIRecsList = list
                list:SetPoint('TOPLEFT', f, 'TOPLEFT', 20, -232)
                list:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -20, -232)
                list:SetHeight(120)

                list.rows = {}

                local function CreateRow(i)
                    local row = CreateFrame('Frame', nil, list)
                    row:SetHeight(24)
                    row:SetPoint('TOPLEFT', list, 'TOPLEFT', 0, -(i - 1) * 26)
                    row:SetPoint('TOPRIGHT', list, 'TOPRIGHT', 0, -(i - 1) * 26)

                    row.icon = row:CreateTexture(nil, 'ARTWORK')
                    row.icon:SetSize(14, 14)
                    row.icon:SetPoint('LEFT', row, 'LEFT', 0, 0)

                    row.text = row:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
                    row.text:SetJustifyH('LEFT')
                    row.text:SetPoint('LEFT', row.icon, 'RIGHT', 8, 0)
                    row.text:SetPoint('RIGHT', row, 'RIGHT', -96, 0)

                    row.dlBtn = CreateFrame('Button', nil, row, 'UIPanelButtonTemplate')
                    row.dlBtn:SetSize(90, 20)
                    row.dlBtn:SetText(LT('INSTALL_DEPS_DOWNLOAD'))
                    row.dlBtn:SetPoint('RIGHT', row, 'RIGHT', 0, 0)
                    if S and type(S.HandleButton) == 'function' then
                        S:HandleButton(row.dlBtn)
                    end

                    return row
                end

                for i = 1, 4 do
                    list.rows[i] = CreateRow(i)
                end
            end

            f.LizeUIRecsList:Show()

            local recs = {
                { folder = 'CursorRing', label = 'CursorRing', url = 'https://www.curseforge.com/wow/addons/cursorring' },
                { folder = 'HidingBar', label = 'HidingBar', url = 'https://www.curseforge.com/wow/addons/hidingbar' },
                { folder = 'Immersion', label = 'Immersion', url = 'https://www.curseforge.com/wow/addons/immersion' },
                { folder = 'SimpleAddonManager', label = 'SimpleAddonManager', url = 'https://www.curseforge.com/wow/addons/simple-addon-manager' },
            }

            for i = 1, 4 do
                local row = f.LizeUIRecsList.rows[i]
                local d = recs[i]

                row.icon:SetTexture(StatusIcon(d.folder))
                row.text:SetText(('(%s) %s'):format(LT('INSTALL_RECS_TAG'), d.label))

                row.dlBtn:SetText(LT('INSTALL_DEPS_DOWNLOAD'))
                row.dlBtn:SetScript('OnClick', function()
                    ShowCopyUrl(d.url, d.label)
                end)
            end
        end)

        if not ok then
            if not self._lizeuiInstallPage5ErrorPrinted then
                self._lizeuiInstallPage5ErrorPrinted = true
                local msg = 'LizeUI: Installer Page5 error: ' .. tostring(err)
                if PrintMsg then
                    PrintMsg(msg)
                elseif _G.print then
                    _G.print(msg)
                end
            end
        end
    end

    local function Page6()
        local f = _G.PluginInstallFrame
        if not f then return end

        local ok, err = pcall(function()
            HideScaleControls(f)
            local function ForceVisible(fs)
                if not fs then return end
                if type(fs.Show) == 'function' then fs:Show() end
                if type(fs.SetAlpha) == 'function' then fs:SetAlpha(1) end
                if type(fs.SetDrawLayer) == 'function' then fs:SetDrawLayer('OVERLAY', 5) end
                if type(fs.SetTextColor) == 'function' then fs:SetTextColor(1, 1, 1) end
            end

            if type(f.Size) == 'function' then
                f:Size(550, 420)
            elseif type(f.SetSize) == 'function' then
                f:SetSize(550, 420)
            end

            if f.LizeUIDepsList then f.LizeUIDepsList:Hide() end
            if f.LizeUIRecsList then f.LizeUIRecsList:Hide() end
            if f.LizeUIFinishButton then f.LizeUIFinishButton:Hide() end

            -- Logo consistente
            if BIG_LOGO and f.tutorialImage then
                f.tutorialImage:SetTexture(BIG_LOGO)
                if type(f.tutorialImage.SetDrawLayer) == 'function' then
                    f.tutorialImage:SetDrawLayer('ARTWORK', 0)
                end
                if type(f.tutorialImage.SetVertexColor) == 'function' then
                    f.tutorialImage:SetVertexColor(1, 1, 1)
                end
                if type(f.tutorialImage.SetAlpha) == 'function' then
                    f.tutorialImage:SetAlpha(1)
                end
                f.tutorialImage:ClearAllPoints()
                if type(f.tutorialImage.Size) == 'function' then
                    f.tutorialImage:Size(256, 128)
                else
                    f.tutorialImage:SetSize(256, 128)
                end
                f.tutorialImage:Point('TOP', f, 'TOP', 0, -30)
                f.tutorialImage:Show()
            end
            if f.tutorialImage2 and type(f.tutorialImage2.Hide) == 'function' then
                f.tutorialImage2:Hide()
            end

            if f.SubTitle then
                f.SubTitle:ClearAllPoints()
                if f.tutorialImage and f.tutorialImage:IsShown() then
                    f.SubTitle:Point('TOP', f.tutorialImage, 'BOTTOM', 0, -10)
                else
                    f.SubTitle:Point('TOP', 0, -40)
                end
                ForceVisible(f.SubTitle)
            end

            if f.Desc1 then
                f.Desc1:ClearAllPoints()
                f.Desc1:Point('TOPLEFT', 20, -185)
                if type(f.Desc1.Width) == 'function' then
                    f.Desc1:Width(f:GetWidth() - 40)
                elseif type(f.Desc1.SetWidth) == 'function' then
                    f.Desc1:SetWidth(f:GetWidth() - 40)
                end
                if type(f.Desc1.FontTemplate) == 'function' then
                    f.Desc1:FontTemplate(nil, 13)
                end
                if type(f.Desc1.SetJustifyH) == 'function' then
                    f.Desc1:SetJustifyH('CENTER')
                end
                if type(f.Desc1.SetJustifyV) == 'function' then
                    f.Desc1:SetJustifyV('TOP')
                end
                ForceVisible(f.Desc1)
            end

            if f.Desc2 then
                f.Desc2:ClearAllPoints()
                f.Desc2:Point('TOPLEFT', 20, -235)
                if type(f.Desc2.Width) == 'function' then
                    f.Desc2:Width(f:GetWidth() - 40)
                elseif type(f.Desc2.SetWidth) == 'function' then
                    f.Desc2:SetWidth(f:GetWidth() - 40)
                end
                if type(f.Desc2.FontTemplate) == 'function' then
                    f.Desc2:FontTemplate(nil, 13)
                end
                if type(f.Desc2.SetJustifyH) == 'function' then
                    f.Desc2:SetJustifyH('CENTER')
                end
                if type(f.Desc2.SetJustifyV) == 'function' then
                    f.Desc2:SetJustifyV('TOP')
                end
                ForceVisible(f.Desc2)
            end

            if f.Desc3 then f.Desc3:SetText('') if type(f.Desc3.Hide) == 'function' then f.Desc3:Hide() end end
            if f.Desc4 then f.Desc4:SetText('') if type(f.Desc4.Hide) == 'function' then f.Desc4:Hide() end end

            if f.SubTitle then f.SubTitle:SetText(LT('INSTALL_CHAT_SUBTITLE')) end
            if f.Desc1 then f.Desc1:SetText(LT('INSTALL_CHAT_DESC1')) end
            if f.Desc2 then f.Desc2:SetText(LT('INSTALL_CHAT_DESC2')) end

            if f.Option2 then f.Option2:SetScript('OnClick', nil) f.Option2:Hide() end
            if f.Option3 then f.Option3:SetScript('OnClick', nil) f.Option3:Hide() end
            if f.Option4 then f.Option4:SetScript('OnClick', nil) f.Option4:Hide() end

            if f.Option1 then
                f.Option1:Show()
                f.Option1:SetEnabled(true)
                f.Option1:SetText(LT('INSTALL_CHAT_BUTTON'))
                f.Option1:ClearAllPoints()
                f.Option1:Point('BOTTOM', 0, 45)
                if type(f.Option1.Size) == 'function' then
                    f.Option1:Size(170, 30)
                elseif type(f.Option1.SetSize) == 'function' then
                    f.Option1:SetSize(170, 30)
                end
                f.Option1:SetScript('OnClick', function()
                    if E and type(E.SetupChat) == 'function' then
                        pcall(E.SetupChat, E)
                    end

                    if _G.PluginInstallStepComplete and type(_G.PluginInstallStepComplete.Show) == 'function' then
                        _G.PluginInstallStepComplete.message = LT('INSTALL_CHAT_DONE')
                        _G.PluginInstallStepComplete:Show()
                    end
                end)
            end
        end)

        if not ok then
            if not self._lizeuiInstallPage6ErrorPrinted then
                self._lizeuiInstallPage6ErrorPrinted = true
                local msg = 'LizeUI: Installer Page6 error: ' .. tostring(err)
                if PrintMsg then
                    PrintMsg(msg)
                elseif _G.print then
                    _G.print(msg)
                end
            end
        end
    end

    local function Page7()
        local f = _G.PluginInstallFrame
        if not f then return end

        local ok, err = pcall(function()
            local function ForceVisible(fs)
                if not fs then return end
                if type(fs.Show) == 'function' then fs:Show() end
                if type(fs.SetAlpha) == 'function' then fs:SetAlpha(1) end
                if type(fs.SetDrawLayer) == 'function' then fs:SetDrawLayer('OVERLAY', 5) end
                if type(fs.SetTextColor) == 'function' then fs:SetTextColor(1, 1, 1) end
            end

            if type(f.Size) == 'function' then
                f:Size(550, 420)
            elseif type(f.SetSize) == 'function' then
                f:SetSize(550, 420)
            end

            if f.LizeUIDepsList then f.LizeUIDepsList:Hide() end
            if f.LizeUIRecsList then f.LizeUIRecsList:Hide() end
            if f.LizeUIFinishButton then f.LizeUIFinishButton:Hide() end

            -- Logo consistente
            if BIG_LOGO and f.tutorialImage then
                f.tutorialImage:SetTexture(BIG_LOGO)
                if type(f.tutorialImage.SetDrawLayer) == 'function' then
                    f.tutorialImage:SetDrawLayer('ARTWORK', 0)
                end
                if type(f.tutorialImage.SetVertexColor) == 'function' then
                    f.tutorialImage:SetVertexColor(1, 1, 1)
                end
                if type(f.tutorialImage.SetAlpha) == 'function' then
                    f.tutorialImage:SetAlpha(1)
                end
                f.tutorialImage:ClearAllPoints()
                if type(f.tutorialImage.Size) == 'function' then
                    f.tutorialImage:Size(256, 128)
                else
                    f.tutorialImage:SetSize(256, 128)
                end
                f.tutorialImage:Point('TOP', f, 'TOP', 0, -30)
                f.tutorialImage:Show()
            end
            if f.tutorialImage2 and type(f.tutorialImage2.Hide) == 'function' then
                f.tutorialImage2:Hide()
            end

            if f.SubTitle then
                f.SubTitle:ClearAllPoints()
                if f.tutorialImage and f.tutorialImage:IsShown() then
                    f.SubTitle:Point('TOP', f.tutorialImage, 'BOTTOM', 0, -10)
                else
                    f.SubTitle:Point('TOP', 0, -40)
                end
                ForceVisible(f.SubTitle)
            end

            if f.Desc1 then
                f.Desc1:ClearAllPoints()
                f.Desc1:Point('TOPLEFT', 20, -185)
                if type(f.Desc1.Width) == 'function' then
                    f.Desc1:Width(f:GetWidth() - 40)
                elseif type(f.Desc1.SetWidth) == 'function' then
                    f.Desc1:SetWidth(f:GetWidth() - 40)
                end
                if type(f.Desc1.FontTemplate) == 'function' then
                    f.Desc1:FontTemplate(nil, 13)
                end
                if type(f.Desc1.SetJustifyH) == 'function' then
                    f.Desc1:SetJustifyH('CENTER')
                end
                if type(f.Desc1.SetJustifyV) == 'function' then
                    f.Desc1:SetJustifyV('TOP')
                end
                ForceVisible(f.Desc1)
            end

            if f.Desc2 then f.Desc2:SetText('') if type(f.Desc2.Hide) == 'function' then f.Desc2:Hide() end end
            if f.Desc3 then f.Desc3:SetText('') if type(f.Desc3.Hide) == 'function' then f.Desc3:Hide() end end
            if f.Desc4 then f.Desc4:SetText('') if type(f.Desc4.Hide) == 'function' then f.Desc4:Hide() end end

            if f.SubTitle then f.SubTitle:SetText(LT('INSTALL_SCALE_SUBTITLE')) end
            if f.Desc1 then f.Desc1:SetText(LT('INSTALL_SCALE_DESC1')) end

            EnsureScaleControls(f)
            local slider = f.LizeUIScaleSlider
            slider:ClearAllPoints()
            if f.Desc1 and type(f.Desc1.IsShown) == 'function' and f.Desc1:IsShown() then
                slider:Point('TOP', f.Desc1, 'BOTTOM', 0, -60)
            else
                slider:Point('CENTER', f, 'CENTER', 0, 60)
            end
            slider:Show()
            slider:SetValueStep(0.01)
            slider:SetObeyStepOnDrag(true)
            slider:SetMinMaxValues(0.4, 1.15)

            local current = (E and E.global and E.global.general and E.global.general.UIScale) or 0.66
            slider:SetValue(current)
            if slider.Cur then slider.Cur:SetText(current) end

            slider.Min:SetText(0.4)
            slider.Max:SetText(1.15)

            slider:SetScript('OnMouseUp', function()
                if E and type(E.PixelScaleChanged) == 'function' then
                    pcall(E.PixelScaleChanged, E)
                end
            end)

            slider:SetScript('OnValueChanged', function(s)
                if not E or not E.Round then
                    ApplyUIScale(s:GetValue(), false)
                    if slider.Cur then slider.Cur:SetText(s:GetValue()) end
                    return
                end

                local val = E:Round(s:GetValue(), 2)
                ApplyUIScale(val, false)
                if slider.Cur then slider.Cur:SetText(val) end
            end)

            if f.Option2 then f.Option2:SetScript('OnClick', nil) f.Option2:Hide() end
            if f.Option3 then f.Option3:SetScript('OnClick', nil) f.Option3:Hide() end
            if f.Option4 then f.Option4:SetScript('OnClick', nil) f.Option4:Hide() end

            if f.Option1 then
                f.Option1:Show()
                f.Option1:SetEnabled(true)
                f.Option1:SetText(LT('INSTALL_SCALE_BUTTON'))
                f.Option1:ClearAllPoints()
                f.Option1:Point('BOTTOM', 0, 45)
                if type(f.Option1.Size) == 'function' then
                    f.Option1:Size(190, 30)
                elseif type(f.Option1.SetSize) == 'function' then
                    f.Option1:SetSize(190, 30)
                end
                f.Option1:SetScript('OnClick', function()
                    local v = 0.66
                    ApplyUIScale(v, true)
                    if slider then
                        slider:SetValue(v)
                        if slider.Cur then slider.Cur:SetText(v) end
                    end
                end)
            end
        end)

        if not ok then
            if not self._lizeuiInstallPage7ErrorPrinted then
                self._lizeuiInstallPage7ErrorPrinted = true
                local msg = 'LizeUI: Installer Page7 error: ' .. tostring(err)
                if PrintMsg then
                    PrintMsg(msg)
                elseif _G.print then
                    _G.print(msg)
                end
            end
        end
    end

    local function Page8()
        local f = _G.PluginInstallFrame
        if not f then return end

        local ok, err = pcall(function()
            HideScaleControls(f)
            local function ForceVisible(fs)
                if not fs then return end
                if type(fs.Show) == 'function' then fs:Show() end
                if type(fs.SetAlpha) == 'function' then fs:SetAlpha(1) end
                if type(fs.SetDrawLayer) == 'function' then fs:SetDrawLayer('OVERLAY', 5) end
                if type(fs.SetTextColor) == 'function' then fs:SetTextColor(1, 1, 1) end
            end

            if type(f.Size) == 'function' then
                f:Size(550, 420)
            elseif type(f.SetSize) == 'function' then
                f:SetSize(550, 420)
            end

            if f.LizeUIDepsList then f.LizeUIDepsList:Hide() end
            if f.LizeUIRecsList then f.LizeUIRecsList:Hide() end
            if f.LizeUIFinishButton then f.LizeUIFinishButton:Hide() end

            -- Logo consistente
            if BIG_LOGO and f.tutorialImage then
                f.tutorialImage:SetTexture(BIG_LOGO)
                if type(f.tutorialImage.SetDrawLayer) == 'function' then
                    f.tutorialImage:SetDrawLayer('ARTWORK', 0)
                end
                if type(f.tutorialImage.SetVertexColor) == 'function' then
                    f.tutorialImage:SetVertexColor(1, 1, 1)
                end
                if type(f.tutorialImage.SetAlpha) == 'function' then
                    f.tutorialImage:SetAlpha(1)
                end
                f.tutorialImage:ClearAllPoints()
                if type(f.tutorialImage.Size) == 'function' then
                    f.tutorialImage:Size(256, 128)
                else
                    f.tutorialImage:SetSize(256, 128)
                end
                f.tutorialImage:Point('TOP', f, 'TOP', 0, -30)
                f.tutorialImage:Show()
            end
            if f.tutorialImage2 and type(f.tutorialImage2.Hide) == 'function' then
                f.tutorialImage2:Hide()
            end

            if f.SubTitle then
                f.SubTitle:ClearAllPoints()
                if f.tutorialImage and f.tutorialImage:IsShown() then
                    f.SubTitle:Point('TOP', f.tutorialImage, 'BOTTOM', 0, -10)
                else
                    f.SubTitle:Point('TOP', 0, -40)
                end
                ForceVisible(f.SubTitle)
            end

            if f.Desc1 then
                f.Desc1:ClearAllPoints()
                f.Desc1:Point('TOPLEFT', 20, -185)
                if type(f.Desc1.Width) == 'function' then
                    f.Desc1:Width(f:GetWidth() - 40)
                elseif type(f.Desc1.SetWidth) == 'function' then
                    f.Desc1:SetWidth(f:GetWidth() - 40)
                end
                if type(f.Desc1.FontTemplate) == 'function' then
                    f.Desc1:FontTemplate(nil, 13)
                end
                if type(f.Desc1.SetJustifyH) == 'function' then
                    f.Desc1:SetJustifyH('CENTER')
                end
                if type(f.Desc1.SetJustifyV) == 'function' then
                    f.Desc1:SetJustifyV('TOP')
                end
                ForceVisible(f.Desc1)
            end

            if f.Desc2 then f.Desc2:SetText('') if type(f.Desc2.Hide) == 'function' then f.Desc2:Hide() end end
            if f.Desc3 then f.Desc3:SetText('') if type(f.Desc3.Hide) == 'function' then f.Desc3:Hide() end end
            if f.Desc4 then f.Desc4:SetText('') if type(f.Desc4.Hide) == 'function' then f.Desc4:Hide() end end

            if f.SubTitle then f.SubTitle:SetText(LT('INSTALL_FINISH_SUBTITLE')) end
            if f.Desc1 then f.Desc1:SetText(LT('INSTALL_FINISH_DESC1')) end

            if f.Option2 then f.Option2:SetScript('OnClick', nil) f.Option2:Hide() end
            if f.Option3 then f.Option3:SetScript('OnClick', nil) f.Option3:Hide() end
            if f.Option4 then f.Option4:SetScript('OnClick', nil) f.Option4:Hide() end

            if f.Option1 then
                f.Option1:Show()
                f.Option1:SetEnabled(true)
                f.Option1:SetText(LT('INSTALL_FINISH_BUTTON'))
                f.Option1:ClearAllPoints()
                f.Option1:Point('BOTTOM', 0, 45)
                if type(f.Option1.Size) == 'function' then
                    f.Option1:Size(170, 30)
                elseif type(f.Option1.SetSize) == 'function' then
                    f.Option1:SetSize(170, 30)
                end
                f.Option1:SetScript('OnClick', function()
                    -- Deshabilitar NamePlates de ElvUI ("Placas de nombre") antes del reload.
                    if E and type(E.private) == 'table' then
                        E.private.nameplates = E.private.nameplates or {}
                        E.private.nameplates.enable = false
                    end

                    if type(_G.ReloadUI) == 'function' then
                        _G.ReloadUI()
                    end
                end)
            end
        end)

        if not ok then
            if not self._lizeuiInstallPage8ErrorPrinted then
                self._lizeuiInstallPage8ErrorPrinted = true
                local msg = 'LizeUI: Installer Page8 error: ' .. tostring(err)
                if PrintMsg then
                    PrintMsg(msg)
                elseif _G.print then
                    _G.print(msg)
                end
            end
        end
    end

    local install = {
        Title = LT('INSTALL_TITLE'),
        Name = 'LizeUI',
        tutorialImage = BIG_LOGO,
        tutorialImageSize = { 256, 128 },
        tutorialImageVertexColor = { 1, 1, 1 },
        Pages = { Page1, Page2, Page3, Page4, Page5, Page6, Page7, Page8 },
    }

    PI:Queue(install)
    if type(PI.RunInstall) == 'function' then
        PI:RunInstall()
    end
end
