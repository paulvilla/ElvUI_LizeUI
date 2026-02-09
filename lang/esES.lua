-- Spanish locale dictionary (esES + esMX). Always loaded so it can be forced for testing.

_G.LizeUI_Locales = _G.LizeUI_Locales or {}
local L = {}

-- Options UI
L.OPT_LAUNCH_INSTALLER = 'Lanzar instalador'
L.OPT_INFO_TITLE = 'Información'
L.OPT_INFO_DESC = 'Desde aquí puedes activar o desactivar funciones de LizeUI e importar perfiles para ElvUI y addons complementarios.\n\nNota: algunas opciones pueden requerir /reload para aplicarse por completo.'
L.OPT_SPACER = ' '

-- Side menu sections
L.OPT_MENU_DEPENDENCIES = 'Dependencias'
L.OPT_MENU_FEATURES = 'Funciones'
L.OPT_MENU_IMPORTS = 'Importaciones'
L.OPT_MENU_RESOURCES = 'Recursos'
L.OPT_MENU_INFORMATION = 'Información'

L.OPT_INFO_SECTION_TITLE = 'Donadores'
L.OPT_INFO_SECTION_DESC = ' '

L.OPT_DONATE_TITLE = 'Donaciones'
L.OPT_DONATE_LINE1_FMT = 'Gracias por usar %s!'
L.OPT_DONATE_LINE2 = 'Con tu apoyo podré seguir mejorando la interfaz y manteniendo la compatibilidad con nuevas actualizaciones del juego y de ElvUI.'
L.OPT_DONATE_LINE3 = 'Además, con las donaciones podrás optar a comunicación directa con el desarrollo y solicitar módulos personalizados.'
L.OPT_DONATE_BUTTON_PATREON = 'Donar (Patreon)'

L.OPT_LINKS_TITLE = 'Enlaces'
L.OPT_LINKS_DESC = 'Puedes conseguir LizeUI desde estas fuentes:'
L.OPT_LINK_CURSEFORGE = 'CurseForge'
L.OPT_LINK_WAGO = 'Wago.io'

L.OPT_DEPS_TITLE = 'Dependencias Addon Imprescindibles/Recomendados'
L.OPT_DEPS_DESC = 'Estos addons son imprescindibles para que la interfaz se vea igual. Si ves el icono en rojo, revisa en la pantalla de selección de personaje → AddOns que estén instalados y activados.'

L.OPT_DEPS_LEGEND_ACTIVE = 'Activo'
L.OPT_DEPS_LEGEND_INACTIVE = 'Sin activar'
L.OPT_DEPS_LEGEND_MISSING = 'Falta'

L.OPT_DEPS_STATUS_TITLE = 'Estado de los addons imprescindibles'
L.OPT_DEPS_MANDATORY_STATUS_TITLE = 'Estado de addons obligatorios'
L.OPT_DEPS_RECOMMENDED_STATUS_TITLE = 'Estado de addons recomendados'

L.OPT_QOL_HEADER = 'Funciones de mejora de vida'
L.OPT_IMPORTS_MAIN_HEADER = 'Importaciones para instalar LizeUI'

L.OPT_QOL_BOX_TITLE = 'Mejora de vida QoL'
L.OPT_BUGFIX_BOX_TITLE = 'Arreglo de bugs'

L.OPT_SUPPRESS_RIGHTCLICK_NAME = 'Suprimir click derecho (doble click)'
L.OPT_SUPPRESS_RIGHTCLICK_DESC = 'Evita que un click derecho “suelto” corte el mouselook en combate (requiere recarga para efecto completo).'

L.OPT_GLOBAL_FADE_NAME = 'Global Fade Persist (vehículo)'
L.OPT_GLOBAL_FADE_DESC = 'Mantiene el fade global de barras de acción consistente en vehículo.'

L.OPT_HIDE_PET_DEMON_NAME = 'Ocultar marco de mascota/demonio'
L.OPT_HIDE_PET_DEMON_DESC = 'Oculta el marco de la mascota (demonio) si aparece.'

L.OPT_DISABLE_FRIENDLY_NPC_HEALTHBARS_NAME = 'Ocultar barras de vida NPC amistoso persistente'
L.OPT_DISABLE_FRIENDLY_NPC_HEALTHBARS_DESC = 'Al entrar al juego o hacer /reload, desactiva la opción de Blizzard que muestra las barras/placas de NPC amistosos.'


