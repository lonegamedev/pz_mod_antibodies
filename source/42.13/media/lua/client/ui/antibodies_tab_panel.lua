require("ISUI/ISTabPanel")
local AntibodiesUI = require("ui/antibodies_ui")

local AntibodiesTabPanel = ISTabPanel:derive("AntibodiesTabPanel")

AntibodiesTabPanel.BORDER_COLOR = AntibodiesUI.GREY

function AntibodiesTabPanel:new(x, y, width, height, target)
	local instance = ISTabPanel:new(x, y, width, height)
	setmetatable(instance, self)
	self.__index = self
	instance.canFocus = true
	instance.target = target
	return instance
end

function AntibodiesTabPanel:initialise()
	ISTabPanel.createChildren(self)
	self.borderColor = AntibodiesTabPanel.BORDER_COLOR
	self:setAnchorRight(true)
	self:setAnchorBottom(true)
	self:setEqualTabWidth(true)
	self:noBackground()
end

return AntibodiesTabPanel
