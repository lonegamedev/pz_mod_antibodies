require("Antibodies")
require("ISAntibodiesWindow")

local UI_BORDER_SPACING = 10
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

function ISHealthPanel:showAntibodiesWindow()
	if ISAntibodiesWindow.instance and ISAntibodiesWindow.instance[self:getDoctor():getPlayerNum() + 1] then
		ISAntibodiesWindow.instance[self:getDoctor():getPlayerNum() + 1]:removeFromUIManager()
		ISAntibodiesWindow.instance[self:getDoctor():getPlayerNum() + 1] = nil
	end
	if
		ISAntibodiesWindow.instance
		and ISAntibodiesWindow.instance[self:getDoctor():getPlayerNum() + 1]
		and ISAntibodiesWindow.instance[self:getDoctor():getPlayerNum() + 1]:isVisible()
	then
		return
	end

	local width = ISAntibodiesWindow.WindowWidth
	local height = ISAntibodiesWindow.WindowHeight

	local y = getPlayerScreenTop(self:getDoctor():getPlayerNum())
		+ (getPlayerScreenHeight(self:getDoctor():getPlayerNum()) - height) / 2
	local x = getPlayerScreenLeft(self:getDoctor():getPlayerNum())
		+ (getPlayerScreenWidth(self:getDoctor():getPlayerNum()) - width) / 2
	local maxX = getCore():getScreenWidth()
	x = math.max(0, math.min(x, maxX - width))

	local modal = ISAntibodiesWindow:new(x, y, width, height, self:getDoctor(), self:getPatient())
	modal:initialise()
	modal:addToUIManager()

	if JoypadState.players[self:getDoctor():getPlayerNum() + 1] then
		setJoypadFocus(self:getDoctor():getPlayerNum(), modal)
	end
end

function ISHealthPanel:canDiagnose()
	return self.doctorLevel >= Antibodies.currentOptions.general.diagnoseSkillNeeded
		or Antibodies.currentOptions.general.debug
end

local ISHealthPanel_onJoypadDown = ISHealthPanel.onJoypadDown
function ISHealthPanel:onJoypadDown(button)
	ISHealthPanel_onJoypadDown(self, button)
	if button == Joypad.XButton and self:canDiagnose() then
		if self:getDoctor() == self:getPatient() then
			getPlayerInfoPanel(self:getDoctor():getPlayerNum()):toggleView(xpSystemText.health)
		else
			self.parent:removeFromUIManager()
		end
		setJoypadFocus(self:getDoctor():getPlayerNum(), nil)
		self:getDoctor():stopReceivingBodyDamageUpdates(self:getPatient())
		self:showAntibodiesWindow()
	end
end

function ISHealthPanel:onClick(button)
	if button.internal == "KNOX_INFECTION" then
		self:showAntibodiesWindow()
	end
end

ISHealthPanel_onGainJoypadFocus = ISHealthPanel.onGainJoypadFocus
function ISHealthPanel:onGainJoypadFocus(joypadData)
	ISHealthPanel_onGainJoypadFocus(self, joypadData)
	if self:canDiagnose() then
		self:setISButtonForX(self.knox_infection)
	end
end

local ISHealthPanel_createChildren = ISHealthPanel.createChildren
function ISHealthPanel:createChildren()
	ISHealthPanel_createChildren(self)
	self.knox_infection = ISButton:new(
		self.fitness:getX() + self.fitness:getWidth() + 5,
		self.fitness:getY(),
		100,
		FONT_HGT_SMALL + 6,
		getText("UI_Antibodies_KnoxInfection_Button"),
		self,
		ISHealthPanel.onClick
	)
	self.knox_infection.internal = "KNOX_INFECTION"
	self.knox_infection.anchorTop = true
	self.knox_infection.anchorBottom = false
	self.knox_infection.anchorLeft = true
	self.knox_infection.anchorRight = false
	self.knox_infection:initialise()
	self.knox_infection:instantiate()
	self.knox_infection:setVisible(false)
	self:addChild(self.knox_infection)

	self.healthPanel:setWidth(self.knox_infection:getRight() + UI_BORDER_SPACING)
end

------------------------------------------------------------------------
------------------------------------------------------------------------

