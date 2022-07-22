AntibodiesIcon = ISPanel:derive("AntibodiesIcon")

AntibodiesIcon.size = 36
AntibodiesIcon.offset = 5
AntibodiesIcon.TooltipWidth = 250

AntibodiesIcon.list = {
    "general",
    "wounds",
    "hygiene",
    "infections"
}

AntibodiesIcon.getIconIndex = function(str)
    for key_index, key_name in ipairs(AntibodiesIcon.list) do
        if key_name == str then
            return key_index
        end
    end
    return 0
end

AntibodiesIcon.getNextIcon = function(str)
    local count = #(AntibodiesIcon.list)
    local index = AntibodiesIcon.getIconIndex(str)
    local next_index = index + 1
    if next_index > count then
        next_index = 1
    end    
    return AntibodiesIcon.list[next_index]
end

AntibodiesIcon.getPrevIcon = function(str)
    local count = #(AntibodiesIcon.list)
    local index = AntibodiesIcon.getIconIndex(str)
    local prev_index = index - 1
    if prev_index < 1 then
        prev_index = count
    end    
    return AntibodiesIcon.list[prev_index]
end

function AntibodiesIcon:new(name)
 	local o = ISPanel.new(self, 0, 0, AntibodiesIcon.size, AntibodiesIcon.size)
    o.name = name
    o.isSelected = false
    o.side = 1
    return o
end

function AntibodiesIcon:initialise()
    ISPanel.initialise(self)
    self.borderColor = {r=0.0, g=0.0, b=0.0, a=0.0}
    self.backgroundColor = {r=0.0, g=0.0, b=0.0, a=0.0}
    self.bgOff = ISImage:new(
        0, 0,
        AntibodiesIcon.size, AntibodiesIcon.size,
        getTexture("media/ui/"..Antibodies.info.modId.."_bgOff.png")
    )
    self:addChild(self.bgOff)
    self.bgOn = ISImage:new(
        0, 0,
        AntibodiesIcon.size, AntibodiesIcon.size,
        getTexture("media/ui/"..Antibodies.info.modId.."_bgOn.png")
    )
    self.bgOn:setVisible(false)
    self:addChild(self.bgOn)
    self.icon = ISImage:new(
        0, 0,
        AntibodiesIcon.size, AntibodiesIcon.size,
        getTexture("media/ui/"..Antibodies.info.modId.."_"..self.name..".png")
    )
    self:addChild(self.icon)
end

function AntibodiesIcon:isMouseOverEx(x, y)
    if x < self:getAbsoluteX() then return false end
    if y < self:getAbsoluteY() then return false end
    if x > self:getAbsoluteX() + self:getWidth() then return false end
    if y > self:getAbsoluteY() + self:getHeight() then return false end
    return true
end

function AntibodiesIcon:setVisible(t)
    ISPanel.setVisible(self, t)
end 

function AntibodiesIcon:setSide(side)
    self.side = side
end

function AntibodiesIcon:setSelected(toggle, force)
    if toggle == self.isSelected and not force then
        return
    end
    self.isSelected = toggle
    self.bgOn:setVisible(toggle)
    self.bgOff:setVisible(not toggle)
    if toggle then
        if not self.tooltipUI then
            self.tooltipUI = ISToolTip:new()
            self.tooltipUI:setOwner(self)
            self.tooltipUI:setVisible(false)
            self.tooltipUI:setAlwaysOnTop(true)
        end
        self:setTooltip(self.toolTip)
        if not self.tooltipUI:getIsVisible() then
			self.tooltipUI:addToUIManager()
			self.tooltipUI:setVisible(true)
		end
        self:updateTooltipPlacement()
    else
		if self.tooltipUI and self.tooltipUI:getIsVisible() then
			self.tooltipUI:setVisible(false)
			self.tooltipUI:removeFromUIManager()
        end
    end
    
end

function AntibodiesIcon:updateTooltipPlacement()
    if self.tooltipUI and self.tooltipUI:isVisible() then
        if self.side < 0 then
            
            local width = self.tooltipUI:getWidth()
            if width == 0 then
		        local panelWidth = 220 + 20 + self.tooltipUI.descriptionPanel.marginLeft + self.tooltipUI.descriptionPanel.marginRight
                width = panelWidth
            end

            self.tooltipUI:setDesiredPosition(
                self:getAbsoluteX() - (8 + width),
                self:getAbsoluteY()
            )
        else
            self.tooltipUI:setDesiredPosition(
                self:getAbsoluteX() + AntibodiesIcon.size + 8,
                self:getAbsoluteY()
            )
        end
    end
end

function AntibodiesIcon:isSelected()
    return self.bgOn:isVisible()
end

function AntibodiesIcon:setTooltip(str)
    if str == nil then
        str = ""
    end
    self.toolTip = str
    if self.tooltipUI then
        self.tooltipUI.description = self.toolTip
        self.tooltipUI.maxLineWidth = AntibodiesIcon.TooltipWidth
    end
end
