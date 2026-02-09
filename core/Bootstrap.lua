-- Bootstrap.lua: crea el módulo y el namespace compartido

local addonName, ns = ...

local E, L, V, P, G = unpack(ElvUI)
local LizeUI = E:NewModule('LizeUI', 'AceHook-3.0', 'AceEvent-3.0')

ns.addonName = addonName
ns.E, ns.L, ns.V, ns.P, ns.G = E, L, V, P, G
ns.LizeUI = LizeUI

ns.IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded

ns.ADDON_PATH = 'Interface\\AddOns\\' .. addonName .. '\\'
ns.LIZEUI_ICON_PATH = ns.ADDON_PATH .. 'media\\textures\\icons\\lizeui.tga'
