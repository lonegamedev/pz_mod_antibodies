require("ISCharacterInfoWindow")
local AntibodiesHygieneBodyPanel = require("ui/antibodies_hygiene_body_panel")
local AntibodiesConfig = require("antibodies_config")

local ISCharacterInfoWindow_createChildren = ISCharacterInfoWindow.createChildren
---@diagnostic disable-next-line: duplicate-set-field
function ISCharacterInfoWindow:createChildren()
	ISCharacterInfoWindow_createChildren(self)

	local config = AntibodiesConfig.getCurrent()
	local enableHygiene = config and config:isHygienePanelEnabled() or false

	if enableHygiene then
		self.hygieneView = AntibodiesHygieneBodyPanel:new(0, 8, self.width, (self.height - 8) + 120, self.playerNum)
		self.hygieneView:initialise()
		self.hygieneView.infoText = getTextOrNull("UI_Antibodies_Hygiene_Info")
		self.panel:addView(getText("UI_Antibodies_Hygiene"), self.hygieneView)

		local th = self:titleBarHeight()
		self.pinButton:setX(self.width - th - 3)
		self.collapseButton:setX(self.width - th - 3)

		self:setWidth(self.charScreen.width)
		self:setHeight(self.charScreen.height)
	end
end
