local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local GFP = E:NewModule('ElvUI_GlobalFadePersist', 'AceHook-3.0', 'AceEvent-3.0'); --Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local EP = LibStub("LibElvUIPlugin-1.0") --We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local AB = E:GetModule("ActionBars");

function FadeParent_OnEvent(self, event)
	if UnitInVehicle("player") and (event == 'UNIT_ENTERED_VEHICLE' or 'UNIT_ENTERING_VEHICLE') then
		self.mouseLock = true;
		E:UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1);
	else
		self.mouseLock = false;
		E:UIFrameFadeOut(self, 0.2, self:GetAlpha(), 1 - AB.db.globalFadeAlpha);
	end
end

function GFP:Initialize()
	--Register plugin so options are properly inserted when config is loaded
	EP:RegisterPlugin(GFP:GetName());

	-- Register vehicle and player death events to fadeParent for easy checking
	AB.fadeParent:RegisterEvent("UNIT_ENTERING_VEHICLE");
	AB.fadeParent:RegisterEvent("UNIT_ENTERED_VEHICLE");
	AB.fadeParent:RegisterEvent("UNIT_EXITING_VEHICLE");
	AB.fadeParent:RegisterEvent("UNIT_EXITED_VEHICLE");
	AB.fadeParent:RegisterEvent("PLAYER_DEAD");

	-- Unregister events we no longer care about (more efficient)
	AB.fadeParent:UnregisterEvent("PLAYER_REGEN_DISABLED");
	AB.fadeParent:UnregisterEvent("PLAYER_REGEN_ENABLED"); 
	AB.fadeParent:UnregisterEvent("PLAYER_TARGET_CHANGED"); 
	AB.fadeParent:UnregisterEvent("UNIT_SPELLCAST_START", "player");
	AB.fadeParent:UnregisterEvent("UNIT_SPELLCAST_STOP", "player");
	AB.fadeParent:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START", "player");
	AB.fadeParent:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player");
	AB.fadeParent:UnregisterEvent("UNIT_HEALTH", "player");
	AB.fadeParent:UnregisterEvent("PLAYER_FOCUS_CHANGED");

	-- Finally, override the default script for this event in ElvUI
	AB.fadeParent:SetScript("OnEvent", FadeParent_OnEvent);
end

E:RegisterModule(GFP:GetName());