L.OPT_ELVUI_IMPORTS_TITLE = 'Importación LizeUI para ElvUI'
L.OPT_ELVUI_IMPORTS_DESC = 'A continuación podrás importar los perfiles de LizeUI en ElvUI según tu resolución.'

L.OPT_ELVUI_3K_BUTTON = 'LizeUI 3440x1440 (3K)'
L.OPT_ELVUI_3K_CONFIRM = '¿Importar el perfil de LizeUI en ElvUI (3K 3440x1440)?'
L.OPT_ELVUI_2K_BUTTON = 'LizeUI 2560x1440 (2K)'
L.OPT_ELVUI_2K_CONFIRM = '¿Importar el perfil de LizeUI en ElvUI (2K 2560x1440)?'
L.OPT_ELVUI_1K_BUTTON = 'LizeUI 1920x1080 (1K)'
L.OPT_ELVUI_1K_CONFIRM = '¿Importar el perfil de LizeUI en ElvUI (1K 1920x1080)?'
L.OPT_NOT_AVAILABLE = 'Aún no disponible'

L.OPT_WOW_IMPORTS_TITLE = 'Importación LizeUI para WoW (Edit Mode)'
L.OPT_WOW_IMPORTS_DESC = 'A continuación podrás importar la configuración de ventanas nativas de WoW (Edit Mode) según tu resolución.'
L.OPT_WOW_IMPORTS_IMPORTANT = '|cffff0000Importante: Para ver bien LizeUI tienes que hacer estas importaciones|r'

L.OPT_WOW_3K_BUTTON = 'WoW Edit Mode (3K)'
L.OPT_WOW_3K_CONFIRM = '¿Importar el layout de WoW (Edit Mode) para 3K 3440x1440?'
L.OPT_WOW_2K_BUTTON = 'WoW Edit Mode (2K)'
L.OPT_WOW_2K_CONFIRM = '¿Importar el layout de WoW (Edit Mode) para 2K 2560x1440?'
L.OPT_WOW_1K_BUTTON = 'WoW Edit Mode (1K)'
L.OPT_WOW_1K_CONFIRM = '¿Importar el layout de WoW (Edit Mode) para 1K 1920x1080?'

L.OPT_ADDON_IMPORTS_TITLE = 'Importación de Addons complementarios'
L.OPT_ADDON_IMPORTS_DESC = 'A continuación podrás importar los perfiles de LizeUI en los addons correspondientes.'
L.OPT_IMPORT_WINDTOOLS = 'Import WindTools'
L.OPT_CONFIRM_WINDTOOLS = '¿Importar el perfil de LizeUI en WindTools?'
L.OPT_IMPORT_PLATER = 'Import Platers'
L.OPT_CONFIRM_PLATER = '¿Importar el perfil de LizeUI en Plater?'
L.OPT_IMPORT_BCDM = 'Import BetterCooldownManager'
L.OPT_CONFIRM_BCDM = 'Importa la configuración de BetterCooldownManager de LizeUI en un perfil nuevo.'
L.OPT_IMPORT_DETAILS = 'Import Details'
L.OPT_CONFIRM_DETAILS = '¿Importar el perfil de LizeUI en Details?'

-- Pestañas de Importaciones
L.OPT_IMPORTS_TAB_INTERFACE = 'Interfaz'
L.OPT_IMPORTS_TAB_SKILLS = 'Habilidades'

-- Luxthos (WeakAuras) imports
L.OPT_LUXTHOS_CONFIG_TITLE = 'Ajustes tiempos reutilizacion (Configuración de Habilidades)'
L.OPT_LUXTHOS_WARLOCK_TITLE = 'Brujos'

-- Luxthos (Cooldown Manager)
L.OPT_LUXTHOS_CONFIRM_COOLDOWN_MANAGER = '¿Importar el perfil de Luxthos para Cooldown Manager?'
L.OPT_LUXTHOS_LABEL_FMT = 'WoW (Luxthos) - %s: %s'
L.OPT_LUXTHOS_INFO_DESC = 'Estas importaciones de tiempos de reutilización están |cff03fc9cBasadas en creaciones|r de |cff03fc9cLuxthos|r, un gran contribuyente a la comunidad de WoW y streamer. Si te gusta este setup, puedes visitar su web y apoyarle a través de los enlaces oficiales de abajo.'
L.OPT_LUXTHOS_WEB_BUTTON = 'Web de Luxthos'
L.OPT_LUXTHOS_PATREON_BUTTON = 'Patreon de Luxthos'

