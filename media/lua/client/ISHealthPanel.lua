-----------------------------------------------------
--STATIC---------------------------------------------
-----------------------------------------------------

local createBodyPartPanel = function(player, healthPanel, colorScheme)
    local minValue = 0
    local maxValue = 0
    for _,colorStep in ipairs(colorScheme) do
        if colorStep.val < minValue then
            minValue = colorStep.val
        end
        if colorStep.val > maxValue then
            maxValue = colorStep.val
        end
    end
    local bodyPartPanel = ISBodyPartPanel:new(
        player, 
        healthPanel:getX(), 
        healthPanel:getY() - 12, 
        self, 
        nil
    )
    bodyPartPanel.minValue = minValue
    bodyPartPanel.maxValue = maxValue
    bodyPartPanel.canSelect = false
    bodyPartPanel:initialise()
    bodyPartPanel:setColorScheme(colorScheme)
    bodyPartPanel:setVisible(false)
    healthPanel:addChild(bodyPartPanel)
    return bodyPartPanel
end

local createWoundsColorScheme = function()
    local minValue = 0
    local maxValue = 0
    local options = AntibodiesOptions.getOptions()
    for woundKey in pairs(options.wounds) do
        minValue = math.min(minValue, options.wounds[woundKey])
        maxValue = math.max(maxValue, options.wounds[woundKey])
    end
    return {
		{ val = minValue, color = Color.new(1,0,0,1)},
		{ val = maxValue, color = Color.new(0,0,1,1)},
    }
end

local createHygieneColorScheme = function()
    return {
		{ val = 0, color = Color.new(0,0,1,1)},
		{ val = 1, color = Color.new(1,0,0,1)},
    }
end

local createInfectionsColorScheme = function()
    local minValue = 0
    local maxValue = 0
    local options = AntibodiesOptions.getOptions()
    for infectionKey in pairs(options.infections) do
        minValue = math.min(minValue, options.infections[infectionKey])
        maxValue = math.max(maxValue, options.infections[infectionKey])
    end
    return {
		{ val = minValue, color = Color.new(1,0,0,1)},
		{ val = maxValue, color = Color.new(0,0,1,1)},
    }
end

local createColorScheme = function(layerKey)
    if layerKey == "wounds" then
        return createWoundsColorScheme()
    end
    if layerKey == "hygiene" then
        return createHygieneColorScheme()
    end
    if layerKey == "infections" then
        return createInfectionsColorScheme()
    end
end

-----------------------------------------------------
--METHODS--------------------------------------------
-----------------------------------------------------

local ISHealthPanel_createChildren = ISHealthPanel.createChildren
function ISHealthPanel:createChildren()
    ISHealthPanel_createChildren(self)
    local player = getSpecificPlayer(self.playerNum)
    self.antibodiesLayers = {}
    for _,key in ipairs(AntibodiesIcon.list) do
        local colorScheme = createColorScheme(key)
        if colorScheme then
            self.antibodiesLayers[key] = createBodyPartPanel(
                player,
                self,
                colorScheme
            )
        end
    end
end

function ISHealthPanel:showAntibodiesLayer(layerKey)
    for key in pairs(self.antibodiesLayers) do
        if key == layerKey then
            self.antibodiesLayers[key]:setVisible(true)
        else
            self.antibodiesLayers[key]:setVisible(false)
        end
    end
end

function ISHealthPanel:setAntibodiesLayersLevels(levels)
    for layerKey in pairs(levels) do
        if self.antibodiesLayers[layerKey] then
            local level = levels[layerKey]
            for bodyPartKey in pairs(level) do
                self.antibodiesLayers[layerKey]:setValue(
                    BodyPartType.FromString(bodyPartKey),
                    level[bodyPartKey]
                )
            end
        end
    end
end

--[[

local ISHealthPanel_onJoypadDirRight = ISHealthPanel.onJoypadDirRight
function ISHealthPanel:onJoypadDirRight(joypadData)
    ISHealthPanel_onJoypadDirRight(self, joypadData)
    local playerNum = (self.otherPlayer or self.character):getPlayerNum()
    local antibodiesPanel = AntibodiesPanel.list[playerNum+1]
    if not antibodiesPanel.isRTL then
        setJoypadFocus(playerNum, antibodiesPanel)
    end
end

local ISHealthPanel_onJoypadDirLeft = ISHealthPanel.onJoypadDirLeft
function ISHealthPanel:onJoypadDirLeft(joypadData)
    ISHealthPanel_onJoypadDirLeft(self, joypadData)
    local playerNum = (self.otherPlayer or self.character):getPlayerNum()
    local antibodiesPanel = AntibodiesPanel.list[playerNum+1]
    if antibodiesPanel.isRTL then
        setJoypadFocus(playerNum, antibodiesPanel)
    end
end
--]]