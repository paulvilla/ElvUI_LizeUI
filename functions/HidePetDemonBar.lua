local E = unpack(ElvUI)
local LizeUI = E:GetModule('LizeUI')

LizeUI.Features = LizeUI.Features or {}

local feature = LizeUI.Features.HidePetDemonBar or {}
LizeUI.Features.HidePetDemonBar = feature

local enabled = false
local hooked = false

local function HidePetFrame()
    if not enabled then return end
    if PetFrame and PetFrame.IsShown and PetFrame:IsShown() then
        PetFrame:Hide()
    end
end

local function EnsureHook()
    if hooked then return end
    hooked = true

    local f = CreateFrame('Frame')
    f:RegisterEvent('PLAYER_ENTERING_WORLD')
    f:RegisterEvent('UNIT_PET')
    f:RegisterEvent('PLAYER_REGEN_DISABLED')
    f:SetScript('OnEvent', function()
        HidePetFrame()

        if PetFrame and PetFrame.Show and not feature._petFrameHooked then
            feature._petFrameHooked = true
            hooksecurefunc(PetFrame, 'Show', function(self)
                if enabled then
                    self:Hide()
                end
            end)
        end
    end)
end

function feature:SetEnabled(state)
    enabled = (state == true)
    EnsureHook()
    HidePetFrame()
end