-- Clases
L.OPT_LUXTHOS_CLASS_DEATH_KNIGHT = 'Caballero de la Muerte'
L.OPT_LUXTHOS_CLASS_DEMON_HUNTER = 'Cazador de demonios'
L.OPT_LUXTHOS_CLASS_DRUID = 'Druida'
L.OPT_LUXTHOS_CLASS_EVOKER = 'Evocador'
L.OPT_LUXTHOS_CLASS_HUNTER = 'Cazador'
L.OPT_LUXTHOS_CLASS_MAGE = 'Mago'
L.OPT_LUXTHOS_CLASS_MONK = 'Monje'
L.OPT_LUXTHOS_CLASS_PALADIN = 'Paladín'
L.OPT_LUXTHOS_CLASS_PRIEST = 'Sacerdote'
L.OPT_LUXTHOS_CLASS_ROGUE = 'Pícaro'
L.OPT_LUXTHOS_CLASS_SHAMAN = 'Chamán'
L.OPT_LUXTHOS_CLASS_WARLOCK = 'Brujo'
L.OPT_LUXTHOS_CLASS_WARRIOR = 'Guerrero'

-- Especializaciones
L.OPT_LUXTHOS_SPEC_AFFLICTION = 'Aflicción'
L.OPT_LUXTHOS_SPEC_ARCANE = 'Arcano'
L.OPT_LUXTHOS_SPEC_ARMS = 'Armas'
L.OPT_LUXTHOS_SPEC_ASSASSINATION = 'Asesinato'
L.OPT_LUXTHOS_SPEC_AUGMENTATION = 'Aumento'
L.OPT_LUXTHOS_SPEC_BALANCE = 'Equilibrio'
L.OPT_LUXTHOS_SPEC_BEAST_MASTERY = 'Dominio de bestias'
L.OPT_LUXTHOS_SPEC_BLOOD = 'Sangre'
L.OPT_LUXTHOS_SPEC_BREWMASTER = 'Maestro cervecero'
L.OPT_LUXTHOS_SPEC_DEMONOLOGY = 'Demonología'
L.OPT_LUXTHOS_SPEC_DESTRUCTION = 'Destrucción'
L.OPT_LUXTHOS_SPEC_DEVASTATION = 'Devastación'
L.OPT_LUXTHOS_SPEC_DEVOURER = 'Devourer'
L.OPT_LUXTHOS_SPEC_DISCIPLINE = 'Disciplina'
L.OPT_LUXTHOS_SPEC_ELEMENTAL = 'Elemental'
L.OPT_LUXTHOS_SPEC_ENHANCEMENT = 'Mejora'
L.OPT_LUXTHOS_SPEC_FERAL = 'Feral'
L.OPT_LUXTHOS_SPEC_FIRE = 'Fuego'
L.OPT_LUXTHOS_SPEC_FROST = 'Escarcha'
L.OPT_LUXTHOS_SPEC_FURY = 'Furia'
L.OPT_LUXTHOS_SPEC_GUARDIAN = 'Guardián'
L.OPT_LUXTHOS_SPEC_HAVOC = 'Devastación'
L.OPT_LUXTHOS_SPEC_HOLY = 'Sagrado'
L.OPT_LUXTHOS_SPEC_MARKSMANSHIP = 'Puntería'
L.OPT_LUXTHOS_SPEC_MISTWEAVER = 'Tejedor de niebla'
L.OPT_LUXTHOS_SPEC_OUTLAW = 'Forajido'
L.OPT_LUXTHOS_SPEC_PRESERVATION = 'Preservación'
L.OPT_LUXTHOS_SPEC_PROTECTION = 'Protección'
L.OPT_LUXTHOS_SPEC_RESTORATION = 'Restauración'
L.OPT_LUXTHOS_SPEC_RETRIBUTION = 'Reprensión'
L.OPT_LUXTHOS_SPEC_SHADOW = 'Sombras'
L.OPT_LUXTHOS_SPEC_SUBTLETY = 'Sutileza'
L.OPT_LUXTHOS_SPEC_SURVIVAL = 'Supervivencia'
L.OPT_LUXTHOS_SPEC_UNHOLY = 'Profano'
L.OPT_LUXTHOS_SPEC_VENGEANCE = 'Venganza'
L.OPT_LUXTHOS_SPEC_WINDWALKER = 'Viajero del viento'

