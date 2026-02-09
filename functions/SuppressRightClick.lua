local E = unpack(ElvUI)
local LizeUI = E:GetModule('LizeUI')

LizeUI.Features = LizeUI.Features or {}

local feature = LizeUI.Features.SuppressRightClick or {}
LizeUI.Features.SuppressRightClick = feature

local enabled = false
local hooked = false
local doubleClickDuration = 0.3
local lastRightClick = 0

-- Credit: this algorithm was suggested by Urzulan
local function OnMouseUp(_, button)
	if not enabled then return end

	if UnitAffectingCombat('player')
		and button == 'RightButton'
		and (lastRightClick + doubleClickDuration) < GetTime() then
		lastRightClick = GetTime()
		MouselookStop()
	end
end

local function EnsureHook()
	if hooked then return end
	hooked = true
	WorldFrame:HookScript('OnMouseUp', OnMouseUp)
end

function feature:SetEnabled(state)
	enabled = (state == true)
	if enabled then
		EnsureHook()
	end
end
