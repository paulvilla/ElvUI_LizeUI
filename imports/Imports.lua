-- Strings de importación
-- Nota: WoW no puede leer .txt en runtime: las strings se cargan como Lua vía el .toc (ver carpeta imports/).

local importStrings = _G.LizeUI_ImportStrings or {}

LizeUI_Imports = LizeUI_Imports or {
    elvui = {
        -- Export de ElvUI (Distributor). Ej: "!E1!..."
        -- Nombre de perfil esperado (para detectar duplicados antes de importar).
        profileName = "LizeUI",
        data = importStrings.elvui or "",
    },

    elvui_3k = {
        -- Export de ElvUI (Distributor) para 3K (3440x1440)
        profileName = "LizeUI_3K",
        data = importStrings.elvui_3k or "",
    },
    elvui_2k = {
        -- Export de ElvUI (Distributor) para 2K (2560x1440)
        profileName = "LizeUI_2K",
        data = importStrings.elvui_2k or "",
    },
    elvui_1k = {
        -- Export de ElvUI (Distributor) para 1K (1920x1080)
        profileName = "LizeUI_1K",
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
        profileName = "LizeUI",
        data = importStrings.windtools or "",
    },
    plater = {
        -- Export de Plater. Ej: "!PLATER:2!..."
        profileName = "LizeUI",
        data = importStrings.plater or "",
    },
    betterCooldownManager = {
        -- Debe empezar con "!BCDM_" (export de BCDM)
        profileName = "LizeUI_all",
        data = importStrings.betterCooldownManager or "",
    },
    betterCooldownManager_all = {
        profileName = "LizeUI_all",
        data = importStrings.betterCooldownManager_all or "",
    },
    betterCooldownManager_mana = {
        profileName = "LizeUI_mana",
        data = importStrings.betterCooldownManager_mana or "",
    },
    betterCooldownManager_no_mana = {
        profileName = "LizeUI_no-mana",
        data = importStrings.betterCooldownManager_no_mana or "",
    },
    details = {
        -- Export de Details! (Import/Export de perfil)
        profileName = "LizeUI",
        data = importStrings.details or "",
    },

    -- Luxthos - Cooldown Manager (Ajustes avanzados) - Ajustes de tiempos de reutilización (Habilidades)
    deathknight_blood_luxthos = { data = importStrings.deathknight_blood_luxthos or "" },
    deathknight_frost_luxthos = { data = importStrings.deathknight_frost_luxthos or "" },
    deathknight_unholy_luxthos = { data = importStrings.deathknight_unholy_luxthos or "" },

    demonhunter_havoc_luxthos = { data = importStrings.demonhunter_havoc_luxthos or "" },
    demonhunter_vengeance_luxthos = { data = importStrings.demonhunter_vengeance_luxthos or "" },
    demonhunter_devourer_luxthos = { data = importStrings.demonhunter_devourer_luxthos or "" },

    druid_balance_luxthos = { data = importStrings.druid_balance_luxthos or "" },
    druid_feral_luxthos = { data = importStrings.druid_feral_luxthos or "" },
    druid_guardian_luxthos = { data = importStrings.druid_guardian_luxthos or "" },
    druid_restoration_luxthos = { data = importStrings.druid_restoration_luxthos or "" },

    evoker_augmentation_luxthos = { data = importStrings.evoker_augmentation_luxthos or "" },
    evoker_devastation_luxthos = { data = importStrings.evoker_devastation_luxthos or "" },
    evoker_preservation_luxthos = { data = importStrings.evoker_preservation_luxthos or "" },

    hunter_beastmastery_luxthos = { data = importStrings.hunter_beastmastery_luxthos or "" },
    hunter_marksmanship_luxthos = { data = importStrings.hunter_marksmanship_luxthos or "" },
    hunter_survival_luxthos = { data = importStrings.hunter_survival_luxthos or "" },

    mage_arcane_luxthos = { data = importStrings.mage_arcane_luxthos or "" },
    mage_fire_luxthos = { data = importStrings.mage_fire_luxthos or "" },
    mage_frost_luxthos = { data = importStrings.mage_frost_luxthos or "" },

    monk_brewmaster_luxthos = { data = importStrings.monk_brewmaster_luxthos or "" },
    monk_mistweaver_luxthos = { data = importStrings.monk_mistweaver_luxthos or "" },
    monk_windwalker_luxthos = { data = importStrings.monk_windwalker_luxthos or "" },

    paladin_holy_luxthos = { data = importStrings.paladin_holy_luxthos or "" },
    paladin_protection_luxthos = { data = importStrings.paladin_protection_luxthos or "" },
    paladin_retribution_luxthos = { data = importStrings.paladin_retribution_luxthos or "" },

    priest_discipline_luxthos = { data = importStrings.priest_discipline_luxthos or "" },
    priest_holy_luxthos = { data = importStrings.priest_holy_luxthos or "" },
    priest_shadow_luxthos = { data = importStrings.priest_shadow_luxthos or "" },

    rogue_assassination_luxthos = { data = importStrings.rogue_assassination_luxthos or "" },
    rogue_outlaw_luxthos = { data = importStrings.rogue_outlaw_luxthos or "" },
    rogue_subtlety_luxthos = { data = importStrings.rogue_subtlety_luxthos or "" },

    shaman_elemental_luxthos = { data = importStrings.shaman_elemental_luxthos or "" },
    shaman_enhancement_luxthos = { data = importStrings.shaman_enhancement_luxthos or "" },
    shaman_restoration_luxthos = { data = importStrings.shaman_restoration_luxthos or "" },

    warlock_affliction_luxthos = {
        data = importStrings.warlock_affliction_luxthos or "",
    },
    warlock_demonology_luxthos = {
        data = importStrings.warlock_demonology_luxthos or "",
    },
    warlock_destruction_luxthos = {
        data = importStrings.warlock_destruction_luxthos or "",
    },

    warrior_arms_luxthos = { data = importStrings.warrior_arms_luxthos or "" },
    warrior_fury_luxthos = { data = importStrings.warrior_fury_luxthos or "" },
    warrior_protection_luxthos = { data = importStrings.warrior_protection_luxthos or "" },
}
