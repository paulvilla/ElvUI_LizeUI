-- Commands.lua: slash commands de LizeUI

local _, ns = ...

local LizeUI = ns.LizeUI
local E = ns.E
local addonName = ns.addonName or 'ElvUI_LizeUI'
local LT = ns.LT
local SplitWords = ns.SplitWords
local PrintMsg = ns.PrintMsg

function LizeUI:HandleSlashCommand(msg)
    local parts = SplitWords(msg)
    local cmd = (parts[1] and string.lower(parts[1])) or ''

    if cmd == '' then
        if E and type(E.ToggleOptions) == 'function' then
            E:ToggleOptions(addonName)
        end
        return
    end

    if cmd == 'help' then
        PrintMsg(LT('CMD_HELP_TITLE'))
        -- Orden solicitado:
        -- help → install → install_reset → install_reset_all → test_english → test_spanish → test_reset_language
        PrintMsg(LT('CMD_HELP_LINE4'))
        if LT('CMD_HELP_LINE5') then PrintMsg(LT('CMD_HELP_LINE5')) end
        if LT('CMD_HELP_LINE6') then PrintMsg(LT('CMD_HELP_LINE6')) end
        if LT('CMD_HELP_LINE7') then PrintMsg(LT('CMD_HELP_LINE7')) end
        PrintMsg(LT('CMD_HELP_LINE1'))
        PrintMsg(LT('CMD_HELP_LINE2'))
        PrintMsg(LT('CMD_HELP_LINE3'))
        return
    end

    if cmd == 'test_english' or cmd == 'test_en' or cmd == 'english' then
        self:SetLanguageMode('enUS')
        PrintMsg(LT('CMD_LANG_FORCED_EN'))
        return
    end

    if cmd == 'test_spanish' or cmd == 'test_es' or cmd == 'spanish' or cmd == 'espanol' or cmd == 'español' then
        self:SetLanguageMode('esES')
        PrintMsg(LT('CMD_LANG_FORCED_ES'))
        return
    end

    if cmd == 'test_reset_language'
        or cmd == 'test_reset_languaje'
        or cmd == 'test_resest_languaje'
        or cmd == 'reset_language'
        or cmd == 'reset_languaje'
        or cmd == 'reset'
        or cmd == 'auto'
    then
        self:SetLanguageMode(nil)
        PrintMsg(LT('CMD_LANG_RESET'))
        return
    end

    if cmd == 'install' or cmd == 'test_welcome' then
        if self.ShowInstallWindow then
            self:ShowInstallWindow(true)
        end
        return
    end

    if cmd == 'install_reset' then
        if type(self.ResetInstallerForChar) == 'function' then
            self:ResetInstallerForChar()
        end
        PrintMsg(LT('CMD_INSTALL_RESET_CHAR'))
        return
    end

    if cmd == 'install_reset_all' then
        if type(self.ResetInstallerForAllChars) == 'function' then
            self:ResetInstallerForAllChars()
        end
        PrintMsg(LT('CMD_INSTALL_RESET_ALL'))
        return
    end

    PrintMsg(LT('CMD_UNKNOWN'))
end

function LizeUI:RegisterSlashCommands()
    if self._lizeuiSlashRegistered then return end
    self._lizeuiSlashRegistered = true

    _G.SLASH_LIZEUI1 = '/lizeui'
    _G.SlashCmdList = _G.SlashCmdList or {}
    _G.SlashCmdList.LIZEUI = function(msg)
        if LizeUI and type(LizeUI.HandleSlashCommand) == 'function' then
            LizeUI:HandleSlashCommand(msg)
        end
    end
end
