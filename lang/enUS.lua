-- Base locale (English). Always loaded as fallback.

_G.LizeUI_Locales = _G.LizeUI_Locales or {}
local L = {}

-- Options UI
L.OPT_LAUNCH_INSTALLER = 'Launch installer'
L.OPT_INFO_TITLE = 'Information'
L.OPT_INFO_DESC = 'From here you can enable/disable LizeUI features and import profiles for ElvUI and companion addons.\n\nNote: some options may require /reload to fully apply.'
L.OPT_SPACER = ' '

-- Side menu sections
L.OPT_MENU_DEPENDENCIES = 'Dependencies'
L.OPT_MENU_FEATURES = 'Features'
L.OPT_MENU_IMPORTS = 'Imports'
L.OPT_MENU_RESOURCES = 'Resources'
L.OPT_MENU_INFORMATION = 'Information'

L.OPT_INFO_SECTION_TITLE = 'Donors'
L.OPT_INFO_SECTION_DESC = ' '

L.OPT_DONATE_TITLE = 'Donations'
L.OPT_DONATE_LINE1_FMT = 'Thank you for using %s!'
L.OPT_DONATE_LINE2 = 'With your support I can keep improving the interface and maintaining compatibility with new game/ElvUI updates.'
L.OPT_DONATE_LINE3 = 'Donations may also give you access to direct communication with development and requests for custom modules.'
L.OPT_DONATE_BUTTON_PATREON = 'Donate (Patreon)'

L.OPT_LINKS_TITLE = 'Links'
L.OPT_LINKS_DESC = 'You can download LizeUI from these sources:'
L.OPT_LINK_CURSEFORGE = 'CurseForge'
L.OPT_LINK_WAGO = 'Wago.io'

L.OPT_DEPS_TITLE = 'Important/Recommended Addon Dependencies'
L.OPT_DEPS_DESC = 'These addons are important to make the interface look the same. If the icon is red, enable/install them on the character selection screen → AddOns.'

L.OPT_DEPS_LEGEND_ACTIVE = 'Enabled'
L.OPT_DEPS_LEGEND_INACTIVE = 'Disabled'
L.OPT_DEPS_LEGEND_MISSING = 'Missing'

L.OPT_DEPS_STATUS_TITLE = 'Important addon status'
L.OPT_DEPS_MANDATORY_STATUS_TITLE = 'Mandatory addon status'
L.OPT_DEPS_RECOMMENDED_STATUS_TITLE = 'Recommended addon status'

L.OPT_QOL_HEADER = 'Quality of life features'
L.OPT_IMPORTS_MAIN_HEADER = 'Imports to install LizeUI'

L.OPT_QOL_BOX_TITLE = 'Quality of life (QoL)'
L.OPT_BUGFIX_BOX_TITLE = 'Bug fixes'

L.OPT_SUPPRESS_RIGHTCLICK_NAME = 'Suppress right-click (double click)'
L.OPT_SUPPRESS_RIGHTCLICK_DESC = 'Prevents a “loose” right-click from breaking mouselook in combat (may require reload for full effect).'

L.OPT_GLOBAL_FADE_NAME = 'Global Fade Persist (vehicle)'
L.OPT_GLOBAL_FADE_DESC = 'Keeps global actionbar fading consistent while in a vehicle.'

L.OPT_HIDE_PET_DEMON_NAME = 'Hide pet/demon frame'
L.OPT_HIDE_PET_DEMON_DESC = 'Hides the pet (demon) frame if it appears.'

L.OPT_DISABLE_FRIENDLY_NPC_HEALTHBARS_NAME = 'Disable friendly NPC health bars (on load)'
L.OPT_DISABLE_FRIENDLY_NPC_HEALTHBARS_DESC = 'On login/reload, disables the Blizzard option that shows friendly NPC nameplate health bars.'