L.OPT_LUXTHOS_WARLOCK_AFFLICTION_LABEL = 'WoW (Luxthos) - Brujo: Aflicción'
L.OPT_LUXTHOS_WARLOCK_AFFLICTION_BUTTON = 'Aflicción'
L.OPT_LUXTHOS_WARLOCK_AFFLICTION_CONFIRM = '¿Importar el string de Luxthos para Brujo (Aflicción)?'

L.OPT_LUXTHOS_WARLOCK_DEMONOLOGY_LABEL = 'WoW (Luxthos) - Brujo: Demonología'
L.OPT_LUXTHOS_WARLOCK_DEMONOLOGY_BUTTON = 'Demonología'
L.OPT_LUXTHOS_WARLOCK_DEMONOLOGY_CONFIRM = '¿Importar el string de Luxthos para Brujo (Demonología)?'

L.OPT_LUXTHOS_WARLOCK_DESTRUCTION_LABEL = 'WoW (Luxthos) - Brujo: Destrucción'
L.OPT_LUXTHOS_WARLOCK_DESTRUCTION_BUTTON = 'Destrucción'
L.OPT_LUXTHOS_WARLOCK_DESTRUCTION_CONFIRM = '¿Importar el string de Luxthos para Brujo (Destrucción)?'

L.OPT_OTHER_IMPORTS_HEADER = 'Información de otras importaciones'
L.OPT_OTHER_IMPORTS_DESC = 'LizeUI también integra recursos adicionales (texturas y fuentes) mediante SharedMedia. No se importan como “perfiles”, pero quedan disponibles para que otros addons los usen.'
L.OPT_TEXTURES = 'Texturas'
L.OPT_FONTS = 'Fuentes'

-- Installer / Welcome window
L.INSTALL_TITLE = 'Instalación LizeUI'
L.INSTALL_SUBTITLE = 'Bienvenido a LizeUI'
L.INSTALL_DESC1 = 'LizeUI es una interfaz para |cff00c0faElvUI|r pensada para que todo se vea claro, limpio y bien alineado desde el primer momento. Incluye varias configuraciones según tu resolución (|cff00ff002K/3K|r) para mantener el escalado, las proporciones y la colocación de cada elemento como está diseñada.\n\nAdemás, añade funcionalidades de mejora de vida (QoL) e incorpora un paquete amplio de texturas y fuentes para enriquecer el aspecto visual del juego. Para que la configuración quede completa, LizeUI incluye autoimportadores e integraciones para los addons necesarios, siempre que los tengas instalados y activados.\n\nPuedes volver a abrir este instalador cuando quieras con |cff00ff00/lizeui install|r.'

-- (Compat) estas líneas ya no se usan en la página 1 del instalador
L.INSTALL_DESC2 = ' '
L.INSTALL_DESC3 = ' '
L.INSTALL_DESC4 = ' '

L.INSTALL_DEPS_SUBTITLE = 'Dependencias (obligatorias e imprescindibles)'
L.INSTALL_DEPS_DESC1 = 'Lista de addons necesarios para que LizeUI se vea como está diseñada. Izquierda: estado. Derecha: importar (si aplica) y copiar el link.'
L.INSTALL_DEPS_IMPORT = 'Importar'
L.INSTALL_DEPS_DOWNLOAD = 'Descargar'
L.INSTALL_DEPS_TAG_MANDATORY = 'Obligatorio'
L.INSTALL_DEPS_TAG_IMPORTANT = 'Imprescindible'
L.INSTALL_DEPS_COPY_TEXT_FMT = 'Link de descarga: %s'

L.INSTALL_RECS_SUBTITLE = 'Addons recomendados'
L.INSTALL_RECS_DESC1 = 'Opcionales, pero recomendados para completar la experiencia de LizeUI. Izquierda: estado. Derecha: copiar el link.'
L.INSTALL_RECS_TAG = 'Recomendado'

