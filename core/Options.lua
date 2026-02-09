-- Options.lua: construcción e inserción de opciones AceConfig (categoría LizeUI)

local addonName, ns = ...

local E = ns.E
local LizeUI = ns.LizeUI

local LT = ns.LT

local BlueTitle = ns.BlueTitle
local GradientText = ns.GradientText
local BuildLSMResourceList = ns.BuildLSMResourceList

local ADDON_PATH = ns.ADDON_PATH
local LIZEUI_ICON_PATH = ns.LIZEUI_ICON_PATH

local function BuildOptionsTable()
    return {
        type = 'group',
        name = ('|T%s:14:14:0:0|t %s'):format(LIZEUI_ICON_PATH, GradientText('LizeUI', 0, 192, 250, 130, 85, 255)),
        icon = LIZEUI_ICON_PATH,
        iconCoords = { 0.08, 0.92, 0.08, 0.92 },
        order = 100,
        args = {
            infoBox = {
                order = 10,
                type = 'group',
                name = BlueTitle(LT('OPT_INFO_TITLE')),
                inline = true,
                args = {
                    desc = {
                        order = 1,
                        type = 'description',
                        name = LT('OPT_INFO_DESC'),
                    },
                    spacer = {
                        order = 2,
                        type = 'description',
                        name = LT('OPT_SPACER'),
                    },
                    suppressRightClick = {
                        order = 3,
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
                        order = 4,
                        type = 'toggle',
                        name = LT('OPT_GLOBAL_FADE_NAME'),
                        desc = LT('OPT_GLOBAL_FADE_DESC'),
                        get = function() return LizeUIDB.features.globalFadePersist end,
                        set = function(_, value)
                            LizeUIDB.features.globalFadePersist = value
                            LizeUI:ApplyFeature('globalFadePersist', value)
                        end,
                    },
                    hidePetDemonBar = {
                        order = 5,
                        type = 'toggle',
                        name = LT('OPT_HIDE_PET_DEMON_NAME'),
                        desc = LT('OPT_HIDE_PET_DEMON_DESC'),
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
                        desc = LT('OPT_NOT_AVAILABLE'),
                        disabled = true,
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
                        desc = LT('OPT_NOT_AVAILABLE'),
                        disabled = true,
                        confirm = true,
                        confirmText = LT('OPT_WOW_1K_CONFIRM'),
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
                    importBCDM = {
                        order = 5,
                        type = 'execute',
                        name = LT('OPT_IMPORT_BCDM'),
                        confirm = true,
                        confirmText = LT('OPT_CONFIRM_BCDM'),
                        func = function() LizeUI:ImportBetterCooldownManager() end,
                    },
                    importDetails = {
                        order = 6,
                        type = 'execute',
                        name = LT('OPT_IMPORT_DETAILS'),
                        confirm = true,
                        confirmText = LT('OPT_CONFIRM_DETAILS'),
                        func = function() LizeUI:ImportDetails() end,
                    },
                },
            },
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