L.OPT_ELVUI_IMPORTS_TITLE = 'LizeUI imports for ElvUI'
L.OPT_ELVUI_IMPORTS_DESC = 'Import LizeUI profiles into ElvUI based on your resolution.'

L.OPT_ELVUI_3K_BUTTON = 'LizeUI 3440x1440 (3K)'
L.OPT_ELVUI_3K_CONFIRM = 'Import the LizeUI profile into ElvUI (3K 3440x1440)?'
L.OPT_ELVUI_2K_BUTTON = 'LizeUI 2560x1440 (2K)'
L.OPT_ELVUI_2K_CONFIRM = 'Import the LizeUI profile into ElvUI (2K 2560x1440)?'
L.OPT_ELVUI_1K_BUTTON = 'LizeUI 1920x1080 (1K)'
L.OPT_ELVUI_1K_CONFIRM = 'Import the LizeUI profile into ElvUI (1K 1920x1080)?'
L.OPT_NOT_AVAILABLE = 'Not available yet'

L.OPT_WOW_IMPORTS_TITLE = 'LizeUI imports for WoW (Edit Mode)'
L.OPT_WOW_IMPORTS_DESC = 'Import the native WoW frame layout (Edit Mode) based on your resolution.'
L.OPT_WOW_IMPORTS_IMPORTANT = '|cffff0000Important: To see LizeUI correctly you must do these imports|r'

L.OPT_WOW_3K_BUTTON = 'WoW Edit Mode (3K)'
L.OPT_WOW_3K_CONFIRM = 'Import the WoW (Edit Mode) layout for 3K 3440x1440?'
L.OPT_WOW_2K_BUTTON = 'WoW Edit Mode (2K)'
L.OPT_WOW_2K_CONFIRM = 'Import the WoW (Edit Mode) layout for 2K 2560x1440?'
L.OPT_WOW_1K_BUTTON = 'WoW Edit Mode (1K)'
L.OPT_WOW_1K_CONFIRM = 'Import the WoW (Edit Mode) layout for 1K 1920x1080?'

L.OPT_ADDON_IMPORTS_TITLE = 'Companion addon imports'
L.OPT_ADDON_IMPORTS_DESC = 'Import LizeUI profiles into the corresponding addons.'
L.OPT_IMPORT_WINDTOOLS = 'Import WindTools'
L.OPT_CONFIRM_WINDTOOLS = 'Import the LizeUI profile into WindTools?'
L.OPT_IMPORT_PLATER = 'Import Plater'
L.OPT_CONFIRM_PLATER = 'Import the LizeUI profile into Plater?'
L.OPT_IMPORT_BCDM = 'Import BetterCooldownManager'
L.OPT_CONFIRM_BCDM = 'Imports the LizeUI BetterCooldownManager configuration into a new profile.'
L.OPT_IMPORT_DETAILS = 'Import Details'
L.OPT_CONFIRM_DETAILS = 'Import the LizeUI profile into Details?'

-- Imports tabs
L.OPT_IMPORTS_TAB_INTERFACE = 'Interface'
L.OPT_IMPORTS_TAB_SKILLS = 'Abilities'

-- Luxthos (WeakAuras) imports
L.OPT_LUXTHOS_CONFIG_TITLE = 'Cooldown settings (Ability Configuration)'
L.OPT_LUXTHOS_WARLOCK_TITLE = 'Warlocks'

-- Luxthos (Cooldown Manager)
L.OPT_LUXTHOS_CONFIRM_COOLDOWN_MANAGER = 'Import Luxthos profile for Cooldown Manager?'
L.OPT_LUXTHOS_LABEL_FMT = 'WoW (Luxthos) - %s: %s'
L.OPT_LUXTHOS_INFO_DESC = 'These cooldown imports are |cff03fc9cbased on creations|r by |cff03fc9cLuxthos|r, a well-known WoW community contributor and streamer. If you enjoy this setup, consider checking out his work and supporting him through the official links below.'
L.OPT_LUXTHOS_WEB_BUTTON = 'Luxthos website'
L.OPT_LUXTHOS_PATREON_BUTTON = 'Luxthos Patreon'