L.INSTALL_BCDM_SUBTITLE = 'BetterCooldownManager'
L.INSTALL_BCDM_DESC1 = 'En esta página puedes importar BetterCooldownManager y elegir si quieres ver la barra de maná/furia/energía. En algunos personajes el gasto es tan bajo que se recomienda ocultarla (en LizeUI esa barra va en pequeño).'
L.INSTALL_BCDM_USE_BUTTON = 'Uso mana / furia / energia'
L.INSTALL_BCDM_NOUSE_BUTTON = 'NO uso mana / furia / energia'
L.INSTALL_BCDM_QUESTION = 'Que recursos usa tu PJ ??'
L.INSTALL_BCDM_ALL_BUTTON = 'Recursos / Barra de clase'
L.INSTALL_BCDM_MANA_BUTTON = 'Solo Recursos'
L.INSTALL_BCDM_NO_MANA_BUTTON = 'Solo barra de clase'
L.INSTALL_CLASS_SUBTITLE = 'Importaciones de clase'
L.INSTALL_CLASS_DESC1 = 'Aquí podrás importar configuraciones específicas de tu clase.'

L.INSTALL_CHAT_SUBTITLE = 'Chat'
L.INSTALL_CHAT_DESC1 = 'Este paso configura las ventanas de chat (nombres, posiciones y colores) para que todo quede alineado con LizeUI.'
L.INSTALL_CHAT_DESC2 = 'Después puedes mover/renombrar pestañas igual que el chat de Blizzard. Pulsa el botón para aplicarlo.'
L.INSTALL_CHAT_BUTTON = 'Configurar chat'
L.INSTALL_CHAT_DONE = 'Chat configurado'

L.INSTALL_SCALE_SUBTITLE = 'Escala de UI'
L.INSTALL_SCALE_DESC1 = 'LizeUI está diseñado para usarse con escala |cff00c0fa0.66|r. Si usas otra escala, algunos elementos pueden verse desplazados o desalineados. Ajusta la barra para cambiarlo manualmente.'
L.INSTALL_SCALE_BUTTON = 'Configuración LizeUI'

L.INSTALL_FINISH_SUBTITLE = 'Finalizar instalación'
L.INSTALL_FINISH_DESC1 = 'Ya está todo listo. Pulsa Finalizar para recargar la interfaz y aplicar los cambios correctamente.'
L.INSTALL_FINISH_BUTTON = 'Finalizar'

-- Config header / plugin line
L.CFG_LINE_FMT = '|cff00c0faLizeUI|r |cffaaaaaaby|r |cff00ff00%s|r - |cffaaaaaaVersión:|r |cff00ff00%s|r'

-- Import messages
L.MSG_MISSING_IMPORT_STRING_FMT = 'LizeUI: Falta el string de import de %s (%s) en LizeUI/imports/Imports.lua'
L.MSG_ELVUI_NOT_AVAILABLE = 'LizeUI: ElvUI no está disponible para importar.'
L.MSG_ELVUI_DISTRIBUTOR_MISSING = 'LizeUI: No se encontró el módulo Distributor de ElvUI.'
L.MSG_PROFILE_IMPORTED_FMT = 'LizeUI: Perfil importado en %s.'
L.MSG_IMPORT_ERROR_FMT = 'LizeUI: Error importando en %s: %s'

L.MSG_WEAKAURAS_NOT_LOADED = 'LizeUI: Editor de importación no disponible.'
L.MSG_WEAKAURAS_NO_IMPORT_API = 'LizeUI: No se detectó ninguna API de importación.'

L.MSG_WINDTOOLS_MISSING_STRING = 'LizeUI: Falta el string de import de WindTools en LizeUI/imports/Imports.lua'
L.MSG_WINDTOOLS_NOT_LOADED = 'LizeUI: WindTools no está cargado.'
L.MSG_WINDTOOLS_API_MISSING = 'LizeUI: No se encontró F.Profiles.ImportByString (WindTools).'
L.MSG_WINDTOOLS_IMPORTED_RELOADING = 'LizeUI: Perfil importado en WindTools. Recargando interfaz...'
L.MSG_WINDTOOLS_IMPORT_ERROR_FMT = 'LizeUI: Error importando en WindTools: %s'

