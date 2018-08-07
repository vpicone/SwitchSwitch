--############################################
-- Namespace
--############################################
local _, addon = ...

--Set up frame helper gobal tables
addon.FrameHelper = {}
local FrameHelper = addon.FrameHelper

--##########################################################################################################################
--                                  Frames Init
--##########################################################################################################################
--Creates the Frame inside the talent frame
function FrameHelper:CreateTalentFrameUI()
    --Check if we already created the frame, as WOW does not delete frames unless you reload, so we dont need to recreate it
    if(FrameHelper.UpperTalentsUI ~= nil) then
        --Update the frame and add/remove porfiles as needed (using garbage collection for memory otimisation)
        --FrameHelper:UpdateTalentFrameUIComponents()
        return
    end
    --Create frame and hide it by default
    FrameHelper.UpperTalentsUI = CreateFrame("Frame", "SwitchSwitch_UpperTalentsUI", PlayerTalentFrameTalents)
    local UpperTalentsUI = FrameHelper.UpperTalentsUI
    UpperTalentsUI:SetPoint("TOPLEFT", PlayerTalentFrameTalents, "TOPLEFT", 60, 30)
    UpperTalentsUI:SetPoint("BOTTOMRIGHT", PlayerTalentFrameTalents, "TOPRIGHT", -110, 2)

    --Create the new and save buttons
    UpperTalentsUI.SaveButton = FrameHelper:CreateButton("TOPRIGHT", UpperTalentsUI, UpperTalentsUI, "TOPRIGHT", addon.L["Save"], 80, nil, -10, -2)
    UpperTalentsUI.NewButton = FrameHelper:CreateButton("TOPRIGHT", UpperTalentsUI.SaveButton, UpperTalentsUI.SaveButton, "TOPLEFT", addon.L["New"], 80, nil, -5, 0) 
    UpperTalentsUI.NewButton:SetScript("OnClick", function() StaticPopup_Show("SwitchSwitch_NewTalentProfilePopUp", "")end)
    --Create Talent string
    UpperTalentsUI.CurrentPorfie = UpperTalentsUI:CreateFontString(nil, "ARTWORK", "GameFontNormalLeft")
    UpperTalentsUI.CurrentPorfie:SetText(addon.L["Talents"] .. ":")
    UpperTalentsUI.CurrentPorfie:SetPoint("LEFT")

    --Create Dropdown menu for talent groups
    UpperTalentsUI.DropDownTalents = CreateFrame("FRAME", "SwitchSwitch_UpperTalentsUI_Dropdown", UpperTalentsUI, "UIDropDownMenuTemplate")
    UpperTalentsUI.DropDownTalents:SetPoint("LEFT", UpperTalentsUI.CurrentPorfie, "RIGHT", 0, -3)
    UIDropDownMenu_SetWidth(UpperTalentsUI.DropDownTalents, 200)
    UIDropDownMenu_Initialize(UpperTalentsUI.DropDownTalents, FrameHelper.Initialize_Talents_List)
    UIDropDownMenu_SetSelectedID(UpperTalentsUI.DropDownTalents, 1)

    --Create new Static popup dialog
    StaticPopupDialogs["SwitchSwitch_NewTalentProfilePopUp"] =
    {
        text = addon.L["Create a new profile:"] .. "%s",
        button1 = addon.L["Ok"],
        button2 = addon.L["Cancel"],
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        hasEditBox = true,
        exclusive = true,
        OnAccept = function(self)
            FrameHelper:OnAceptNewPorfile(self)
        end,
        EditBoxOnTextChanged = function (self) 
            local data = self:GetParent().editBox:GetText()
            if(data ~= nil and data ~= '') then
                self:GetParent().button1:Enable()
            else
                self:GetParent().button1:Disable()
            end
        end,
        OnShow = function(self)
            self.button1:Disable()
        end,
        OnCancel = function()
            StaticPopupDialogs["SwitchSwitch_NewTalentProfilePopUp"].text = addon.L["Create a new profile:"]
        end
    }
end

--Creates the Configuration frame UI
function FrameHelper:CreateConfigFrame()

end

--##########################################################################################################################
--                                  Frames Component handler
--##########################################################################################################################
function FrameHelper.Initialize_Talents_List(self, level, menuList)
    menuList = 
    {
        { 
            text = "test555",
        },
        { 
            text = "test4",
        },
        { 
            text = "test5",
        }
    }
    if(not level) then
        level = 1
    end
	for index = 1, #menuList do
        local info = menuList[index]
		if (info.text) then
            info.index = index
            info.value = info.text
            info.arg1 = self
            info.func = FrameHelper.SetDropDownValue
			UIDropDownMenu_AddButton( info, level )
		end
	end
end

function FrameHelper.SetDropDownValue(self, arg1, arg2, checked)
    if (not checked) then
		-- set selected value as selected
        UIDropDownMenu_SetSelectedValue(arg1, self.value)
    end
end

function FrameHelper:OnAceptNewPorfile(frame)
    local profileName = frame.editBox:GetText()
    --Check if the porfile exits if so, change the text
    if(addon:DoesTalentPorfileExist(profileName)) then
        frame.button1:Disable()
        C_Timer.After(0.01,function() StaticPopup_Show("SwitchSwitch_NewTalentProfilePopUp", "\n\n |cFFFF0000" .. addon.L["Talent Group name is already in use"]) end)
        return
    end

    --Porfile name does not exist so create it
    addon.sv.Talents[profileName] =
    {
        options = {},
        talents = addon:GetCurrentTalents()
    }
    addon:Print(addon.L["Talent Porfile %s created!"]:format(profileName))
end

--##########################################################################################################################
--                                  Helper Functions
--##########################################################################################################################
function FrameHelper:CreateButton(point, parentFrame, relativeFrame, relativePoint, text, width, height, xOffSet, yOffSet, TextHeight)
    --Set defalt values in case not specified
    width = width or 100
    height = height or 20
    xOffSet = xOffSet or 0
    yOffSet = yOffSet or 0
    TextHeight = TextHeight or ""
    text = text or "Not specified"
    --Create the button and set their value
    local button = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
    button:SetPoint(point, relativeFrame, relativePoint, xOffSet, yOffSet)
    button:SetSize(width,height)
    button:SetText(text)
    button:SetNormalFontObject("GameFontNormal"..TextHeight)
    button:SetHighlightFontObject("GameFontHighlight"..TextHeight)
    --Return the button
    return button
end