-- Classes
L.OPT_LUXTHOS_CLASS_DEATH_KNIGHT = 'Death Knight'
L.OPT_LUXTHOS_CLASS_DEMON_HUNTER = 'Demon Hunter'
L.OPT_LUXTHOS_CLASS_DRUID = 'Druid'
L.OPT_LUXTHOS_CLASS_EVOKER = 'Evoker'
L.OPT_LUXTHOS_CLASS_HUNTER = 'Hunter'
L.OPT_LUXTHOS_CLASS_MAGE = 'Mage'
L.OPT_LUXTHOS_CLASS_MONK = 'Monk'
L.OPT_LUXTHOS_CLASS_PALADIN = 'Paladin'
L.OPT_LUXTHOS_CLASS_PRIEST = 'Priest'
L.OPT_LUXTHOS_CLASS_ROGUE = 'Rogue'
L.OPT_LUXTHOS_CLASS_SHAMAN = 'Shaman'
L.OPT_LUXTHOS_CLASS_WARLOCK = 'Warlock'
L.OPT_LUXTHOS_CLASS_WARRIOR = 'Warrior'

-- Specs
L.OPT_LUXTHOS_SPEC_AFFLICTION = 'Affliction'
L.OPT_LUXTHOS_SPEC_ARCANE = 'Arcane'
L.OPT_LUXTHOS_SPEC_ARMS = 'Arms'
L.OPT_LUXTHOS_SPEC_ASSASSINATION = 'Assassination'
L.OPT_LUXTHOS_SPEC_AUGMENTATION = 'Augmentation'
L.OPT_LUXTHOS_SPEC_BALANCE = 'Balance'
L.OPT_LUXTHOS_SPEC_BEAST_MASTERY = 'Beast Mastery'
L.OPT_LUXTHOS_SPEC_BLOOD = 'Blood'
L.OPT_LUXTHOS_SPEC_BREWMASTER = 'Brewmaster'
L.OPT_LUXTHOS_SPEC_DEMONOLOGY = 'Demonology'
L.OPT_LUXTHOS_SPEC_DESTRUCTION = 'Destruction'
L.OPT_LUXTHOS_SPEC_DEVASTATION = 'Devastation'
L.OPT_LUXTHOS_SPEC_DEVOURER = 'Devourer'
L.OPT_LUXTHOS_SPEC_DISCIPLINE = 'Discipline'
L.OPT_LUXTHOS_SPEC_ELEMENTAL = 'Elemental'
L.OPT_LUXTHOS_SPEC_ENHANCEMENT = 'Enhancement'
L.OPT_LUXTHOS_SPEC_FERAL = 'Feral'
L.OPT_LUXTHOS_SPEC_FIRE = 'Fire'
L.OPT_LUXTHOS_SPEC_FROST = 'Frost'
L.OPT_LUXTHOS_SPEC_FURY = 'Fury'
L.OPT_LUXTHOS_SPEC_GUARDIAN = 'Guardian'
L.OPT_LUXTHOS_SPEC_HAVOC = 'Havoc'
L.OPT_LUXTHOS_SPEC_HOLY = 'Holy'
L.OPT_LUXTHOS_SPEC_MARKSMANSHIP = 'Marksmanship'
L.OPT_LUXTHOS_SPEC_MISTWEAVER = 'Mistweaver'
L.OPT_LUXTHOS_SPEC_OUTLAW = 'Outlaw'
L.OPT_LUXTHOS_SPEC_PRESERVATION = 'Preservation'
L.OPT_LUXTHOS_SPEC_PROTECTION = 'Protection'
L.OPT_LUXTHOS_SPEC_RESTORATION = 'Restoration'
L.OPT_LUXTHOS_SPEC_RETRIBUTION = 'Retribution'
L.OPT_LUXTHOS_SPEC_SHADOW = 'Shadow'
L.OPT_LUXTHOS_SPEC_SUBTLETY = 'Subtlety'
L.OPT_LUXTHOS_SPEC_SURVIVAL = 'Survival'
L.OPT_LUXTHOS_SPEC_UNHOLY = 'Unholy'
L.OPT_LUXTHOS_SPEC_VENGEANCE = 'Vengeance'
L.OPT_LUXTHOS_SPEC_WINDWALKER = 'Windwalker'