L.MSG_PLATER_MISSING_STRING = 'LizeUI: Falta el string de import de Plater en LizeUI/imports/Imports.lua'
L.MSG_PLATER_API_MISSING = 'LizeUI: Plater no está cargado o no expone ImportAndSwitchProfile.'
L.MSG_PLATER_IMPORTED = 'LizeUI: Perfil importado en Plater.'
L.MSG_PLATER_IMPORT_ERROR_FMT = 'LizeUI: Error importando en Plater: %s'

-- Prompt de reinicio (Plater)
L.POPUP_RELOAD_UI_TEXT_PLATER = 'Perfil importado en Plater. Para que los cambios se apliquen correctamente, es recomendable reiniciar la interfaz ahora.'
L.POPUP_RELOAD_UI_TEXT_ELVUI = 'Perfil importado en ElvUI. Para que los cambios se apliquen correctamente, es recomendable reiniciar la interfaz ahora.'
L.POPUP_RELOAD_UI_TEXT_WINDTOOLS = 'Perfil importado en WindTools. Para que los cambios se apliquen correctamente, es recomendable reiniciar la interfaz ahora.'
L.POPUP_RELOAD_UI_TEXT_BCDM = 'Perfil importado en BetterCooldownManager. Para que los cambios se apliquen correctamente, es recomendable reiniciar la interfaz ahora.'
L.POPUP_RELOAD_UI_RELOAD = 'Reiniciar'
L.POPUP_RELOAD_UI_CANCEL = 'Cancelar'

-- Aviso de nombre duplicado (importaciones)
L.POPUP_DUPLICATE_NAME_TEXT_FMT = 'Ya existe un %s con el nombre |cff03fc9c%s|r. ¿Qué quieres hacer?'
L.POPUP_DUPLICATE_NAME_REPLACE = 'Sustituir'
L.POPUP_DUPLICATE_NAME_KEEP = 'Cargar existente'
L.POPUP_DUPLICATE_KIND_PROFILE = 'perfil'
L.POPUP_DUPLICATE_KIND_LAYOUT = 'layout'

L.MSG_DUPLICATE_KEEP_SELECTED_FMT = 'LizeUI: Se cargó el %s existente "%s" y se seleccionó.'

-- Aviso de addons importantes faltantes
L.POPUP_IMPORTANT_ADDONS_TEXT_FMT = 'Para que la interfaz se vea igual, estos addons deben estar instalados y activos:\n\n%s\n\nPuedes activarlos en la pantalla de selección de personaje → AddOns.\n\nPulsa Aceptar para no volver a mostrar este aviso.'
L.POPUP_IMPORTANT_ADDONS_OK = 'Aceptar'
L.POPUP_IMPORTANT_ADDONS_LATER = 'Más tarde'
L.POPUP_IMPORTANT_ADDONS_MISSING = 'falta'
L.POPUP_IMPORTANT_ADDONS_DISABLED = 'desactivado'


L.MSG_WOW_COPY_PASTE_HELP = 'LizeUI: Copia el string de la ventana y pégalo en Edit Mode → Layouts → Import.'
L.MSG_WOW_VISUAL_HINT = 'LizeUI: Si no se aplica visualmente, prueba /reload y selecciona el layout en Edit Mode.'

L.MSG_WOW_IMPORTING_FMT = 'LizeUI: Importando %s (len=%d)...'
L.MSG_WOW_AUTO_IMPORT_FAILED_FMT = 'LizeUI: Import automático falló para %s: %s'
L.MSG_DEBUG_C_EDITMODE_MISSING = 'LizeUI: Debug: C_EditMode no existe.'
L.MSG_DEBUG_C_EDITMODE_FUNCTIONS_FMT = 'LizeUI: Debug: Funciones en C_EditMode: %s'
L.MSG_WOW_LAYOUT_IMPORTED_API_FMT = 'LizeUI: Layout importado en %s (API=%s).'
L.MSG_WOW_LAYOUT_IMPORTED_API_ID_FMT = 'LizeUI: Layout importado en %s (API=%s, layoutID=%s).'
L.MSG_WOW_LAYOUT_SAVED_NAME_FMT = 'LizeUI: Nombre del layout guardado: %s'