function ISHealthPanel:render()
	if self.otherPlayer then
		self.fitness:setVisible(false)
	end
	--    self.healthPanel:render();

	local fontHgt = getTextManager():getFontHeight(UIFont.Small)
	local y = self.healthPanel.y

	self.fitness:setY(y)

	y = y + UI_BORDER_SPACING + FONT_HGT_SMALL + 6

	self:drawText(getText("IGUI_health_Overall_Body_Status"), self.fitness:getX(), y, 1.0, 1.0, 1.0, 1.0, UIFont.Small)
	y = y + fontHgt

	local InjuryRedTextTint = (100 - self:getPatient():getBodyDamage():getHealth()) / 100
	InjuryRedTextTint = math.max(InjuryRedTextTint, 0.2)
	local str = self.healthPanel.javaObject:getDamageStatusString()
	self:drawText(str, self.fitness:getX(), y, 1.0, 1.0 - InjuryRedTextTint, 1.0 - InjuryRedTextTint, 1.0, UIFont.Small)
	y = y + fontHgt

	local x = self.fitness:getX()
	local fgBar = { r = 0.5, g = 0.5, b = 0.5, a = 0.5 }

	local doctor = self.otherPlayer or self.character

	if doctor:getJoypadBind() ~= -1 then
		self:drawTextureScaled(
			self.abutton,
			UI_BORDER_SPACING,
			self.height - UI_BORDER_SPACING - fontHgt,
			fontHgt,
			fontHgt,
			1.0,
			1.0,
			1.0,
			1.0
		)
		self:drawText(
			getText("IGUI_health_JoypadTreatment"),
			UI_BORDER_SPACING + fontHgt + 2,
			self.height - UI_BORDER_SPACING - fontHgt,
			1,
			1,
			1,
			1,
			UIFont.Small
		)
	else
		self:drawText(
			getText("IGUI_health_RightClickTreatement"),
			UI_BORDER_SPACING,
			self.height - UI_BORDER_SPACING - fontHgt,
			1,
			1,
			1,
			1,
			UIFont.Small
		)
	end

	-- for each damaged body part, we gonna display the body part name + the damage type
	local painLevel = self:getPatient():getMoodles():getMoodleLevel(MoodleType.Pain)
	if isClient() and not self:getPatient():isLocalPlayer() then
		painLevel = self:getPatient():getBodyDamageRemote():getRemotePainLevel()
	end
	if (self.doctorLevel > 4 or self.character == getPlayer() or ISHealthPanel.cheat) and painLevel > 0 then
		self:drawText(getText("Moodles_pain_lvl" .. painLevel), x, y, 1, 1, 1, 1, UIFont.Small)
		y = y + fontHgt
	end
	if self.cheat and self.character:getBodyDamage():getFakeInfectionLevel() > 0 then
		self:drawText(
			"Fake infection level " .. self.character:getBodyDamage():getFakeInfectionLevel(),
			x,
			y,
			1,
			1,
			1,
			1,
			UIFont.Small
		)
		y = y + fontHgt
	end
	if self.cheat and self.character:getReduceInfectionPower() > 0 then
		self:drawText("Antibiotic level " .. self.character:getReduceInfectionPower(), x, y, 1, 1, 1, 1, UIFont.Small)
		y = y + fontHgt
	end

	local listItemsHeight = self.listbox:getScrollHeight()
	local myHeight = y + listItemsHeight + fontHgt + UI_BORDER_SPACING * 2
	local myY = self:getY()
	local parent = self.parent
	while parent and parent.parent do
		myY = myY + parent:getY()
		parent = parent.parent
	end
	if myY + myHeight > getCore():getScreenHeight() then
		myHeight = getCore():getScreenHeight() - myY
	end
	self.listbox:setY(y)
	self.listbox:setHeight(myHeight - (fontHgt + UI_BORDER_SPACING * 2) - y)
	self.listbox.vscroll:setHeight(self.listbox:getHeight())
	self.allTextHeight = myHeight - (fontHgt + UI_BORDER_SPACING * 2)

	if self.blockingMessage then
		self:drawRect(0, 0, self.width, self.height, 0.9 * self.blockingAlpha, 0, 0, 0)
		self:drawText(
			self.blockingMessage,
			self.width / 2 - (getTextManager():MeasureStringX(UIFont.Medium, self.blockingMessage) / 2),
			(self.height / 2) - 5,
			1,
			1,
			1,
			1,
			UIFont.Medium
		)
	end
end

------------------------------------------------------------------------
------------------------------------------------------------------------

local ISHealthPanel_update = ISHealthPanel.update
function ISHealthPanel:update()
	ISHealthPanel_update(self)
	if Antibodies then
		if Antibodies.currentOptions and self.knox_infection then
			if Antibodies.currentOptions.general.diagnoseEnabled then
				self.doctorLevel = AntibodiesUtils.getMedicalSkill(self:getDoctor())
				self.knox_infection:setVisible(self:canDiagnose())
			else
				self.knox_infection:setVisible(false)
			end
		end
	end
end