L.OPT_LUXTHOS_WARLOCK_AFFLICTION_LABEL = 'WoW (Luxthos) - Warlock: Affliction'
L.OPT_LUXTHOS_WARLOCK_AFFLICTION_BUTTON = 'Affliction'
L.OPT_LUXTHOS_WARLOCK_AFFLICTION_CONFIRM = 'Import the Luxthos string for Warlock (Affliction)?'

L.OPT_LUXTHOS_WARLOCK_DEMONOLOGY_LABEL = 'WoW (Luxthos) - Warlock: Demonology'
L.OPT_LUXTHOS_WARLOCK_DEMONOLOGY_BUTTON = 'Demonology'
L.OPT_LUXTHOS_WARLOCK_DEMONOLOGY_CONFIRM = 'Import the Luxthos string for Warlock (Demonology)?'

L.OPT_LUXTHOS_WARLOCK_DESTRUCTION_LABEL = 'WoW (Luxthos) - Warlock: Destruction'
L.OPT_LUXTHOS_WARLOCK_DESTRUCTION_BUTTON = 'Destruction'
L.OPT_LUXTHOS_WARLOCK_DESTRUCTION_CONFIRM = 'Import the Luxthos string for Warlock (Destruction)?'

L.OPT_OTHER_IMPORTS_HEADER = 'Other import information'
L.OPT_OTHER_IMPORTS_DESC = 'LizeUI also registers additional resources (textures and fonts) via SharedMedia. They are not imported as “profiles”, but become available for other addons.'
L.OPT_TEXTURES = 'Textures'
L.OPT_FONTS = 'Fonts'

-- Installer / Welcome window
L.INSTALL_TITLE = 'LizeUI Installation'
L.INSTALL_SUBTITLE = 'Welcome to LizeUI'
L.INSTALL_DESC1 = 'LizeUI is an interface package for |cff00c0faElvUI|r built to look clean, clear, and properly aligned from the start. It includes multiple configurations based on your resolution (|cff00ff002K/3K|r) to keep scaling, proportions, and spacing consistent with the intended layout.\n\nIt also adds quality-of-life utilities and ships a large set of textures and fonts to enhance the overall look of the game. To help you achieve the full setup, LizeUI includes auto-importers and integrations for the required companion addons, as long as you have them installed and enabled.\n\nYou can reopen this installer anytime with |cff00ff00/lizeui install|r.'

-- (Compat) these lines are no longer used on installer page 1
L.INSTALL_DESC2 = ' '
L.INSTALL_DESC3 = ' '
L.INSTALL_DESC4 = ' '
L.INSTALL_DEPS_SUBTITLE = 'Dependencies (mandatory & important)'
L.INSTALL_DEPS_DESC1 = 'Addons required to match the intended LizeUI look. Left: status. Right: import (if available) and copy the link.'
L.INSTALL_DEPS_IMPORT = 'Import'
L.INSTALL_DEPS_DOWNLOAD = 'Download'
L.INSTALL_DEPS_TAG_MANDATORY = 'Mandatory'
L.INSTALL_DEPS_TAG_IMPORTANT = 'Important'
L.INSTALL_DEPS_COPY_TEXT_FMT = 'Download link: %s'

L.INSTALL_RECS_SUBTITLE = 'Recommended addons'
L.INSTALL_RECS_DESC1 = 'Optional, but recommended to complete the LizeUI experience. Left: status. Right: copy the link.'
L.INSTALL_RECS_TAG = 'Recommended'