L.REASON_EDITMODE_API_UNAVAILABLE = 'API de Edit Mode no disponible'
L.REASON_NO_NEW_LAYOUT_DETECTED = 'No se detectó un layout nuevo tras importar'
L.REASON_API_DID_NOT_ADD_LAYOUT = 'La API no añadió ningún layout (o no se pudo detectar)'

L.MSG_BCDM_MISSING_STRING = 'LizeUI: Falta el string de import de BetterCooldownManager en LizeUI/imports/Imports.lua'
L.MSG_BCDM_API_MISSING = 'LizeUI: No se encontró BCDMG:ImportBCDM (BetterCooldownManager).'
L.MSG_BCDM_IMPORTED = 'LizeUI: Perfil importado en BetterCooldownManager.'
L.MSG_BCDM_IMPORT_ERROR_FMT = 'LizeUI: Error importando en BetterCooldownManager: %s'

L.MSG_DETAILS_MISSING_STRING = 'LizeUI: Falta el string de import de Details en LizeUI/imports/Imports.lua'
L.MSG_DETAILS_NOT_LOADED = 'LizeUI: Details no está cargado.'
L.MSG_DETAILS_NO_IMPORT_API = 'LizeUI: No se encontró una función de importación conocida en Details (ImportProfile/ImportProfileFromString/ImportSettings).'
L.MSG_DETAILS_IMPORT_ERROR_FMT = 'LizeUI: Error importando en Details: %s'
L.MSG_DETAILS_IMPORT_OK_FMT = 'LizeUI: Import Details OK (%s).'
L.MSG_DETAILS_ACTIVE_PROFILE_FMT = 'LizeUI: Perfil activo en Details: %s'
L.MSG_DETAILS_IMPORT_DONE_NOT_APPLIED_FMT = 'LizeUI: Import hecho, pero no pude forzar el cambio de perfil en Details automáticamente. Si no ves cambios, selecciona el perfil "%s" dentro de Details.'

L.MSG_DETAILS_STRING_INFO_FMT = 'LizeUI: Details import string len=%d head=%s tail=%s'
L.MSG_DETAILS_RETURNED_INVALID_FMT = '%s devolvió %s (string inválida o no soportada)'

-- Copy window
L.COPYWIN_TITLE_FMT = 'LizeUI: %s'
L.COPYWIN_HELP = 'Copia este string y pégalo en: Modo Edición -> Diseño -> Importar.'
L.COPYWIN_HELP_WEAKAURAS = 'Copia este string y pégalo en: Editor nuevo de WoW -> Importar.'
L.COPYWIN_HELP_COOLDOWN_MANAGER = 'Copia este string y pégalo en: Ajustes -> Mejoras de juego -> Cooldown Manager -> Ajustes avanzados -> Importar.'
L.COPYWIN_SELECT_ALL = 'Seleccionar todo'
L.COPYWIN_CLOSE = 'Cerrar'

-- Slash commands
L.CMD_HELP_TITLE = 'Comandos de LizeUI:'
L.CMD_HELP_LINE1 = '/lizeui test_english  - Forzar inglés (test)'
L.CMD_HELP_LINE2 = '/lizeui test_spanish  - Forzar español (test)'
L.CMD_HELP_LINE3 = '/lizeui test_reset_language - Volver a autodetectar'
L.CMD_HELP_LINE4 = '/lizeui help - Mostrar esta ayuda'
L.CMD_HELP_LINE5 = '/lizeui install - Abrir el instalador'
L.CMD_HELP_LINE6 = '/lizeui install_reset - Resetear salida instalador (este personaje)'
L.CMD_HELP_LINE7 = '/lizeui install_reset_all - Resetear salida instalador (todos los personajes)'

L.CMD_LANG_FORCED_EN = 'LizeUI: Idioma forzado a inglés para testing.'
L.CMD_LANG_FORCED_ES = 'LizeUI: Idioma forzado a español para testing.'
L.CMD_LANG_RESET = 'LizeUI: Idioma reseteado a autodetectar.'
L.CMD_UNKNOWN = 'LizeUI: Comando desconocido. Usa /lizeui help'

L.CMD_INSTALL_RESET_CHAR = 'LizeUI: Instalador reseteado para este personaje.'
L.CMD_INSTALL_RESET_ALL = 'LizeUI: Instalador reseteado para todos los personajes.'

_G.LizeUI_Locales.esES = L
