-- Strings de importación
-- Nota: WoW no puede leer .txt en runtime: las strings se cargan como Lua vía el .toc (ver carpeta imports/).

local importStrings = _G.LizeUI_ImportStrings or {}

LizeUI_Imports = LizeUI_Imports or {
    elvui = {
        -- Export de ElvUI (Distributor). Ej: "!E1!..."
        data = importStrings.elvui or "",
    },

    elvui_3k = {
        -- Export de ElvUI (Distributor) para 3K (3440x1440)
        data = importStrings.elvui_3k or "",
    },
    elvui_2k = {
        -- Export de ElvUI (Distributor) para 2K (2560x1440)
        data = importStrings.elvui_2k or "",
    },
    elvui_1k = {
        -- Export de ElvUI (Distributor) para 1K (1920x1080)
        data = importStrings.elvui_1k or "",
    },

    wow_3k = {
        -- Export de Edit Mode (ventanas propias de WoW) para 3K (3440x1440)
        data = importStrings.wow_3k or "",
    },
    wow_2k = {
        -- Export de Edit Mode (ventanas propias de WoW) para 2K (2560x1440)
        data = importStrings.wow_2k or "",
    },
    wow_1k = {
        -- Export de Edit Mode (ventanas propias de WoW) para 1K (1920x1080)
        data = importStrings.wow_1k or "",
    },
    windtools = {
        -- Formato WindTools: profileString .. "{}" .. privateString
        data = importStrings.windtools or "",
    },
    plater = {
        -- Export de Plater. Ej: "!PLATER:2!..."
        profileName = "LizeUI",
        data = importStrings.plater or "",
    },
    betterCooldownManager = {
        -- Debe empezar con "!BCDM_" (export de BCDM)
        profileName = "LizeUI",
        data = importStrings.betterCooldownManager or "",
    },
    details = {
        -- Export de Details! (Import/Export de perfil)
        profileName = "LizeUI",
        data = importStrings.details or "",
    },
}