L.INSTALL_BCDM_SUBTITLE = 'BetterCooldownManager'
L.INSTALL_BCDM_DESC1 = 'On this page you can import BetterCooldownManager and choose whether you want to show the mana/rage/energy bar. For some characters the resource usage is so low that it is better to hide it (in LizeUI that bar is kept small).'
L.INSTALL_BCDM_USE_BUTTON = 'I use mana / rage / energy'
L.INSTALL_BCDM_NOUSE_BUTTON = 'I do NOT use mana / rage / energy'
L.INSTALL_BCDM_QUESTION = 'Which resources does your character use?'
L.INSTALL_BCDM_ALL_BUTTON = 'Resources / Class bar'
L.INSTALL_BCDM_MANA_BUTTON = 'Resources only'
L.INSTALL_BCDM_NO_MANA_BUTTON = 'Class bar only'
L.INSTALL_CLASS_SUBTITLE = 'Class imports'
L.INSTALL_CLASS_DESC1 = 'Here you will be able to import class-specific configurations.'

L.INSTALL_CHAT_SUBTITLE = 'Chat'
L.INSTALL_CHAT_DESC1 = 'This step configures your chat windows (names, positions, and colors) to match the LizeUI layout.'
L.INSTALL_CHAT_DESC2 = 'After that, you can move/rename tabs just like Blizzard chat. Click the button to apply the setup.'
L.INSTALL_CHAT_BUTTON = 'Setup Chat'
L.INSTALL_CHAT_DONE = 'Chat configured'

L.INSTALL_SCALE_SUBTITLE = 'UI Scale'
L.INSTALL_SCALE_DESC1 = 'LizeUI is designed around a |cff00c0fa0.66|r UI scale. If you use a different scale, some elements may look shifted or misaligned. Use the slider to adjust it manually.'
L.INSTALL_SCALE_BUTTON = 'LizeUI Settings'

L.INSTALL_FINISH_SUBTITLE = 'Finish installation'
L.INSTALL_FINISH_DESC1 = 'All set. Click Finish to reload your UI and apply the changes properly.'
L.INSTALL_FINISH_BUTTON = 'Finish'

-- Config header / plugin line
L.CFG_LINE_FMT = '|cff00c0faLizeUI|r |cffaaaaaaby|r |cff00ff00%s|r - |cffaaaaaaVersion:|r |cff00ff00%s|r'

-- Import messages
L.MSG_MISSING_IMPORT_STRING_FMT = 'LizeUI: Missing import string for %s (%s) in LizeUI/imports/Imports.lua'
L.MSG_ELVUI_NOT_AVAILABLE = 'LizeUI: ElvUI is not available for import.'
L.MSG_ELVUI_DISTRIBUTOR_MISSING = 'LizeUI: ElvUI Distributor module not found.'
L.MSG_PROFILE_IMPORTED_FMT = 'LizeUI: Profile imported into %s.'
L.MSG_IMPORT_ERROR_FMT = 'LizeUI: Error importing into %s: %s'

L.MSG_WEAKAURAS_NOT_LOADED = 'LizeUI: Import editor not available.'
L.MSG_WEAKAURAS_NO_IMPORT_API = 'LizeUI: No import API detected.'

L.MSG_WINDTOOLS_MISSING_STRING = 'LizeUI: Missing WindTools import string in LizeUI/imports/Imports.lua'
L.MSG_WINDTOOLS_NOT_LOADED = 'LizeUI: WindTools is not loaded.'
L.MSG_WINDTOOLS_API_MISSING = 'LizeUI: F.Profiles.ImportByString not found (WindTools).'
L.MSG_WINDTOOLS_IMPORTED_RELOADING = 'LizeUI: Profile imported into WindTools. Reloading UI...'
L.MSG_WINDTOOLS_IMPORT_ERROR_FMT = 'LizeUI: Error importing into WindTools: %s'

