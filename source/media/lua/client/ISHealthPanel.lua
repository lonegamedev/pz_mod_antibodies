require("Antibodies")
require("ISAntibodiesWindow")

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

local ISHealthPanel_onJoypadDown = ISHealthPanel.onJoypadDown
function ISHealthPanel:onJoypadDown(button)
	ISHealthPanel_onJoypadDown(self, button)
	if button == Joypad.XButton then
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
	self:setISButtonForX(self.knox_infection)
end

local ISHealthPanel_createChildren = ISHealthPanel.createChildren
function ISHealthPanel:createChildren()
	ISHealthPanel_createChildren(self)
	self.knox_infection = ISButton:new(
		self.fitness:getX() + 105,
		self.fitness:getY(),
		100,
		20,
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

	self.healthPanel:setWidth(self.healthPanel:getWidth() + 80)
end

local ISHealthPanel_update = ISHealthPanel.update
function ISHealthPanel:update()
	ISHealthPanel_update(self)
	if Antibodies then
		if Antibodies.currentOptions and self.knox_infection then
			if Antibodies.currentOptions.general.diagnoseEnabled then
				self.doctorLevel = AntibodiesUtils.getMedicalSkill(self.character)
				self.knox_infection:setVisible(
					self.doctorLevel >= Antibodies.currentOptions.general.diagnoseSkillNeeded
						or Antibodies.currentOptions.general.debug
				)
			else
				self.knox_infection:setVisible(false)
			end
		end
	end
end
