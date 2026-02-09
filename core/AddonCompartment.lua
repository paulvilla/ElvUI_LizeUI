-- AddonCompartment.lua: handler global (Dragonflight+)

local addonName, ns = ...

local E = ns.E
local LizeUI = ns.LizeUI

-- Addon Compartment (Dragonflight+): handler global declarado en el .toc.
-- Nota: la firma del handler cambió en 11.0; aceptamos varargs para compatibilidad.
if type(_G.LizeUI_OnAddonCompartmentClick) ~= 'function' then
    _G.LizeUI_OnAddonCompartmentClick = function(_addonNameFromMetadata, _buttonName, ...)
        if LizeUI and type(LizeUI.EnsureElvUIToggleOptions) == 'function' then
            LizeUI:EnsureElvUIToggleOptions()
        end

        if E and type(E.ToggleOptions) == 'function' then
            E:ToggleOptions(addonName)
            return
        end

        -- Fallback extremo: intenta abrir via slash handler si existe.
        local slash = _G.SlashCmdList and _G.SlashCmdList.ELVUI
        if type(slash) == 'function' then
            slash(addonName)
        end
    end
end
