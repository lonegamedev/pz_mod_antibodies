local FIELD_WIDTH = 100
local FIELD_HEIGHT = 20

local PANEL_MARGIN = 50
local SPACING_Y = 10

local baseAntibodyGrowthTip = "All effect values will be added to this base value\nand multiplied by the infection curve, which in turn \ncauses antibody growth to be maximized \nat the midpoint of infection"
local damageEffectToolTip = "Applied per affected body part"
local moodleEffectToolTip = "Multipled by moodle level (0 - 4)"
local traitEffectToolTip = "Constant trait bonus"
local debugTooltip = "Enable console.txt messages. You can find log file in your ProjectZomboid home directory"
local debugTooltipDamage = "Breakdown damage effects in console.txt messages"
local debugTooltipTraits = "Breakdown traits effects in console.txt messages"
local debugTooltipMoodle = "Breakdown moodle effects in console.txt messages"
local serverOverrideMessage1 = "Server overrides all local options. Once disconnected, your settings will be restored."
local serverOverrideMessage2 = "You can edit server options by assuming admin role."

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

local function applyOptions(new_options)
    if shouldSaveHostOptions() then
        AntibodiesShared.applyOptions(new_options)
        AntibodiesShared.saveHostOptions(new_options)
    else
        AntibodiesShared.applyOptions(new_options)
        AntibodiesShared.saveOptions(new_options)
    end
end

local function addOffsetY(offset)
    pageElement.addY = pageElement.addY + offset
    pageElement.mainPanel:setScrollHeight(pageElement.addY + PANEL_MARGIN)
end

local function addLabel(text, options)
    if type(options) ~= "table" then
        options = {}
    end
    if options["font"] == nil then
        options["font"] = UIFont.Small
    end
    if options["useAddY"] == nil then
        options["useAddY"] = true
    end
    local offsetX = 0
    local offsetY = 0
    if options["centerX"] == true then
        offsetX = getTextManager():MeasureStringX(options["font"], text) * 0.5
    end
    if type(options["offsetX"]) == "number" then
        offsetX = offsetX + options["offsetX"]
    end 
    if type(options["offsetY"]) == "number" then
        offsetY = offsetY + options["offsetY"]
    end 
    local text_height = getTextManager():MeasureStringY(options["font"], text)    
    local label = ISLabel:new(
        pageElement.addX + offsetX, 
        pageElement.addY + offsetY, 
        text_height, 
        text, 
        1, 1, 1, 1, 
        options["font"],
        false
    )
    label:initialise()
    label:instantiate()
    pageElement.mainPanel:addChild(label)
    if options["useAddY"] == true then
        addOffsetY(text_height)
    end
    if options["color"] then
        label:setColor(
            options["color"]["r"],
            options["color"]["g"],
            options["color"]["b"]
        )
    end
end

local function addNumberField(groupName, propName, tooltip, minValue, maxValue)
    local function parseTxt(txt)
        local val = tonumber(txt) or 0
        return math.min(math.max(val, minValue), maxValue)
    end
    local function isValid(txt)
        local val = tonumber(txt) or 0
        if val > maxValue then
            return false
        end
        if val < minValue then
            return false
        end
        return true
    end
    addLabel(propName, {
        ["font"] = UIFont.Small,
        ["useAddY"] = false,
        ["offsetX"] = -16,
        ["offsetY"] = 2,
        ["color"] = {
            ["r"] = 0.9,
            ["g"] = 0.9,
            ["b"] = 0.9
        }
    })
    local input = ISTextEntryBox:new(
        tostring(options[groupName][propName]),
        pageElement.addX,
        pageElement.addY,
        FIELD_WIDTH,
        FIELD_HEIGHT
    )
    input.onTextChange = function()
        pageElement.gameOptions:onChange(input)
        input:setValid(isValid(input:getInternalText()))
    end
    input.toUI = function()
        input:setText(
            tostring(
                options[groupName][propName]
            )
        )
    end
    input.apply = function()
        options[groupName][propName] = parseTxt(
            input:getText()
        )
    end
    input:initialise()
    input:instantiate()
    input:setOnlyNumbers(true)
    input:setTooltip(tooltip)
    pageElement.mainPanel:addChild(input)
    pageElement.gameOptions:add(input)
    addOffsetY(FIELD_HEIGHT)
end