L.MSG_PLATER_MISSING_STRING = 'LizeUI: Missing Plater import string in LizeUI/imports/Imports.lua'
L.MSG_PLATER_API_MISSING = 'LizeUI: Plater is not loaded or does not expose ImportAndSwitchProfile.'
L.MSG_PLATER_IMPORTED = 'LizeUI: Profile imported into Plater.'
L.MSG_PLATER_IMPORT_ERROR_FMT = 'LizeUI: Error importing into Plater: %s'

-- Reload prompt (Plater)
L.POPUP_RELOAD_UI_TEXT_PLATER = 'Plater profile imported. To ensure all changes apply correctly, you should reload the UI now.'
L.POPUP_RELOAD_UI_TEXT_ELVUI = 'ElvUI profile imported. To ensure all changes apply correctly, you should reload the UI now.'
L.POPUP_RELOAD_UI_TEXT_WINDTOOLS = 'WindTools profile imported. To ensure all changes apply correctly, you should reload the UI now.'
L.POPUP_RELOAD_UI_TEXT_BCDM = 'BetterCooldownManager profile imported. To ensure all changes apply correctly, you should reload the UI now.'
L.POPUP_RELOAD_UI_RELOAD = 'Reload'
L.POPUP_RELOAD_UI_CANCEL = 'Cancel'

-- Duplicate name prompt (imports)
L.POPUP_DUPLICATE_NAME_TEXT_FMT = 'A %s named |cff03fc9c%s|r already exists. What do you want to do?'
L.POPUP_DUPLICATE_NAME_REPLACE = 'Replace'
L.POPUP_DUPLICATE_NAME_KEEP = 'Load existing'
L.POPUP_DUPLICATE_KIND_PROFILE = 'profile'
L.POPUP_DUPLICATE_KIND_LAYOUT = 'layout'

L.MSG_DUPLICATE_KEEP_SELECTED_FMT = 'LizeUI: Loaded existing %s "%s" and selected it.'

-- Missing important addons prompt
L.POPUP_IMPORTANT_ADDONS_TEXT_FMT = 'To make the interface look the same, these addons should be installed and enabled:\n\n%s\n\nYou can enable them from the character selection screen → AddOns.\n\nClick OK to not show this message again.'
L.POPUP_IMPORTANT_ADDONS_OK = 'OK'
L.POPUP_IMPORTANT_ADDONS_LATER = 'Later'
L.POPUP_IMPORTANT_ADDONS_MISSING = 'missing'
L.POPUP_IMPORTANT_ADDONS_DISABLED = 'disabled'


L.MSG_WOW_COPY_PASTE_HELP = 'LizeUI: Copy the string from the window and paste it into Edit Mode → Layouts → Import.'
L.MSG_WOW_VISUAL_HINT = 'LizeUI: If it does not apply visually, try /reload and select the layout in Edit Mode.'

L.MSG_WOW_IMPORTING_FMT = 'LizeUI: Importing %s (len=%d)...'
L.MSG_WOW_AUTO_IMPORT_FAILED_FMT = 'LizeUI: Auto-import failed for %s: %s'
L.MSG_DEBUG_C_EDITMODE_MISSING = 'LizeUI: Debug: C_EditMode does not exist.'
L.MSG_DEBUG_C_EDITMODE_FUNCTIONS_FMT = 'LizeUI: Debug: Functions in C_EditMode: %s'
L.MSG_WOW_LAYOUT_IMPORTED_API_FMT = 'LizeUI: Layout imported into %s (API=%s).'
L.MSG_WOW_LAYOUT_IMPORTED_API_ID_FMT = 'LizeUI: Layout imported into %s (API=%s, layoutID=%s).'
L.MSG_WOW_LAYOUT_SAVED_NAME_FMT = 'LizeUI: Saved layout name: %s'

L.REASON_EDITMODE_API_UNAVAILABLE = 'Edit Mode API not available'
L.REASON_NO_NEW_LAYOUT_DETECTED = 'No new layout detected after import'
L.REASON_API_DID_NOT_ADD_LAYOUT = 'The API did not add any layout (or it could not be detected)'

