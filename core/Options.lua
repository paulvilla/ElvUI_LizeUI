-- Options.lua: construcción e inserción de opciones AceConfig (categoría LizeUI)

local addonName, ns = ...

local E = ns.E
local LizeUI = ns.LizeUI

local LT = ns.LT
local LTF = ns.LTF

local BlueTitle = ns.BlueTitle
local GradientText = ns.GradientText
local BuildLSMResourceList = ns.BuildLSMResourceList

local ADDON_PATH = ns.ADDON_PATH
local LIZEUI_ICON_PATH = ns.LIZEUI_ICON_PATH

local OK_ICON = ADDON_PATH .. 'media\\textures\\icons\\ok.tga'
local ERROR_ICON = ADDON_PATH .. 'media\\textures\\icons\\error.tga'
local NO_ACTIVE_ICON = ADDON_PATH .. 'media\\textures\\icons\\no-active.tga'
local BIG_LOGO = ADDON_PATH .. 'media\\textures\\icons\\lizeui_grande.tga'
local CAFE_ICON = ADDON_PATH .. 'media\\textures\\icons\\cafe.tga'
local CLASS_ICONS_PATH = ADDON_PATH .. 'media\\textures\\classes\\'

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
        EditBoxOnEnterPressed = function(self)
            self:GetParent():Hide()
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
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

local function GetAddOnInfoSafe(addonFolder)
    local getInfo = (C_AddOns and C_AddOns.GetAddOnInfo) or _G.GetAddOnInfo
    if type(getInfo) ~= 'function' then return nil end

    local ok, r1, r2, r3, r4, r5, r6 = pcall(getInfo, addonFolder)
    if not ok then return nil end

    -- En algunas builds modernas, C_AddOns.GetAddOnInfo devuelve una tabla.
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
    local name, _, _, loadable, reason = GetAddOnInfoSafe(addonFolder)
    if (type(reason) == 'string' and reason == 'MISSING') or type(name) ~= 'string' or name == '' then
        return 'missing'
    end

    -- Fuente principal: enable state (instalado pero desactivado vs activado)
    local state = GetAddOnEnableStateSafe(addonFolder)
    if state ~= nil then
        if state > 0 then return 'ok' end
        return 'inactive'
    end

    -- Si está cargado, lo consideramos OK.
    local loaded = IsAddOnLoadedSafe(addonFolder)
    if loaded == true then return 'ok' end

    -- Fallback: reason explícito (si existe) + loadable
    if type(reason) == 'string' and reason == 'DISABLED' then
        return 'inactive'
    end

    -- Si no pudimos leer el estado, solo consideramos OK si es claramente loadable.
    if loadable == true then return 'ok' end

    return 'inactive'
end

local function StatusIcon(addonFolder)
    local status = GetAddonStatus(addonFolder)
    if status == 'ok' then return OK_ICON end
    if status == 'inactive' then return NO_ACTIVE_ICON end
    return ERROR_ICON
end

local function StatusTextInline(label, addonFolder)
    return ('%s |T%s:14:14:0:0|t'):format(label, StatusIcon(addonFolder))
end

local function AddonStatusButton(order, label, addonFolder, url, width, iconSize)
    local size = iconSize or 14
    local t = {
        order = order,
        type = 'execute',
        name = function()
            return ('|T%s:%d:%d:0:0|t %s'):format(StatusIcon(addonFolder), size, size, label)
        end,
        func = function()
            if type(url) ~= 'string' or url == '' then return end

            if EnsureCopyUrlPopup() and E and type(E.StaticPopup_Show) == 'function' then
                if E.PopupDialogs and E.PopupDialogs[COPY_URL_POPUP] then
                    E.PopupDialogs[COPY_URL_POPUP].text = ('Link de descarga: %s'):format(label or 'LizeUI')
                end
                E:StaticPopup_Show(COPY_URL_POPUP, nil, nil, url)
                return
            end

            local show = _G.StaticPopup_Show
            if type(show) == 'function' then
                if _G.StaticPopupDialogs and _G.StaticPopupDialogs[COPY_URL_POPUP] then
                    _G.StaticPopupDialogs[COPY_URL_POPUP].text = ('Link de descarga: %s'):format(label or 'LizeUI')
                end
                show(COPY_URL_POPUP, url)
            end
        end,
    }
    if width ~= nil then
        t.width = width
    end
    return t
end

local function DisabledOption(option)
    if type(option) == 'table' then
        option.disabled = true
    end
    return option
end

