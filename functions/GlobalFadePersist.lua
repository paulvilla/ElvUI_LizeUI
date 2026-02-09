local E = unpack(ElvUI)
local LizeUI = E:GetModule('LizeUI')
local AB = E:GetModule('ActionBars')

LizeUI.Features = LizeUI.Features or {}

local feature = LizeUI.Features.GlobalFadePersist or {}
LizeUI.Features.GlobalFadePersist = feature

local enabled = false
local originalOnEvent
local installed = false
local addedEvents

local function ApplyFade(self, event)
	if not enabled then return end

	-- Forzar el estado deseado independientemente del evento.
	-- Motivo: algunos eventos (p.ej. montar/desmontar) pueden hacer que ElvUI reajuste el fade.
	if UnitInVehicle('player') then
		self.mouseLock = true
		E:UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	else
		self.mouseLock = false
		local alpha = 1 - ((AB and AB.db and AB.db.globalFadeAlpha) or 0)
		E:UIFrameFadeOut(self, 0.2, self:GetAlpha(), alpha)
	end
end

local function AddEvent(ev)
	if not (AB and AB.fadeParent) then return end

	-- Solo desregistraremos eventos que hayamos añadido nosotros.
	if AB.fadeParent.IsEventRegistered and AB.fadeParent:IsEventRegistered(ev) then return end
	AB.fadeParent:RegisterEvent(ev)
	addedEvents = addedEvents or {}
	addedEvents[ev] = true
end

local function RemoveAddedEvents()
	if not (addedEvents and AB and AB.fadeParent) then return end
	for ev in pairs(addedEvents) do
		AB.fadeParent:UnregisterEvent(ev)
	end
	addedEvents = nil
end

local function EnsureInstalled()
	if installed then return true end
	if not (AB and AB.fadeParent and AB.fadeParent.GetScript) then return false end

	-- Asegurar que recibimos eventos que afectan a vehículo/montura.
	AddEvent('UNIT_ENTERING_VEHICLE')
	AddEvent('UNIT_ENTERED_VEHICLE')
	AddEvent('UNIT_EXITING_VEHICLE')
	AddEvent('UNIT_EXITED_VEHICLE')
	AddEvent('PLAYER_DEAD')
	AddEvent('PLAYER_ENTERING_WORLD')
	AddEvent('PLAYER_MOUNT_DISPLAY_CHANGED')

	originalOnEvent = originalOnEvent or AB.fadeParent:GetScript('OnEvent')
	AB.fadeParent:SetScript('OnEvent', function(self, event, ...)
		if originalOnEvent then
			originalOnEvent(self, event, ...)
		end
		ApplyFade(self, event)
	end)

	installed = true
	return true
end

function feature:SetEnabled(state)
	enabled = (state == true)

	if enabled then
		if not EnsureInstalled() then
			if not feature._retryScheduled then
				feature._retryScheduled = true
				C_Timer.After(1, function()
					feature._retryScheduled = nil
					if enabled then
						EnsureInstalled()
					end
				end)
			end
		else
			-- aplicar estado actual una vez
			ApplyFade(AB.fadeParent, UnitInVehicle('player') and 'UNIT_ENTERED_VEHICLE' or 'UNIT_EXITED_VEHICLE')
		end
	else
		if installed and AB and AB.fadeParent and originalOnEvent then
			AB.fadeParent:SetScript('OnEvent', originalOnEvent)
		end
		RemoveAddedEvents()
		installed = false
	end
end