L.MSG_BCDM_MISSING_STRING = 'LizeUI: Missing BetterCooldownManager import string in LizeUI/imports/Imports.lua'
L.MSG_BCDM_API_MISSING = 'LizeUI: BCDMG:ImportBCDM not found (BetterCooldownManager).'
L.MSG_BCDM_IMPORTED = 'LizeUI: Profile imported into BetterCooldownManager.'
L.MSG_BCDM_IMPORT_ERROR_FMT = 'LizeUI: Error importing into BetterCooldownManager: %s'

L.MSG_DETAILS_MISSING_STRING = 'LizeUI: Missing Details import string in LizeUI/imports/Imports.lua'
L.MSG_DETAILS_NOT_LOADED = 'LizeUI: Details is not loaded.'
L.MSG_DETAILS_NO_IMPORT_API = 'LizeUI: No known import function found in Details (ImportProfile/ImportProfileFromString/ImportSettings).'
L.MSG_DETAILS_IMPORT_ERROR_FMT = 'LizeUI: Error importing into Details: %s'
L.MSG_DETAILS_IMPORT_OK_FMT = 'LizeUI: Details import OK (%s).'
L.MSG_DETAILS_ACTIVE_PROFILE_FMT = 'LizeUI: Active profile in Details: %s'
L.MSG_DETAILS_IMPORT_DONE_NOT_APPLIED_FMT = 'LizeUI: Import completed, but I could not force the profile switch automatically. If you do not see changes, select the profile "%s" inside Details.'

L.MSG_DETAILS_STRING_INFO_FMT = 'LizeUI: Details import string len=%d head=%s tail=%s'
L.MSG_DETAILS_RETURNED_INVALID_FMT = '%s returned %s (invalid or unsupported string)'

-- Copy window
L.COPYWIN_TITLE_FMT = 'LizeUI: %s'
L.COPYWIN_HELP = 'Copy this string and paste it into: Edit Mode → Layouts → Import.'
L.COPYWIN_HELP_WEAKAURAS = 'Copy this string and paste it into the new in-game WoW editor → Import.'
L.COPYWIN_HELP_COOLDOWN_MANAGER = 'Copy this string and paste it into: Options → Gameplay Enhancements → Cooldown Manager → Advanced Cooldown Settings → Import.'
L.COPYWIN_SELECT_ALL = 'Select all'
L.COPYWIN_CLOSE = 'Close'

-- Slash commands
L.CMD_HELP_TITLE = 'LizeUI commands:'
L.CMD_HELP_LINE1 = '/lizeui test_english  - Force English UI text'
L.CMD_HELP_LINE2 = '/lizeui test_spanish  - Force Spanish UI text'
L.CMD_HELP_LINE3 = '/lizeui test_reset_language - Back to auto-detect'
L.CMD_HELP_LINE4 = '/lizeui help - Show this help'
L.CMD_HELP_LINE5 = '/lizeui install - Open the installer'
L.CMD_HELP_LINE6 = '/lizeui install_reset - Reset installer popup (this character)'
L.CMD_HELP_LINE7 = '/lizeui install_reset_all - Reset installer popup (all characters)'

L.CMD_LANG_FORCED_EN = 'LizeUI: Language forced to English for testing.'
L.CMD_LANG_FORCED_ES = 'LizeUI: Language forced to Spanish for testing.'
L.CMD_LANG_RESET = 'LizeUI: Language reset to auto-detect.'
L.CMD_UNKNOWN = 'LizeUI: Unknown command. Use /lizeui help'

L.CMD_INSTALL_RESET_CHAR = 'LizeUI: Installer state reset for this character.'
L.CMD_INSTALL_RESET_ALL = 'LizeUI: Installer state reset for all characters.'

_G.LizeUI_Locales.enUS = L