local function UrlButton(order, label, url, width, image, imageSize)
    local t = {
        order = order,
        type = 'execute',
        name = label,
        func = function()
            if type(url) ~= 'string' or url == '' then return end

            if EnsureCopyUrlPopup() and E and type(E.StaticPopup_Show) == 'function' then
                if E.PopupDialogs and E.PopupDialogs[COPY_URL_POPUP] then
                    E.PopupDialogs[COPY_URL_POPUP].text = label or 'LizeUI'
                end
                E:StaticPopup_Show(COPY_URL_POPUP, nil, nil, url)
                return
            end

            local show = _G.StaticPopup_Show
            if type(show) == 'function' then
                if _G.StaticPopupDialogs and _G.StaticPopupDialogs[COPY_URL_POPUP] then
                    _G.StaticPopupDialogs[COPY_URL_POPUP].text = label or 'LizeUI'
                end
                show(COPY_URL_POPUP, url)
            end
        end,
    }
    if width ~= nil then
        t.width = width
    end

    if type(image) == 'string' and image ~= '' then
        t.image = image
        local size = type(imageSize) == 'number' and imageSize or 14
        t.imageWidth = size
        t.imageHeight = size
    end
    return t
end

local function LuxKey(prefix, token)
    if type(token) ~= 'string' or token == '' then return prefix end
    return prefix .. token:upper()
end

local function LuxClass(token)
    return LT(LuxKey('OPT_LUXTHOS_CLASS_', token))
end

local function LuxSpec(token)
    return LT(LuxKey('OPT_LUXTHOS_SPEC_', token))
end

local function LuxLabel(classToken, specToken)
    if type(LTF) == 'function' then
        return LTF('OPT_LUXTHOS_LABEL_FMT', LuxClass(classToken), LuxSpec(specToken))
    end
    return ('WoW (Luxthos) - %s: %s'):format(LuxClass(classToken), LuxSpec(specToken))
end

local function LuxConfirm()
    return LT('OPT_LUXTHOS_CONFIRM_COOLDOWN_MANAGER')
end

