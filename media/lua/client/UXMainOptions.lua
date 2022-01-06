local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FIELD_WIDTH = 50
local FIELD_HEIGHT = 20
local Y_SPACING = 10
local PANEL_MARGIN = 20

local UXGameOption = require "UXGameOption"
local UXTextEntryBox = require "UXTextBoxEntry"

local baseAntibodyGrowthTip = "All effect values will be added to this base value\nand multiplied by the infection curve, which in turn \ncauses antibody growth to be maximized \nat the midpoint of infection."
local damageEffectToolTip = "Applied per affected body part."
local moodleEffectToolTip = "Will be multipled by moodle level (0-4)."
local traitEffectToolTip = "Constant trait bonus."

function MainOptions:Antibodies_addLabel(text)
    h = FONT_HGT_SMALL + 3 * 2
    local label = ISLabel:new(self.addX, self.addY, h, text, 1, 1, 1, 1, UIFont.Small);
    label:initialise();
    self.mainPanel:addChild(label);
end  

function MainOptions:Antibodies_addTextEntryBox(w, h, name, text, minValue, maxValue)
	h = FONT_HGT_SMALL + 3 * 2
	local label = ISLabel:new(self.addX, self.addY, h, name, 1, 1, 1, 1, UIFont.Small);
	label:initialise();
	self.mainPanel:addChild(label);
	local panel = UXTextEntryBox:new(text, self.addX + 20, self.addY, w, h, minValue, maxValue)
	panel:initialise();
    panel:instantiate()
    panel:setOnlyNumbers(true)
	self.mainPanel:addChild(panel);
	self.mainPanel:insertNewLineOfButtons(panel)
	self.addY = self.addY + h + Y_SPACING;
    self.mainPanel:setScrollHeight(self.addY + PANEL_MARGIN)
    return panel;
end

function MainOptions:Antibodies_addTextField(w, h, options, group, name, tooltip, minValue, maxValue)
    local textEntry = self:Antibodies_addTextEntryBox(FIELD_WIDTH, 20, name, tostring(options[group][name]), minValue, maxValue)
    textEntry:setTooltip(tooltip);
    local function parseTxt(txt)
        local val = tonumber(txt) or 0
        return math.min(math.max(val, minValue), maxValue)
    end
    local gameOption = UXGameOption:new(group.."."..name, textEntry)
    function gameOption.toUI(self)
        self.control:setText(tostring(options[group][name]))
    end
    function gameOption.apply(self)
        options[group][name] = parseTxt(self.control:getText())
    end
    self.gameOptions:add(gameOption)
end

function MainOptions:Antibodies_addGroup(txt)
    local label = ISLabel:new(self.addX, self.addY + Y_SPACING, FONT_HGT_MEDIUM, txt, 1, 1, 1, 1, UIFont.Medium)
    label:initialise();
    label:setAnchorRight(true);
    self.mainPanel:addChild(label);
    self.addY = self.addY + (FONT_HGT_MEDIUM * 2.0) + Y_SPACING
    self.mainPanel:setScrollHeight(self.addY + PANEL_MARGIN)
end

function MainOptions:Antibodies_addGroupFields(options, group, tooltip)
    self:Antibodies_addGroup(group)
    for k,v in pairs(options[group]) do
        self:Antibodies_addTextField(FIELD_WIDTH, FIELD_HEIGHT, options, group, k, tooltip, -1.0, 1.0)
    end  
end

function ApplyOptions(options)
    AntibodiesShared.applyOptions(options)
    AntibodiesShared.saveOptions(options)
end

local oldMainOptionsCreateFunction = MainOptions.create
function MainOptions:create()
    oldMainOptionsCreateFunction(self)

    --
    self:addPage(AntibodiesShared.modName)
    self.addX = self:getWidth() * 0.5
    self.addY = PANEL_MARGIN

    if isClient() then
        self:Antibodies_addLabel("Server overrides all local options. Once disconneted, your settings will be restored.")
        return
    end

    local options = AntibodiesShared.getCurrentOptions()

    self:Antibodies_addGroup("General")
    self:Antibodies_addTextField(FIELD_WIDTH, FIELD_HEIGHT, options, "General", "baseAntibodyGrowth", baseAntibodyGrowthTip, 1.0, 2.0)

    self:Antibodies_addGroupFields(options, "DamageEffects", damageEffectToolTip)
    self:Antibodies_addGroupFields(options, "MoodleEffects", moodleEffectToolTip)
    self:Antibodies_addGroupFields(options, "TraitsEffects", traitEffectToolTip)

    --OnApply
    do
	    local oldApply = self.apply
	    function self.apply(...)
            oldApply(...)
            ApplyOptions(options)
	    end
    end
    --
end