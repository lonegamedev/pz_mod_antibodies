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

local pageElement = nil
local options = nil

local function canEditOptions()
    if not isClient() then
        return true
    end
    if isAdmin() then
        return true
    end
    return false
end

local function shouldSaveHostOptions()
    return isClient() and isAdmin()
end

local function Antibodies_addLabel(text)
    h = FONT_HGT_SMALL + 3 * 2
    local label = ISLabel:new(
        pageElement.addX, 
        pageElement.addY, 
        h, text, 1, 1, 1, 1, UIFont.Small);
    label:initialise();
    pageElement.mainPanel:addChild(label);
    pageElement.addY = pageElement.addY + h + Y_SPACING;
end  

local function Antibodies_addTextEntryBox(w, h, name, text, minValue, maxValue)
	h = FONT_HGT_SMALL + 3 * 2
	local label = ISLabel:new(
        pageElement.addX, pageElement.addY, 
        h, name, 1, 1, 1, 1, UIFont.Small);
	label:initialise();
	pageElement.mainPanel:addChild(label);
	local panel = UXTextEntryBox:new(
        text, 
        pageElement.addX + 20, pageElement.addY, 
        w, h, minValue, maxValue)
	panel:initialise();
    panel:instantiate()
    panel:setOnlyNumbers(true)
	pageElement.mainPanel:addChild(panel);
	pageElement.mainPanel:insertNewLineOfButtons(panel)
	pageElement.addY = pageElement.addY + h + Y_SPACING;
    pageElement.mainPanel:setScrollHeight(pageElement.addY + PANEL_MARGIN)
    return panel;
end

local function Antibodies_addTextField(w, h, options, group, name, tooltip, minValue, maxValue)
    local textEntry = Antibodies_addTextEntryBox(
        FIELD_WIDTH, 20, name, 
        tostring(options[group][name]), minValue, maxValue)
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
    pageElement.gameOptions:add(gameOption)
end

local function Antibodies_addGroup(txt)
    local label = ISLabel:new(
        pageElement.addX, pageElement.addY + Y_SPACING, 
        FONT_HGT_MEDIUM, txt, 1, 1, 1, 1, UIFont.Medium)
    label:initialise();
    label:setAnchorRight(true);
    pageElement.mainPanel:addChild(label);
    pageElement.addY = pageElement.addY + (FONT_HGT_MEDIUM * 2.0) + Y_SPACING
    pageElement.mainPanel:setScrollHeight(pageElement.addY + PANEL_MARGIN)
end

local function Antibodies_addGroupFields(options, group, tooltip)
    Antibodies_addGroup(group)
    for k,v in pairs(options[group]) do
        Antibodies_addTextField(
            FIELD_WIDTH, FIELD_HEIGHT, 
            options, group, k, tooltip, -1.0, 1.0)
    end  
end

local function applyOptions(options)
    if shouldSaveHostOptions() then
        AntibodiesShared.applyOptions(options)
        AntibodiesShared.saveHostOptions(options)
    else
        AntibodiesShared.applyOptions(options)
        AntibodiesShared.saveOptions(options)
    end
end

local function redrawUX()
    options = AntibodiesShared.getCurrentOptions()
    if not pageElement then
        return
    end
    pageElement.mainPanel:clearChildren()
    if canEditOptions() then
        Antibodies_addGroup("General")
        Antibodies_addTextField(FIELD_WIDTH, FIELD_HEIGHT, options, "General", "baseAntibodyGrowth", baseAntibodyGrowthTip, 1.0, 2.0)
        Antibodies_addGroupFields(options, "DamageEffects", damageEffectToolTip)
        Antibodies_addGroupFields(options, "MoodleEffects", moodleEffectToolTip)
        Antibodies_addGroupFields(options, "TraitsEffects", traitEffectToolTip)
    else
        Antibodies_addLabel("Server overrides all local options. Once disconneted, your settings will be restored.")
        Antibodies_addLabel("You can edit server options by assuming admin role.")
    end     
end


local oldMainOptionsCreateFunction = MainOptions.create
function MainOptions:create()
    oldMainOptionsCreateFunction(self)

    self:addPage(AntibodiesShared.modName)
    self.addX = self:getWidth() * 0.5
    self.addY = PANEL_MARGIN

    pageElement = self
    redrawUX()

    --OnApply
    do
	    local oldApply = self.apply
	    function self.apply(...)
            oldApply(...)
            applyOptions(options)
	    end
    end
    --
end

local wasCanEditOptions = canEditOptions()
local function onPlayerUpdate()
    if canEditOptions() ~= wasCanEditOptions then
        wasCanEditOptions = canEditOptions()
        redrawUX()
    end
end
Events.OnPlayerUpdate.Add(onPlayerUpdate)