local CLASS_ICON_FILES = {
    death_knight = 'DeathKnight',
    demon_hunter = 'DemonHunter',
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

local function LuxClassWithIcon(classToken)
    local file = CLASS_ICON_FILES[classToken]
    if type(file) == 'string' and file ~= '' then
        return ('|T%s%s.tga:14:14:0:0|t %s'):format(CLASS_ICONS_PATH, file, LuxClass(classToken))
    end
    return LuxClass(classToken)
end

local function BuildOptionsTable()
    local headerArgs = {
        beforeLogo = {
            order = 1,
            type = 'description',
            fontSize = 'medium',
            name = ' ',
            width = 'full',
        },
        logo = {
            order = 2,
            type = 'description',
            name = '',
            image = function()
                return BIG_LOGO, 256, 128
            end,
        },
        afterLogo = {
            order = 3,
            type = 'description',
            fontSize = 'medium',
            name = ' \n ',
            width = 'full',
        },
    }

    return {
        type = 'group',
        childGroups = 'tree',
        name = ('|T%s:14:14:0:0|t %s'):format(LIZEUI_ICON_PATH, GradientText('LizeUI', 0, 192, 250, 130, 85, 255)),
        icon = LIZEUI_ICON_PATH,
        iconCoords = { 0.08, 0.92, 0.08, 0.92 },
        order = 100,
        args = {
            beforeLogo = headerArgs.beforeLogo,
            logo = headerArgs.logo,
            afterLogo = headerArgs.afterLogo,

            dependencies = {
                order = 10,
                type = 'group',
                name = LT('OPT_MENU_DEPENDENCIES'),
                args = {
                    launchInstaller = {
                        order = 1,
                        type = 'execute',
                        name = LT('OPT_LAUNCH_INSTALLER'),
                        func = function()
                            local ACD = E and E.Libs and E.Libs.AceConfigDialog
                            if ACD and type(ACD.Close) == 'function' then
                                pcall(ACD.Close, ACD, 'ElvUI')
                            end

                            local function Launch()
                                if LizeUI and type(LizeUI.ShowInstallWindow) == 'function' then
                                    LizeUI:ShowInstallWindow(true)
                                end
                            end

                            if _G.C_Timer and type(_G.C_Timer.After) == 'function' then
                                _G.C_Timer.After(0, Launch)
                            else
                                Launch()
                            end
                        end,
                    },
                    depsHeader = {
                        order = 5,
                        type = 'header',
                        name = BlueTitle(LT('OPT_DEPS_TITLE')),
                    },
                    depsDescBox = {
                        order = 6,
                        type = 'group',
                        name = LT('OPT_SPACER'),
                        inline = true,
                        args = {
                            desc = {
                                order = 1,
                                type = 'description',
                                name = LT('OPT_DEPS_DESC'),
                            },
                            legendLine = {
                                order = 1.5,
                                type = 'description',
                                fontSize = 'medium',
                                name = function()
                                    local parts = {
                                        ('|T%s:14:14:0:0|t %s'):format(OK_ICON, LT('OPT_DEPS_LEGEND_ACTIVE')),
                                        ('|T%s:14:14:0:0|t %s'):format(NO_ACTIVE_ICON, LT('OPT_DEPS_LEGEND_INACTIVE')),
                                        ('|T%s:14:14:0:0|t %s'):format(ERROR_ICON, LT('OPT_DEPS_LEGEND_MISSING')),
                                    }
                                    return table.concat(parts, '     ')
                                end,
                            },
                            spacerDeps = {
                                order = 1.6,
                                type = 'description',
                                name = LT('OPT_SPACER'),
                            },
                            mandatoryAddonsBox = {
                                order = 2,
                                type = 'group',
                                name = BlueTitle(LT('OPT_DEPS_MANDATORY_STATUS_TITLE')),
                                inline = true,
                                args = {
                                    windTools = AddonStatusButton(1, 'ElvUI_WindTools', 'ElvUI_WindTools', 'https://www.curseforge.com/wow/addons/elvui-windtools'),
                                },
                            },
                            addonsBox = {
                                order = 3,
                                type = 'group',
                                name = BlueTitle(LT('OPT_DEPS_STATUS_TITLE')),
                                inline = true,
                                args = {
                                    plater = AddonStatusButton(1, 'Plater', 'Plater', 'https://www.curseforge.com/wow/addons/plater-nameplates'),
                                    bcdm = AddonStatusButton(2, 'BetterCooldownManager', 'BetterCooldownManager', 'https://www.curseforge.com/wow/addons/bettercooldownmanager', 1.66),
                                    addonSkins = DisabledOption(AddonStatusButton(3, 'AddOnSkins', 'AddOnSkins', 'https://www.curseforge.com/wow/addons/addonskins')),
                                    details = AddonStatusButton(4, 'Details!', 'Details', 'https://www.curseforge.com/wow/addons/details'),
                                },
                            },
                            recommendedAddonsBox = {
                                order = 4,
                                type = 'group',
                                name = BlueTitle(LT('OPT_DEPS_RECOMMENDED_STATUS_TITLE')),
                                inline = true,
                                args = {
                                    cursorRing = AddonStatusButton(1, 'CursorRing', 'CursorRing', 'https://www.curseforge.com/wow/addons/cursorring'),
                                    hidingBar = AddonStatusButton(2, 'HidingBar', 'HidingBar', 'https://www.curseforge.com/wow/addons/hidingbar'),
                                    immersion = AddonStatusButton(3, 'Immersion', 'Immersion', 'https://www.curseforge.com/wow/addons/immersion'),
                                    sam = AddonStatusButton(4, 'SimpleAddonManager', 'SimpleAddonManager', 'https://www.curseforge.com/wow/addons/simple-addon-manager', 1.66),
                                },
                            },
                        },
                    },
                },
            },

            features = {
                order = 30,
                type = 'group',
                name = LT('OPT_MENU_FEATURES'),
                args = {
                    qolHeader = {
                        order = 9,
                        type = 'header',
                        name = BlueTitle(LT('OPT_QOL_HEADER')),
                    },
                    qolBox = {
                        order = 11,
                        type = 'group',
                        name = BlueTitle(LT('OPT_QOL_BOX_TITLE')),
                        inline = true,
                        width = 0.5,
                        args = {
                            suppressRightClick = {
                                order = 1,
                                type = 'toggle',
                                name = LT('OPT_SUPPRESS_RIGHTCLICK_NAME'),
                                desc = LT('OPT_SUPPRESS_RIGHTCLICK_DESC'),
                                get = function() return LizeUIDB.features.suppressRightClick end,
                                set = function(_, value)
                                    LizeUIDB.features.suppressRightClick = value
                                    LizeUI:ApplyFeature('suppressRightClick', value)
                                end,
                            },
                            globalFadePersist = {
                                order = 2,
                                type = 'toggle',
                                name = LT('OPT_GLOBAL_FADE_NAME'),
                                desc = LT('OPT_GLOBAL_FADE_DESC'),
                                get = function() return LizeUIDB.features.globalFadePersist end,
                                set = function(_, value)
                                    LizeUIDB.features.globalFadePersist = value
                                    LizeUI:ApplyFeature('globalFadePersist', value)
                                end,
                            },
                        },
                    },
                    bugfixBox = {
                        order = 12,
                        type = 'group',
                        name = BlueTitle(LT('OPT_BUGFIX_BOX_TITLE')),
                        inline = true,
                        width = 0.5,
                        args = {
                            hidePetDemonBar = {
                                order = 1,
                                type = 'toggle',
                                name = LT('OPT_HIDE_PET_DEMON_NAME'),
                                desc = LT('OPT_HIDE_PET_DEMON_DESC'),
                                get = function() return LizeUIDB.features.hidePetDemonBar end,
                                set = function(_, value)
                                    LizeUIDB.features.hidePetDemonBar = value
                                    LizeUI:ApplyFeature('hidePetDemonBar', value)
                                end,
                            },
                            disableFriendlyNPCHealthBars = {
                                order = 2,
                                type = 'toggle',
                                name = LT('OPT_DISABLE_FRIENDLY_NPC_HEALTHBARS_NAME'),
                                desc = LT('OPT_DISABLE_FRIENDLY_NPC_HEALTHBARS_DESC'),
                                get = function() return LizeUIDB.features.disableFriendlyNPCHealthBars end,
                                set = function(_, value)
                                    LizeUIDB.features.disableFriendlyNPCHealthBars = value
                                    LizeUI:ApplyFeature('disableFriendlyNPCHealthBars', value)
                                end,
                            },
                        },
                    },
                },
            },

            imports = {
                order = 20,
                type = 'group',
                name = LT('OPT_MENU_IMPORTS'),
                childGroups = 'tab',
                args = {
                    interfaceTab = {
                        order = 1,
                        type = 'group',
                        name = LT('OPT_IMPORTS_TAB_INTERFACE'),
                        args = {
                            elvuiImportsBox = {
                                order = 20,
                                type = 'group',
                                name = BlueTitle(LT('OPT_ELVUI_IMPORTS_TITLE')),
                                inline = true,
                                args = {
                                    desc = {
                                        order = 1,
                                        type = 'description',
                                        name = LT('OPT_ELVUI_IMPORTS_DESC'),
                                    },
                                    spacer = {
                                        order = 2,
                                        type = 'description',
                                        name = LT('OPT_SPACER'),
                                    },
                                    importElvui3k = {
                                        order = 3,
                                        type = 'execute',
                                        name = LT('OPT_ELVUI_3K_BUTTON'),
                                        confirm = true,
                                        confirmText = LT('OPT_ELVUI_3K_CONFIRM'),
                                        func = function() LizeUI:ImportElvUI('elvui_3k', 'ElvUI (3K)') end,
                                    },
                                    importElvui2k = {
                                        order = 4,
                                        type = 'execute',
                                        name = LT('OPT_ELVUI_2K_BUTTON'),
                                        confirm = true,
                                        confirmText = LT('OPT_ELVUI_2K_CONFIRM'),
                                        func = function() LizeUI:ImportElvUI('elvui_2k', 'ElvUI (2K)') end,
                                    },
                                    importElvui1k = {
                                        order = 5,
                                        type = 'execute',
                                        name = LT('OPT_ELVUI_1K_BUTTON'),
                                        confirm = true,
                                        confirmText = LT('OPT_ELVUI_1K_CONFIRM'),
                                        func = function() LizeUI:ImportElvUI('elvui_1k', 'ElvUI (1K)') end,
                                    },
                                },
                            },
                            wowImportsBox = {
                                order = 25,
                                type = 'group',
                                name = BlueTitle(LT('OPT_WOW_IMPORTS_TITLE')),
                                inline = true,
                                args = {
                                    desc = {
                                        order = 1,
                                        type = 'description',
                                        name = LT('OPT_WOW_IMPORTS_DESC'),
                                    },
                                    importantNote = {
                                        order = 1.5,
                                        type = 'description',
                                        name = LT('OPT_WOW_IMPORTS_IMPORTANT'),
                                    },
                                    spacer = {
                                        order = 2,
                                        type = 'description',
                                        name = LT('OPT_SPACER'),
                                    },
                                    importWow3k = {
                                        order = 3,
                                        type = 'execute',
                                        name = LT('OPT_WOW_3K_BUTTON'),
                                        confirm = true,
                                        confirmText = LT('OPT_WOW_3K_CONFIRM'),
                                        func = function() LizeUI:ImportWoWEditMode('wow_3k', 'WoW (3K)') end,
                                    },
                                    importWow2k = {
                                        order = 4,
                                        type = 'execute',
                                        name = LT('OPT_WOW_2K_BUTTON'),
                                        confirm = true,
                                        confirmText = LT('OPT_WOW_2K_CONFIRM'),
                                        func = function() LizeUI:ImportWoWEditMode('wow_2k', 'WoW (2K)') end,
                                    },
                                    importWow1k = {
                                        order = 5,
                                        type = 'execute',
                                        name = LT('OPT_WOW_1K_BUTTON'),
                                        confirm = true,
                                        confirmText = LT('OPT_WOW_1K_CONFIRM'),
                                        func = function() LizeUI:ImportWoWEditMode('wow_1k', 'WoW (1K)') end,
                                    },
                                },
                            },
                            addonImportsBox = {
                                order = 30,
                                type = 'group',
                                name = BlueTitle(LT('OPT_ADDON_IMPORTS_TITLE')),
                                inline = true,
                                args = {
                                    desc = {
                                        order = 1,
                                        type = 'description',
                                        name = LT('OPT_ADDON_IMPORTS_DESC'),
                                    },
                                    spacer = {
                                        order = 2,
                                        type = 'description',
                                        name = LT('OPT_SPACER'),
                                    },
                                    importWindTools = {
                                        order = 3,
                                        type = 'execute',
                                        name = LT('OPT_IMPORT_WINDTOOLS'),
                                        confirm = true,
                                        confirmText = LT('OPT_CONFIRM_WINDTOOLS'),
                                        func = function() LizeUI:ImportWindTools() end,
                                    },
                                    importPlater = {
                                        order = 4,
                                        type = 'execute',
                                        name = LT('OPT_IMPORT_PLATER'),
                                        confirm = true,
                                        confirmText = LT('OPT_CONFIRM_PLATER'),
                                        func = function() LizeUI:ImportPlater() end,
                                    },
                                    importDetails = {
                                        order = 5,
                                        type = 'execute',
                                        name = LT('OPT_IMPORT_DETAILS'),
                                        confirm = true,
                                        confirmText = LT('OPT_CONFIRM_DETAILS'),
                                        func = function() LizeUI:ImportDetails() end,
                                    },
                                },
                            },

                            betterCooldownManagerImportsBox = {
                                order = 31,
                                type = 'group',
                                name = BlueTitle(LT('OPT_IMPORT_BCDM')),
                                inline = true,
                                args = {
                                    desc = {
                                        order = 1,
                                        type = 'description',
                                        name = LT('OPT_CONFIRM_BCDM'),
                                    },
                                    spacer = {
                                        order = 2,
                                        type = 'description',
                                        name = LT('OPT_SPACER'),
                                    },
                                    question = {
                                        order = 3,
                                        type = 'description',
                                        name = LT('INSTALL_BCDM_QUESTION'),
                                    },
                                    importBCDMAll = {
                                        order = 4,
                                        type = 'execute',
                                        name = LT('INSTALL_BCDM_ALL_BUTTON'),
                                        width = 1.33,
                                        confirm = true,
                                        confirmText = LT('OPT_CONFIRM_BCDM'),
                                        func = function() LizeUI:ImportBetterCooldownManager('all') end,
                                    },
                                    importBCDMMana = {
                                        order = 5,
                                        type = 'execute',
                                        name = LT('INSTALL_BCDM_MANA_BUTTON'),
                                        confirm = true,
                                        confirmText = LT('OPT_CONFIRM_BCDM'),
                                        func = function() LizeUI:ImportBetterCooldownManager('mana') end,
                                    },
                                    importBCDMNoMana = {
                                        order = 6,
                                        type = 'execute',
                                        name = LT('INSTALL_BCDM_NO_MANA_BUTTON'),
                                        confirm = true,
                                        confirmText = LT('OPT_CONFIRM_BCDM'),
                                        func = function() LizeUI:ImportBetterCooldownManager('no_mana') end,
                                    },
                                },
                            },
                        },
                    },

                    skillsTab = {
                        order = 2,
                        type = 'group',
                        name = LT('OPT_IMPORTS_TAB_SKILLS'),
                        args = {
                            luxthosCooldownsBox = {
                                order = 35,
                                type = 'group',
                                name = BlueTitle(LT('OPT_LUXTHOS_CONFIG_TITLE')),
                                inline = true,
                                args = {
                                    luxthosInfo = {
                                        order = 0.1,
                                        type = 'description',
                                        fontSize = 'medium',
                                        name = LT('OPT_LUXTHOS_INFO_DESC'),
                                        width = 'full',
                                    },
                                    luxthosSpacer = {
                                        order = 0.2,
                                        type = 'description',
                                        name = LT('OPT_SPACER'),
                                        width = 'full',
                                    },
                                    luxthosWebButton = UrlButton(0.3, LT('OPT_LUXTHOS_WEB_BUTTON'), 'https://www.luxthos.com/', 0.85),
                                    luxthosPatreonButton = UrlButton(0.4, LT('OPT_LUXTHOS_PATREON_BUTTON'), 'https://www.patreon.com/luxthos', 1.15),
                                    luxthosSpacer2 = {
                                        order = 0.5,
                                        type = 'description',
                                        name = ' ',
                                        width = 'full',
                                    },
                                    deathKnightBox = {
                                        order = 1,
                                        type = 'group',
                                        name = BlueTitle(LuxClassWithIcon('death_knight')),
                                        inline = true,
                                        args = {
                                            blood = {
                                                order = 1,
                                                type = 'execute',
                                                name = LuxSpec('blood'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('deathknight_blood_luxthos', LuxLabel('death_knight', 'blood')) end,
                                            },
                                            frost = {
                                                order = 2,
                                                type = 'execute',
                                                name = LuxSpec('frost'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('deathknight_frost_luxthos', LuxLabel('death_knight', 'frost')) end,
                                            },
                                            unholy = {
                                                order = 3,
                                                type = 'execute',
                                                name = LuxSpec('unholy'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('deathknight_unholy_luxthos', LuxLabel('death_knight', 'unholy')) end,
                                            },
                                        },
                                    },

                                    demonHunterBox = {
                                        order = 2,
                                        type = 'group',
                                        name = BlueTitle(LuxClassWithIcon('demon_hunter')),
                                        inline = true,
                                        args = {
                                            havoc = {
                                                order = 1,
                                                type = 'execute',
                                                name = LuxSpec('havoc'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('demonhunter_havoc_luxthos', LuxLabel('demon_hunter', 'havoc')) end,
                                            },
                                            vengeance = {
                                                order = 2,
                                                type = 'execute',
                                                name = LuxSpec('vengeance'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('demonhunter_vengeance_luxthos', LuxLabel('demon_hunter', 'vengeance')) end,
                                            },
                                            devourer = {
                                                order = 3,
                                                type = 'execute',
                                                name = LuxSpec('devourer'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('demonhunter_devourer_luxthos', LuxLabel('demon_hunter', 'devourer')) end,
                                            },
                                        },
                                    },

                                    druidBox = {
                                        order = 3,
                                        type = 'group',
                                        name = BlueTitle(LuxClassWithIcon('druid')),
                                        inline = true,
                                        args = {
                                            balance = {
                                                order = 1,
                                                type = 'execute',
                                                name = LuxSpec('balance'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('druid_balance_luxthos', LuxLabel('druid', 'balance')) end,
                                            },
                                            feral = {
                                                order = 2,
                                                type = 'execute',
                                                name = LuxSpec('feral'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('druid_feral_luxthos', LuxLabel('druid', 'feral')) end,
                                            },
                                            guardian = {
                                                order = 3,
                                                type = 'execute',
                                                name = LuxSpec('guardian'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('druid_guardian_luxthos', LuxLabel('druid', 'guardian')) end,
                                            },
                                            restoration = {
                                                order = 4,
                                                type = 'execute',
                                                name = LuxSpec('restoration'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('druid_restoration_luxthos', LuxLabel('druid', 'restoration')) end,
                                            },
                                        },
                                    },

                                    evokerBox = {
                                        order = 4,
                                        type = 'group',
                                        name = BlueTitle(LuxClassWithIcon('evoker')),
                                        inline = true,
                                        args = {
                                            augmentation = {
                                                order = 1,
                                                type = 'execute',
                                                name = LuxSpec('augmentation'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('evoker_augmentation_luxthos', LuxLabel('evoker', 'augmentation')) end,
                                            },
                                            devastation = {
                                                order = 2,
                                                type = 'execute',
                                                name = LuxSpec('devastation'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('evoker_devastation_luxthos', LuxLabel('evoker', 'devastation')) end,
                                            },
                                            preservation = {
                                                order = 3,
                                                type = 'execute',
                                                name = LuxSpec('preservation'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('evoker_preservation_luxthos', LuxLabel('evoker', 'preservation')) end,
                                            },
                                        },
                                    },

                                    hunterBox = {
                                        order = 5,
                                        type = 'group',
                                        name = BlueTitle(LuxClassWithIcon('hunter')),
                                        inline = true,
                                        args = {
                                            beastMastery = {
                                                order = 1,
                                                type = 'execute',
                                                name = LuxSpec('beast_mastery'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('hunter_beastmastery_luxthos', LuxLabel('hunter', 'beast_mastery')) end,
                                            },
                                            marksmanship = {
                                                order = 2,
                                                type = 'execute',
                                                name = LuxSpec('marksmanship'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('hunter_marksmanship_luxthos', LuxLabel('hunter', 'marksmanship')) end,
                                            },
                                            survival = {
                                                order = 3,
                                                type = 'execute',
                                                name = LuxSpec('survival'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('hunter_survival_luxthos', LuxLabel('hunter', 'survival')) end,
                                            },
                                        },
                                    },

                                    mageBox = {
                                        order = 6,
                                        type = 'group',
                                        name = BlueTitle(LuxClassWithIcon('mage')),
                                        inline = true,
                                        args = {
                                            arcane = {
                                                order = 1,
                                                type = 'execute',
                                                name = LuxSpec('arcane'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('mage_arcane_luxthos', LuxLabel('mage', 'arcane')) end,
                                            },
                                            fire = {
                                                order = 2,
                                                type = 'execute',
                                                name = LuxSpec('fire'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('mage_fire_luxthos', LuxLabel('mage', 'fire')) end,
                                            },
                                            frost = {
                                                order = 3,
                                                type = 'execute',
                                                name = LuxSpec('frost'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('mage_frost_luxthos', LuxLabel('mage', 'frost')) end,
                                            },
                                        },
                                    },

                                    monkBox = {
                                        order = 7,
                                        type = 'group',
                                        name = BlueTitle(LuxClassWithIcon('monk')),
                                        inline = true,
                                        args = {
                                            brewmaster = {
                                                order = 1,
                                                type = 'execute',
                                                name = LuxSpec('brewmaster'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('monk_brewmaster_luxthos', LuxLabel('monk', 'brewmaster')) end,
                                            },
                                            mistweaver = {
                                                order = 2,
                                                type = 'execute',
                                                name = LuxSpec('mistweaver'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('monk_mistweaver_luxthos', LuxLabel('monk', 'mistweaver')) end,
                                            },
                                            windwalker = {
                                                order = 3,
                                                type = 'execute',
                                                name = LuxSpec('windwalker'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('monk_windwalker_luxthos', LuxLabel('monk', 'windwalker')) end,
                                            },
                                        },
                                    },

                                    paladinBox = {
                                        order = 8,
                                        type = 'group',
                                        name = BlueTitle(LuxClassWithIcon('paladin')),
                                        inline = true,
                                        args = {
                                            holy = {
                                                order = 1,
                                                type = 'execute',
                                                name = LuxSpec('holy'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('paladin_holy_luxthos', LuxLabel('paladin', 'holy')) end,
                                            },
                                            protection = {
                                                order = 2,
                                                type = 'execute',
                                                name = LuxSpec('protection'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('paladin_protection_luxthos', LuxLabel('paladin', 'protection')) end,
                                            },
                                            retribution = {
                                                order = 3,
                                                type = 'execute',
                                                name = LuxSpec('retribution'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('paladin_retribution_luxthos', LuxLabel('paladin', 'retribution')) end,
                                            },
                                        },
                                    },

                                    priestBox = {
                                        order = 9,
                                        type = 'group',
                                        name = BlueTitle(LuxClassWithIcon('priest')),
                                        inline = true,
                                        args = {
                                            discipline = {
                                                order = 1,
                                                type = 'execute',
                                                name = LuxSpec('discipline'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('priest_discipline_luxthos', LuxLabel('priest', 'discipline')) end,
                                            },
                                            holy = {
                                                order = 2,
                                                type = 'execute',
                                                name = LuxSpec('holy'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('priest_holy_luxthos', LuxLabel('priest', 'holy')) end,
                                            },
                                            shadow = {
                                                order = 3,
                                                type = 'execute',
                                                name = LuxSpec('shadow'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('priest_shadow_luxthos', LuxLabel('priest', 'shadow')) end,
                                            },
                                        },
                                    },

                                    rogueBox = {
                                        order = 10,
                                        type = 'group',
                                        name = BlueTitle(LuxClassWithIcon('rogue')),
                                        inline = true,
                                        args = {
                                            assassination = {
                                                order = 1,
                                                type = 'execute',
                                                name = LuxSpec('assassination'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('rogue_assassination_luxthos', LuxLabel('rogue', 'assassination')) end,
                                            },
                                            outlaw = {
                                                order = 2,
                                                type = 'execute',
                                                name = LuxSpec('outlaw'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('rogue_outlaw_luxthos', LuxLabel('rogue', 'outlaw')) end,
                                            },
                                            subtlety = {
                                                order = 3,
                                                type = 'execute',
                                                name = LuxSpec('subtlety'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('rogue_subtlety_luxthos', LuxLabel('rogue', 'subtlety')) end,
                                            },
                                        },
                                    },

                                    shamanBox = {
                                        order = 11,
                                        type = 'group',
                                        name = BlueTitle(LuxClassWithIcon('shaman')),
                                        inline = true,
                                        args = {
                                            elemental = {
                                                order = 1,
                                                type = 'execute',
                                                name = LuxSpec('elemental'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('shaman_elemental_luxthos', LuxLabel('shaman', 'elemental')) end,
                                            },
                                            enhancement = {
                                                order = 2,
                                                type = 'execute',
                                                name = LuxSpec('enhancement'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('shaman_enhancement_luxthos', LuxLabel('shaman', 'enhancement')) end,
                                            },
                                            restoration = {
                                                order = 3,
                                                type = 'execute',
                                                name = LuxSpec('restoration'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('shaman_restoration_luxthos', LuxLabel('shaman', 'restoration')) end,
                                            },
                                        },
                                    },

                                    warlockBox = {
                                        order = 12,
                                        type = 'group',
                                        name = BlueTitle(LuxClassWithIcon('warlock')),
                                        inline = true,
                                        args = {
                                            affliction = {
                                                order = 1,
                                                type = 'execute',
                                                name = LuxSpec('affliction'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('warlock_affliction_luxthos', LuxLabel('warlock', 'affliction')) end,
                                            },
                                            demonology = {
                                                order = 2,
                                                type = 'execute',
                                                name = LuxSpec('demonology'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('warlock_demonology_luxthos', LuxLabel('warlock', 'demonology')) end,
                                            },
                                            destruction = {
                                                order = 3,
                                                type = 'execute',
                                                name = LuxSpec('destruction'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('warlock_destruction_luxthos', LuxLabel('warlock', 'destruction')) end,
                                            },
                                        },
                                    },

                                    warriorBox = {
                                        order = 13,
                                        type = 'group',
                                        name = BlueTitle(LuxClassWithIcon('warrior')),
                                        inline = true,
                                        args = {
                                            arms = {
                                                order = 1,
                                                type = 'execute',
                                                name = LuxSpec('arms'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('warrior_arms_luxthos', LuxLabel('warrior', 'arms')) end,
                                            },
                                            fury = {
                                                order = 2,
                                                type = 'execute',
                                                name = LuxSpec('fury'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('warrior_fury_luxthos', LuxLabel('warrior', 'fury')) end,
                                            },
                                            protection = {
                                                order = 3,
                                                type = 'execute',
                                                name = LuxSpec('protection'),
                                                confirm = true,
                                                confirmText = LuxConfirm(),
                                                func = function() LizeUI:ImportLuxthos('warrior_protection_luxthos', LuxLabel('warrior', 'protection')) end,
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            },

            resources = {
                order = 40,
                type = 'group',
                name = LT('OPT_MENU_RESOURCES'),
                args = {
                    otherImportsHeader = {
                        order = 40,
                        type = 'header',
                        name = BlueTitle(LT('OPT_OTHER_IMPORTS_HEADER')),
                    },
                    otherImportsBox = {
                        order = 41,
                        type = 'group',
                        name = LT('OPT_SPACER'),
                        inline = true,
                        args = {
                    desc = {
                        order = 1,
                        type = 'description',
                        name = LT('OPT_OTHER_IMPORTS_DESC'),
                    },
                    spacer = {
                        order = 2,
                        type = 'description',
                        name = LT('OPT_SPACER'),
                    },
                    texturesBox = {
                        order = 3,
                        type = 'group',
                        name = BlueTitle(LT('OPT_TEXTURES')),
                        inline = true,
                        args = {
                            list = {
                                order = 1,
                                type = 'description',
                                name = function()
                                    return BuildLSMResourceList('statusbar', ADDON_PATH .. 'media\\textures')
                                end,
                            },
                        },
                    },
                    fontsBox = {
                        order = 4,
                        type = 'group',
                        name = BlueTitle(LT('OPT_FONTS')),
                        inline = true,
                        args = {
                            list = {
                                order = 1,
                                type = 'description',
                                name = function()
                                    return BuildLSMResourceList('font', ADDON_PATH .. 'media\\fonts')
                                end,
                            },
                        },
                    },
                        },
                    },
                },
            },

            information = {
                order = 50,
                type = 'group',
                name = LT('OPT_MENU_INFORMATION'),
                args = {
                    infoTopBox = {
                        order = 1,
                        type = 'group',
                        name = BlueTitle(LT('OPT_INFO_SECTION_TITLE')),
                        inline = true,
                        args = {
                            desc = {
                                order = 1,
                                type = 'description',
                                name = LT('OPT_INFO_SECTION_DESC'),
                            },
                            spacer = {
                                order = 2,
                                type = 'description',
                                name = ' \n ',
                                width = 'full',
                            },
                        },
                    },
                    donateBox = {
                        order = 2,
                        type = 'group',
                        name = BlueTitle(LT('OPT_DONATE_TITLE')),
                        inline = true,
                        args = {
                            desc = {
                                order = 1,
                                type = 'description',
                                fontSize = 'medium',
                                name = function()
                                    local gradient = GradientText('LizeUI', 0, 192, 250, 130, 85, 255)
                                    return (LT('OPT_DONATE_LINE1_FMT'):format(gradient) .. '\n' .. LT('OPT_DONATE_LINE2') .. '\n' .. LT('OPT_DONATE_LINE3'))
                                end,
                            },
                            spacer = {
                                order = 1.5,
                                type = 'description',
                                name = ' \n ',
                                width = 'full',
                            },
                            patreon = UrlButton(2, ('|T%s:14:14:0:0|t %s'):format(CAFE_ICON, LT('OPT_DONATE_BUTTON_PATREON')), 'https://www.patreon.com/Lizerius', 1.7),
                        },
                    },
                    linksBox = {
                        order = 3,
                        type = 'group',
                        name = BlueTitle(LT('OPT_LINKS_TITLE')),
                        inline = true,
                        args = {
                            desc = {
                                order = 1,
                                type = 'description',
                                name = LT('OPT_LINKS_DESC'),
                            },
                            spacer = {
                                order = 1.5,
                                type = 'description',
                                name = ' ',
                                width = 'full',
                            },
                            curseforgeLabel = {
                                order = 2,
                                type = 'description',
                                name = LT('OPT_LINK_CURSEFORGE'),
                                width = 'full',
                            },
                            curseforgeUrl = {
                                order = 2.1,
                                type = 'input',
                                name = '',
                                width = 'full',
                                get = function() return 'https://www.curseforge.com/wow/addons/elvui-lizeui' end,
                                set = function() end,
                            },
                            spacer2 = {
                                order = 2.2,
                                type = 'description',
                                name = ' ',
                                width = 'full',
                            },
                            wagoLabel = {
                                order = 3,
                                type = 'description',
                                name = LT('OPT_LINK_WAGO'),
                                width = 'full',
                            },
                            wagoUrl = {
                                order = 3.1,
                                type = 'input',
                                name = '',
                                width = 'full',
                                get = function() return 'https://addons.wago.io/addons/lizeui' end,
                                set = function() end,
                            },
                        },
                    },
                },
            },
        },
    }
end

function LizeUI:InsertOptions()
    if not (E and E.Options and E.Options.args) then return end

    -- Apply locale before building the options table.
    local mode = self:GetLanguageMode()
    if mode == 'en' then mode = 'enUS' end
    if mode == 'es' then mode = 'esES' end
    self:ApplyLanguageMode(mode)

    local optionsTable = BuildOptionsTable()

    -- Insertar LizeUI como categoría principal (mismo nivel que General/ActionBars/etc.)
    E.Options.args[addonName] = optionsTable

    self:EnsurePluginsLine()

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
                LizeUI:EnsurePluginsLine()
            end)
        end
    end
end