local function addNumberGroup(groupName, minValue, maxValue, tooltip, blacklist)
    if type(blacklist) ~= "table" then
        blacklist = {}
    end
    for key, value in pairs(options[groupName]) do
        if not AntibodiesShared.has_value(blacklist, key) then
            addNumberField(
                groupName, 
                key,
                tooltip,
                minValue,
                maxValue
            )
            addOffsetY(SPACING_Y * 2)
        end
    end
end

local function addTickbox(groupName, propName, tooltip)
    addLabel(propName, {
        ["font"] = UIFont.Small,
        ["useAddY"] = false,
        ["offsetX"] = -16,
        ["offsetY"] = 2,
        ["color"] = {
            ["r"] = 0.9,
            ["g"] = 0.9,
            ["b"] = 0.9
        }
    })
    local input = ISTickBox:new(
        pageElement.addX, 
        pageElement.addY, 
        FIELD_WIDTH, FIELD_WIDTH, 
        propName
    )
    input.tooltip = tooltip
    input.changeOptionMethod = function(target, index, selected)
        pageElement.gameOptions:onChange(input)
    end
    input.toUI = function()
        input:setSelected(1, options[groupName][propName])
    end
    input.apply = function()
        local val = false
        if input:isSelected(1) then
            val = true
        end
        options[groupName][propName] = val    
    end
    input:initialise()
    input:instantiate()
    pageElement.mainPanel:addChild(input)
    pageElement.gameOptions:add(input)
    addOffsetY(FIELD_HEIGHT)
    input:addOption("", true, nil)
end

local function showOptions()
    options = AntibodiesShared.getOptions()
    addLabel("General", {
        ["font"] = UIFont.Large,
        ["offsetX"] = -16,
    })
    addOffsetY(SPACING_Y * 2)
    addNumberGroup("General", 0.0, 2.0, baseAntibodyGrowthTip)
    addOffsetY(SPACING_Y * 1)

    addLabel("DamageEffects", {
        ["font"] = UIFont.Large, 
        ["offsetX"] = -16,
    })
    addOffsetY(SPACING_Y * 2)
    addNumberGroup("DamageEffects", -1.0, 1.0, damageEffectToolTip)
    addOffsetY(SPACING_Y * 1)

    addLabel("MoodleEffects", {
        ["font"] = UIFont.Large,
        ["offsetX"] = -16,
    })
    addOffsetY(SPACING_Y * 2)
    addNumberGroup("MoodleEffects", -1.0, 1.0, moodleEffectToolTip,
        AntibodiesShared.zeroMoodles
    )
    addOffsetY(SPACING_Y * 1)

    addLabel("TraitsEffects", {
        ["font"] = UIFont.Large,
        ["offsetX"] = -16,
    })
    addOffsetY(SPACING_Y * 2)
    addNumberGroup("TraitsEffects", -1.0, 1.0, traitEffectToolTip)
    addOffsetY(SPACING_Y * 1)

    addLabel("Debug", {
        ["font"] = UIFont.Large,
        ["offsetX"] = -16,
    })
    addOffsetY(SPACING_Y * 2)
    addTickbox("Debug", "enabled", debugTooltip)
    addOffsetY(SPACING_Y * 2)
    addTickbox("Debug", "damageEffects", debugTooltipDamage)
    addOffsetY(SPACING_Y * 2)
    addTickbox("Debug", "moodleEffects", debugTooltipMoodle)
    addOffsetY(SPACING_Y * 2)
    addTickbox("Debug", "traitsEffects", debugTooltipTraits)
end

local function showNoAdminMessage()
    addLabel(
        serverOverrideMessage1, 
        {
            ["font"] = UIFont.Medium, 
            ["useAddY"] = true,
            ["centerX"] = true
        }
    )
    addOffsetY(SPACING_Y)
    addLabel(
        serverOverrideMessage2,
        {
            ["font"] = UIFont.Small, 
            ["useAddY"] = true,
            ["centerX"] = true,
            ["color"] = {
                ["r"] = 0.9,
                ["g"] = 0.9,
                ["b"] = 0.9
            }
        }
    )
end

local function redrawUX()
    if not pageElement then
        return
    end
    pageElement.addX = pageElement:getWidth() * 0.5
    pageElement.addY = PANEL_MARGIN
    pageElement.mainPanel:clearChildren()
    pageElement.mainPanel:addScrollBars()
    if canEditOptions() then
        showOptions()
    else
        showNoAdminMessage()
    end     
end

local MainOptions_create = MainOptions.create
function MainOptions:create()
    MainOptions_create(self)

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
