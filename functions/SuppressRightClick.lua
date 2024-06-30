DoubleClickDuration = 0.3;

-- Credit: this algorithm was suggested by Urzulan, see <http://www.curse.com/addons/wow/src?comment=3>

LastRightClick = 0;
WorldFrame:HookScript("OnMouseUp", function(self, button)
	if (UnitAffectingCombat("player") and
			button == "RightButton" and
			LastRightClick + DoubleClickDuration < GetTime()) then
		LastRightClick = GetTime();
		MouselookStop();
	end
end);
