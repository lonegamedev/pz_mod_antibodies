local FIELD_WIDTH = 100
local FIELD_HEIGHT = 20

local PANEL_MARGIN = 50
local SPACING_Y = 10

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

local function addNumberField(groupName, propName, label, tooltip, minValue, maxValue)
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
    addLabel(label, {
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

local function addNumberGroup(groupName, minValue, maxValue, labels, tooltips, blacklist, whitelist)
    if type(blacklist) ~= "table" then
        blacklist = {}
    end
    if type(whitelist) ~= "table" then
        whitelist = {}
    end
    if #whitelist > 0 then
        for index, key in pairs(whitelist) do
            local label = labels
            local tooltip = tooltips
            if label == nil then
                label = key
            end
            if tooltip == nil then
                tooltip = ""
            end
            if type(label) == "table" then
                label = labels[key]
            end
            if type(tooltips) == "table" then
                tooltip = tooltips[key]
            end
            addNumberField(
                groupName, 
                key,
                label,
                tooltip,
                minValue,
                maxValue
            )
            addOffsetY(SPACING_Y * 2)
        end
        return
    end
    for key, value in pairs(options[groupName]) do
        if not AntibodiesShared.has_value(blacklist, key) then
            local label = labels
            local tooltip = tooltips
            if label == nil then
                label = key
            end
            if tooltip == nil then
                tooltip = ""
            end
            if type(label) == "table" then
                label = labels[key]
            end
            if type(tooltips) == "table" then
                tooltip = tooltips[key]
            end
            addNumberField(
                groupName, 
                key,
                label,
                tooltip,
                minValue,
                maxValue
            )
            addOffsetY(SPACING_Y * 2)
        end
    end
end

local function addTickbox(groupName, propName, label, tooltip)
    if label == nil then
        label = propName
    end
    if tooltip == nil then
        tooltip = ""
    end
    addLabel(label, {
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

    if shouldSaveHostOptions() then
        options = AntibodiesShared.deepcopy(AntibodiesShared.currentOptions)
    else
        options = AntibodiesShared.getLocalOptions()
    end
    if options == nil then
        options = AntibodiesShared.getLocalOptions()
    end

    addLabel(getText("UI_Antibodies_General"), {
        ["font"] = UIFont.Large,
        ["offsetX"] = -16,
    })
    addOffsetY(SPACING_Y * 2)
    addNumberGroup("General", 0.0, 2.0, getText("UI_Antibodies_baseAntibodyGrowth"), getText("UI_Antibodies_baseAntibodyGrowthToolTip"))
    addOffsetY(SPACING_Y * 1)

    addLabel(getText("UI_Antibodies_HygineEffects"), {
        ["font"] = UIFont.Large, 
        ["offsetX"] = -16,
    })
    addOffsetY(SPACING_Y * 2)
    addNumberGroup("HygineEffects", -1.0, 0.0, 
        { 
            ["bloodEffect"] = getText("UI_Antibodies_HygineEffects_Blood"),
            ["dirtEffect"] = getText("UI_Antibodies_HygineEffects_Dirt")
        },
        getText("UI_Antibodies_HygineEffects_BloodDirtTooltip"), 
        {}, 
        {"bloodEffect", "dirtEffect"})
    addNumberGroup("HygineEffects", 0.0, 1.0, 
        {
            ["modDeepWounded"] = getText("UI_Antibodies_ModDeepWound"),
            ["modBleeding"] = getText("UI_Antibodies_ModBleeding"),
            ["modBitten"] = getText("UI_Antibodies_ModBitten"),
            ["modCut"] = getText("UI_Antibodies_ModCut"),
            ["modScratched"] = getText("UI_Antibodies_ModScratched"),
            ["modBurnt"] = getText("UI_Antibodies_ModBurnt"),
            ["modNeedBurnWash"] = getText("UI_Antibodies_ModBurnWash"),
            ["modStiched"] = getText("UI_Antibodies_ModStiched"),
            ["modHaveBullet"] = getText("UI_Antibodies_ModHaveBullet"),
            ["modHaveGlass"] = getText("UI_Antibodies_ModHaveGlass")
        }, getText("UI_Antibodies_HygineEffects_ModTooltip"), {"bloodEffect", "dirtEffect"})
    addOffsetY(SPACING_Y * 1)

    addLabel(getText("UI_Antibodies_MoodleEffects"), {
        ["font"] = UIFont.Large,
        ["offsetX"] = -16,
    })
    addOffsetY(SPACING_Y * 2)
    addNumberGroup("MoodleEffects", -1.0, 1.0, 
        {
            ["Bleeding"] = getText("UI_Antibodies_MoodleBleeding"),
            ["Hypothermia"] = getText("UI_Antibodies_MoodleHyperthermia"),
            ["Hyperthermia"] = getText("UI_Antibodies_MoodleHypothermia"),
            ["Thirst"] = getText("UI_Antibodies_MoodleThrist"),
            ["Hungry"] = getText("UI_Antibodies_MoodleHungry"),
            ["Sick"] = getText("UI_Antibodies_MoodleSick"),
            ["HasACold"] = getText("UI_Antibodies_MoodleHasACold"),
            ["Tired"] = getText("UI_Antibodies_MoodleTired"),
            ["Endurance"] = getText("UI_Antibodies_MoodleEndurance"),
            ["Pain"] = getText("UI_Antibodies_MoodlePain"),
            ["Wet"] = getText("UI_Antibodies_MoodleWet"),
            ["HeavyLoad"] = getText("UI_Antibodies_MoodleHeavyLoad"),
            ["Windchill"] = getText("UI_Antibodies_MoodleWindchill"),
            ["Panic"] = getText("UI_Antibodies_MoodlePanic"),
            ["Stress"] = getText("UI_Antibodies_MoodleStress"),
            ["Unhappy"] = getText("UI_Antibodies_MoodleUnhappy"),
            ["Bored"] = getText("UI_Antibodies_MoodleBored"),
            ["Drunk"] = getText("UI_Antibodies_MoodleDrunk"),
            ["FoodEaten"] = getText("UI_Antibodies_MoodleFoodEaten")
        }, getText("UI_Antibodies_MoodleEffectsToolTip"),
        AntibodiesShared.zeroMoodles
    )
    addOffsetY(SPACING_Y * 1)

    addLabel(getText("UI_Antibodies_TraitsEffects"), {
        ["font"] = UIFont.Large,
        ["offsetX"] = -16,
    })
    addOffsetY(SPACING_Y * 2)
    addNumberGroup("TraitsEffects", -1.0, 1.0, 
        {
            ["Asthmatic"] = getText("UI_trait_Asthmatic"),
            ["Smoker"] = getText("UI_trait_Smoker"),
            ["Unfit"] = getText("UI_trait_unfit"),
            ["Out of Shape"] = getText("UI_trait_outofshape"),
            ["Athletic"] = getText("UI_trait_athletic"),
            ["SlowHealer"] = getText("UI_trait_SlowHealer"),
            ["FastHealer"] = getText("UI_trait_FastHealer"),
            ["ProneToIllness"] = getText("UI_trait_pronetoillness"),
            ["Resilient"] = getText("UI_trait_resilient"),
            ["Weak"] = getText("UI_trait_weak"),
            ["Feeble"] = getText("UI_trait_feeble"),
            ["Strong"] = getText("UI_trait_strong"),
            ["Stout"] = getText("UI_trait_stout"),
            ["Emaciated"] = getText("UI_trait_emaciated"),
            ["Very Underweight"] = getText("UI_trait_veryunderweight"),
            ["Underweight"] = getText("UI_trait_underweight"),
            ["Overweight"] = getText("UI_trait_overweight"),
            ["Obese"] = getText("UI_trait_obese"),
            ["Lucky"] = getText("UI_trait_lucky"),
            ["Unlucky"] = getText("UI_trait_unlucky")
        }, getText("UI_TraitsEffectsToolTip"))
    addOffsetY(SPACING_Y * 1)

    addLabel(getText("UI_Antibodies_Debug"), {
        ["font"] = UIFont.Large,
        ["offsetX"] = -16,
    })
    addOffsetY(SPACING_Y * 2)
    addTickbox("Debug", "enabled", getText("UI_Antibodies_DebugEnabled"), getText("UI_Antibodies_DebugToolTip"))
    addOffsetY(SPACING_Y * 2)
    addTickbox("Debug", "infectionEffects", getText("UI_Antibodies_DebugInfection"), getText("UI_Antibodies_DebugInfectionToolTip"))
    addOffsetY(SPACING_Y * 2)
    addTickbox("Debug", "hygieneEffects", getText("UI_Antibodies_DebugHygiene"), getText("UI_Antibodies_DebugHygieneToolTip"))
    addOffsetY(SPACING_Y * 2)
    addTickbox("Debug", "moodleEffects", getText("UI_Antibodies_DebugMoodle"), getText("UI_Antibodies_DebugMoodleToolTip"))
    addOffsetY(SPACING_Y * 2)
    addTickbox("Debug", "traitsEffects", getText("UI_Antibodies_DebugTraits"), getText("UI_Antibodies_DebugTraitsToolTip"))
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
