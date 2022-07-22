AntibodiesPanel = ISPanelJoypad:derive("AntibodiesPanel")

-----------------------------------------------------
--STATIC---------------------------------------------
-----------------------------------------------------

AntibodiesPanel.createPanel = function(player)
    local count = #(AntibodiesIcon.list)
    local maxHeight = (count * (AntibodiesIcon.size + AntibodiesIcon.offset)) - AntibodiesIcon.offset
    local panel = AntibodiesPanel:new(0, 0, AntibodiesIcon.size, maxHeight)
    panel.borderColor = {r=0.0, g=0.0, b=0.0, a=0.0}
    panel.backgroundColor = {r=0.0, g=0.0, b=0.0, a=0.0}
    panel.player = player
    panel.selectedIcon = ""
    panel.side = 1
    panel:initialise()
    panel:addToUIManager()
    panel:setVisible(false)
    panel.cleanUp = function(deadPlayer)
        if player == deadPlayer then
            AntibodiesPanel.destroyPanel(panel)
        end
    end
    Events.OnPlayerDeath.Add(panel.cleanUp)
    return panel
end

AntibodiesPanel.destroyPanel = function(panel)
    if panel ~= nil then
        Events.OnPlayerDeath.Remove(panel.cleanUp)
        panel:setVisible(false)
        panel:removeFromUIManager()
    end
end

-----------------------------------------------------
--METHODS--------------------------------------------
-----------------------------------------------------

function AntibodiesPanel:createChildren()
    self.icons = {}
    self.diagnosis = {
        ["timestamp"] = 0
    }
    local walker_y = 0
    for i in pairs(AntibodiesIcon.list) do
        local key_name = AntibodiesIcon.list[i]
        local icon = AntibodiesIcon:new(key_name)
        icon:initialise()
        self.icons[key_name] = icon
        self:addChild(icon)
        icon:setY(walker_y)
        walker_y = walker_y + AntibodiesIcon.size + AntibodiesIcon.offset        
    end
end

function AntibodiesPanel:setSelected(name)
    local playerNum = self.player:getPlayerNum()
    local infoPanel = getPlayerInfoPanel(playerNum)
    self.selectedIcon = ""
    for key_index, key_name in ipairs(AntibodiesIcon.list) do
        if key_name == name then
            self.icons[key_name]:setSelected(true)
            self.selectedIcon = key_name
        else
            self.icons[key_name]:setSelected(false)
        end
    end
    if infoPanel then
        infoPanel.healthView:showAntibodiesLayer(self.selectedIcon)
    end
end

function AntibodiesPanel:getSelected()
    return self.selectedIcon
end

function AntibodiesPanel:updateDiagnosis(doctor, patient)
    local save = patient:getModData()
    if not save.medicalFile then
        return
    end
    if self.diagnosis then
        if self.diagnosis.timestamp == save.medicalFile.timestamp then
            return
        end
    end
    self.diagnosis = AntibodiesDiagnosis.create(save.medicalFile, doctor)
    for key_index, key_name in ipairs(AntibodiesIcon.list) do
        local icon = self.icons[key_name]
        icon:setTooltip(self.diagnosis[key_name])
    end
    local playerNum = self.player:getPlayerNum()
    local infoPanel = getPlayerInfoPanel(playerNum)
    infoPanel.healthView:setAntibodiesLayersLevels(
        self.diagnosis.levels
    )
end

function AntibodiesPanel:computeSide(healthPanel)
    local panelX = healthPanel:getAbsoluteX() + healthPanel:getRight() + AntibodiesIcon.offset
    local panelRight = panelX + AntibodiesIcon.size
    local screenRight = getPlayerScreenLeft(self.player:getPlayerNum()) + getPlayerScreenWidth(self.player:getPlayerNum())
    if panelRight > screenRight then
        return -1
    end
    return 1
end

function AntibodiesPanel:updatePlacement(healthPanel)
    self.side = self:computeSide(healthPanel)
    if self.side == -1 then
        self:setX(healthPanel:getAbsoluteX() - (AntibodiesIcon.offset + AntibodiesIcon.size))
        self:setY(healthPanel:getAbsoluteY() + AntibodiesIcon.size)
    else
        self:setX(healthPanel:getAbsoluteX() + healthPanel:getRight() + AntibodiesIcon.offset)
        self:setY(healthPanel:getAbsoluteY() + AntibodiesIcon.size)
    end
    for key_index, key_name in ipairs(AntibodiesIcon.list) do
        local icon = self.icons[key_name]
        if icon then
            icon:setSide(self.side)
            icon:updateTooltipPlacement()
        end
    end
end

function AntibodiesPanel:onMouseMove(dx, dy)
    if self.hasJoypadFocus then
        return
    end
    for key_index, key_name in ipairs(AntibodiesIcon.list) do
        local icon = self.icons[key_name]
        if icon:isMouseOver() then
            self:setSelected(key_name)
            break
        end
    end
end

function AntibodiesPanel:onMouseMoveOutside()
    if self.hasJoypadFocus then
        return
    end
    self:setSelected("")
end

-----------------------------------------------------
--CALLBACKS------------------------------------------
-----------------------------------------------------

--[[
function AntibodiesPanel:onJoypadDirLeft(joypadData)
    if not self.isRTL then
        local playerNum = self.player:getPlayerNum()
        local infoPanel = getPlayerInfoPanel(playerNum)
        if infoPanel ~= nil then
            local healthView = infoPanel.healthView
            setJoypadFocus(playerNum, healthView)
        end
    end
end

function AntibodiesPanel:onJoypadDirRight(joypadData)
    if self.isRTL then
        local playerNum = self.player:getPlayerNum()
        local infoPanel = getPlayerInfoPanel(playerNum)
        if infoPanel ~= nil then
            local healthView = infoPanel.healthView
            setJoypadFocus(playerNum, healthView)
        end
    end
end

function AntibodiesPanel:onJoypadDirDown(joypadData)
    self:setSelected(
        getNextIcon(self:getSelected())
    )    
end

function AntibodiesPanel:onJoypadDirUp(joypadData)
    self:setSelected(
        getPrevIcon(self:getSelected())
    )
end

function AntibodiesPanel:onJoypadDown(button)
    local playerNum = self.player:getPlayerNum()
    local infoPanel = getPlayerInfoPanel(playerNum)
    if infoPanel ~= nil then
        local healthView = infoPanel.healthView
        healthView:onJoypadDown(button)
    end
end

function AntibodiesPanel:onGainJoypadFocus(joypadData)
    self.hasJoypadFocus = true
    self:setSelected(
        getNextIcon(self:getSelected())
    )
end

function AntibodiesPanel:onLoseJoypadFocus(joypadData)
    self.hasJoypadFocus = false
    self:setSelected("")
end
--]]
