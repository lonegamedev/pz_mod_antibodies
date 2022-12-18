local ISCharacterInfoWindow_createChildren = ISCharacterInfoWindow.createChildren
function ISCharacterInfoWindow:createChildren()
	ISCharacterInfoWindow_createChildren(self)

	local enableHygiene = true
	local options = AntibodiesOptions.getOptions()
	if options then
		enableHygiene = options.general.enableHygienePanel
	end

	if enableHygiene then
		self.hygieneView = ISCharacterHygiene:new(0, 8, self.width, (self.height - 8) + 120, self.playerNum)
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
