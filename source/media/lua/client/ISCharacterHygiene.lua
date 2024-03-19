require("ISUI/ISPanelJoypad")

ISCharacterHygiene = ISPanelJoypad:derive("ISCharacterHygiene")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

function ISCharacterHygiene:initialise()
	ISPanelJoypad.initialise(self)
	self:create()
end

function ISCharacterHygiene:createChildren()
	ISPanelJoypad.createChildren(self)

	self.cacheColor = Color.new(1.0, 1.0, 1.0, 1.0)

	self.colorScheme = {
		{
			val = 0,
			color = Color.new(
				getCore():getBadHighlitedColor():getR(),
				getCore():getBadHighlitedColor():getG(),
				getCore():getBadHighlitedColor():getB(),
				1
			),
		},
		{
			val = 100,
			color = Color.new(
				getCore():getGoodHighlitedColor():getR(),
				getCore():getGoodHighlitedColor():getG(),
				getCore():getGoodHighlitedColor():getB(),
				1
			),
		},
	}

	local y = 8
	self.bpPanelX = 0
	self.bpPanelY = y
	self.bpAnchorX = 123
	self.bpAnchorY = 50
	self.bodyPartPanel = ISBodyPartPanel:new(self.char, self.bpPanelX, self.bpPanelY, self, nil)
	self.bodyPartPanel.maxValue = 100
	self.bodyPartPanel.canSelect = false
	self.bodyPartPanel:initialise()
	self.bodyPartPanel:setColorScheme(self.colorScheme)

	self:addChild(self.bodyPartPanel)
end

function ISCharacterHygiene:setVisible(visible)
	if visible then
		-- init?
	end
	self.javaObject:setVisible(visible)
end

function ISCharacterHygiene:prerender()
	ISPanelJoypad.prerender(self)
end

function ISCharacterHygiene:render()
	local labelPart = getText("IGUI_health_Part")
	local labelBody = getText("UI_characreation_body")
	local labelClothing = getText("UI_characreation_clothing")
	local bodyWidth = getTextManager():MeasureStringX(UIFont.Small, labelBody)
	local clothesWidth = getTextManager():MeasureStringX(UIFont.Small, labelClothing)

	local xOffset = 0
	local yOffset = 8
	local yText = yOffset
	local partX = 150
	local biteX = partX + self.maxLabelWidth + 20
	local scratchX = biteX + bodyWidth + 20
	--self:drawTexture(self.bodyOutline, xOffset, yOffset, 1, 1, 1, 1)

	self:drawText(labelPart, partX, yText, 1, 1, 1, 1, UIFont.Small)
	self:drawText(labelBody, biteX, yText, 1, 1, 1, 1, UIFont.Small)
	self:drawText(labelClothing, scratchX, yText, 1, 1, 1, 1, UIFont.Small)
	yText = yText + FONT_HGT_SMALL + 5

	local player = getSpecificPlayer(self.playerNum)
	local save = player:getModData()
	local medicalFile = save.medicalFile

	for i = 0, BodyPartType.ToIndex(BodyPartType.MAX) do
		local string = BodyPartType.ToString(BodyPartType.FromIndex(i))
		if self.bparts[string] then
			local part_hygiene = medicalFile.status.parts[string].hygiene
			local bodyHygiene = 100.0 - luautils.round(part_hygiene.body * 100.0)
			local clothingHygiene = 100.0 - luautils.round(part_hygiene.clothing * 100.0)

			bodyHygiene = math.floor(bodyHygiene)
			clothingHygiene = math.floor(clothingHygiene)
			local minHygiene = math.min(bodyHygiene, clothingHygiene)

			self.bodyPartPanel:setValue(BodyPartType.FromIndex(i), minHygiene)

			self:drawText(
				BodyPartType.getDisplayName(BodyPartType.FromIndex(i)),
				partX,
				yText,
				1,
				1,
				1,
				1,
				UIFont.Small
			)

			local r, g, b = self.bodyPartPanel:getRgbForValue(bodyHygiene)
			self:drawText(bodyHygiene .. "%", biteX, yText, r, g, b, 1, UIFont.Small)

			if part_hygiene.clothingPieces > 0 then
				r, g, b = self.bodyPartPanel:getRgbForValue(clothingHygiene)
				self:drawText(clothingHygiene .. "%", scratchX, yText, r, g, b, 1, UIFont.Small)
			else
				self:drawText("", scratchX, yText, r, g, b, 1, UIFont.Small)
			end

			yText = yText + FONT_HGT_SMALL
		end
	end

	local width = math.max(self.width, scratchX + clothesWidth + 20)
	self:setWidthAndParentWidth(width)

	local height = math.max(self.height, yText + 20)
	self:setHeightAndParentHeight(height)
end

function ISCharacterHygiene:create()
	self:initTextures()

	self.maxLabelWidth = 0
	for i = 1, BodyPartType.ToIndex(BodyPartType.MAX) do
		local string = BodyPartType.ToString(BodyPartType.FromIndex(i - 1))
		if self.bparts[string] then
			local label = BodyPartType.getDisplayName(BodyPartType.FromIndex(i - 1))
			local labelWidth = getTextManager():MeasureStringX(UIFont.Small, label)
			self.maxLabelWidth = math.max(self.maxLabelWidth, labelWidth)
		end
	end
end

function ISCharacterHygiene:initTextures()
	self.bparts = {}

	self.bparts["Hand_L"] = true
	self.bparts["Hand_R"] = true
	self.bparts["ForeArm_L"] = true
	self.bparts["ForeArm_R"] = true
	self.bparts["UpperArm_L"] = true
	self.bparts["UpperArm_R"] = true
	self.bparts["Torso_Upper"] = true
	self.bparts["Torso_Lower"] = true
	self.bparts["Head"] = true
	self.bparts["Neck"] = true
	self.bparts["Groin"] = true
	self.bparts["UpperLeg_L"] = true
	self.bparts["UpperLeg_R"] = true
	self.bparts["LowerLeg_L"] = true
	self.bparts["LowerLeg_R"] = true
	self.bparts["Foot_L"] = true
	self.bparts["Foot_R"] = true
end

function ISCharacterHygiene:onJoypadDown(button)
	if button == Joypad.BButton then
		getPlayerInfoPanel(self.playerNum):toggleView(xpSystemText.protection)
		setJoypadFocus(self.playerNum, nil)
	end
	if button == Joypad.LBumper then
		getPlayerInfoPanel(self.playerNum):onJoypadDown(button)
	end
	if button == Joypad.RBumper then
		getPlayerInfoPanel(self.playerNum):onJoypadDown(button)
	end
end

function ISCharacterHygiene:new(x, y, width, height, playerNum)
	local o = {}
	o = ISPanelJoypad:new(x, y, width, height)
	o:noBackground()
	setmetatable(o, self)
	self.__index = self
	o.playerNum = playerNum
	o.char = getSpecificPlayer(playerNum)
	o.bFemale = o.char:isFemale()
	o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
	o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.8 }
	o.sex = "female"
	if not o.char:isFemale() then
		o.sex = "male"
	end
	o.bodyOutline = getTexture("media/ui/defense/" .. o.sex .. "_base.png")
	return o
end
