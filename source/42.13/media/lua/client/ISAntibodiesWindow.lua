require("AntibodiesUI")

ISAntibodiesWindow = ISPanelJoypad:derive("ISAntibodiesWindow")
ISAntibodiesWindow.__index = ISAntibodiesWindow

local WINDOW_WIDTH = 600
local WINDOW_HEIGHT = 400
local WINDOW_PADDING = 10

local BORDER_COLOR = AntibodiesUI.GREY

local TOP_HEIGHT = 40
local BOTTOM_HEIGHT = 45

local TAB_BUTTONS_HEIGHT = 21
local TAB_PANEL_HEIGHT = WINDOW_HEIGHT - (TOP_HEIGHT + BOTTOM_HEIGHT)
local TAB_BOTTOM = TOP_HEIGHT + TAB_BUTTONS_HEIGHT

local LEFT_RIGHT_SEP = 10
local LEFT_PANEL_WIDTH = (WINDOW_WIDTH * 0.4) - LEFT_RIGHT_SEP
local RIGHT_PANEL_WIDTH = WINDOW_WIDTH - LEFT_PANEL_WIDTH - LEFT_RIGHT_SEP
local LEFT_RIGHT_HEIGHT = WINDOW_HEIGHT - (TOP_HEIGHT + BOTTOM_HEIGHT + TAB_BUTTONS_HEIGHT)

ISAntibodiesWindow.instance = {}
ISAntibodiesWindow.WindowWidth = WINDOW_WIDTH
ISAntibodiesWindow.WindowHeight = WINDOW_HEIGHT

ISAntibodiesWindow.conditionProgressBar = 10
ISAntibodiesWindow.woundsProgressBar = 10
ISAntibodiesWindow.infectionsProgressBar = 10
ISAntibodiesWindow.hygieneProgressBar = 10

local computeConditionBarWidth = function()
	local options = Antibodies.currentOptions
	local res = 0
	for key, value in pairs(options.condition) do
		local val = math.abs(value)
		if val > res then
			res = val
		end
	end
	if res > 0 then
		return res
	end
	return 1.0
end

local computeWoundsBarWidth = function()
	local options = Antibodies.currentOptions
	local val1 = 0
	for _, key in ipairs(Antibodies.WoundTreatmentBase) do
		val1 = val1 + options.wounds[key]
	end
	local val2 = 0
	for _, key in ipairs(Antibodies.WoundTreatmentMods) do
		val2 = val2 + (options.wounds[key] * options.general.doctorSkillTreatmentMod * 10)
	end
	val1 = math.abs(val1)
	val2 = math.abs(val2)
	local res = val1
	if res > val2 then
		res = val2
	end
	if res > 0 then
		return res
	end
	return 1.0
end

local computeInfectionsBarWidth = function()
	local options = Antibodies.currentOptions
	local res = 0
	for key, value in pairs(options.infections) do
		res = res + value
	end
	res = math.abs(res)
	if res > 0 then
		return res
	end
	return 1.0
end

local computeHygineBarWidth = function()
	local options = Antibodies.currentOptions
	local mod = 0
	for _, key in ipairs(Antibodies.HygieneMods) do
		mod = mod + options.hygiene[key]
	end
	local res = math.abs(mod * options.hygiene.bloodEffect) + math.abs(mod * options.hygiene.dirtEffect)
	if res > 0.0 then
		return res
	end
	return 1.0
end

function ISAntibodiesWindow:initialise()
	ISPanelJoypad.initialise(self)

	ISAntibodiesWindow.conditionProgressBar = computeConditionBarWidth()
	ISAntibodiesWindow.woundsProgressBar = computeWoundsBarWidth()
	ISAntibodiesWindow.infectionsProgressBar = computeInfectionsBarWidth()
	ISAntibodiesWindow.hygieneProgressBar = computeHygineBarWidth()

	local btnWid = 100
	local btnHgt = math.max(AntibodiesUI.FONT_HGT_SMALL + 3 * 2, 25)

	self.closeButton = ISButton:new(
		self:getWidth() - btnWid - 10,
		self:getHeight() - WINDOW_PADDING - btnHgt,
		btnWid,
		btnHgt,
		getText("UI_Close"),
		self,
		ISAntibodiesWindow.onClick
	)
	self.closeButton.internal = "CLOSE"
	self.closeButton.anchorLeft = false
	self.closeButton.anchorRight = true
	self.closeButton.anchorTop = false
	self.closeButton.anchorBottom = true
	self.closeButton:initialise()
	self.closeButton:instantiate()
	self.closeButton.borderColor = BORDER_COLOR
	self:addChild(self.closeButton)
end

function ISAntibodiesWindow:createChildren()
	ISPanelJoypad.createChildren(self)

	self.progressPanel = ISAntibodiesProgressPanel:new(0, TAB_BOTTOM, LEFT_PANEL_WIDTH, LEFT_RIGHT_HEIGHT)
	self:addChild(self.progressPanel)

	self.conditionPanel = ISAntibodiesConditionPanel:new(
		LEFT_RIGHT_SEP + LEFT_PANEL_WIDTH,
		TAB_BOTTOM,
		RIGHT_PANEL_WIDTH,
		LEFT_RIGHT_HEIGHT
	)
	self:addChild(self.conditionPanel)

	self.woundsPanel = ISAntibodiesBodyPanel:new(
		LEFT_RIGHT_SEP + LEFT_PANEL_WIDTH,
		TAB_BOTTOM,
		RIGHT_PANEL_WIDTH,
		LEFT_RIGHT_HEIGHT,
		ISAntibodiesBodyPanel.View.Wounds
	)
	self:addChild(self.woundsPanel)

	self.infectionsPanel = ISAntibodiesBodyPanel:new(
		LEFT_RIGHT_SEP + LEFT_PANEL_WIDTH,
		TAB_BOTTOM,
		RIGHT_PANEL_WIDTH,
		LEFT_RIGHT_HEIGHT,
		ISAntibodiesBodyPanel.View.Infections
	)
	self:addChild(self.infectionsPanel)

	self.hygienePanel = ISAntibodiesBodyPanel:new(
		LEFT_RIGHT_SEP + LEFT_PANEL_WIDTH,
		TAB_BOTTOM,
		RIGHT_PANEL_WIDTH,
		LEFT_RIGHT_HEIGHT,
		ISAntibodiesBodyPanel.View.Hygiene
	)
	self:addChild(self.hygienePanel)

	self.tabs = ISTabPanel:new(0, TOP_HEIGHT, WINDOW_WIDTH, TAB_PANEL_HEIGHT)
	self.tabs:initialise()
	self.tabs:setAnchorRight(true)
	self.tabs:setAnchorBottom(true)
	self.tabs.borderColor = BORDER_COLOR
	self.tabs.target = self
	self.tabs:setEqualTabWidth(true)
	self:addChild(self.tabs)

	self.tabs:addView(getText("UI_Antibodies_KnoxInfection_ConditionEffects"), self.conditionPanel)
	self.tabs:addView(getText("UI_Antibodies_KnoxInfection_WoundEffects"), self.woundsPanel)
	self.tabs:addView(getText("UI_Antibodies_KnoxInfection_InfectionEffects"), self.infectionsPanel)
	self.tabs:addView(getText("UI_Antibodies_KnoxInfection_HygieneEffects"), self.hygienePanel)
end

function ISAntibodiesWindow:drawTitle()
	local title = getText("UI_Antibodies_KnoxInfection_TitleSelf")
	if self.patient ~= self.doctor then
		title = getText(
			"UI_Antibodies_KnoxInfection_TitleOther",
			self.patient:getDescriptor():getForename() .. " " .. self.patient:getDescriptor():getSurname()
		)
	end
	local titleWidth = getTextManager():MeasureStringX(UIFont.Medium, title)
	self:drawText(title, (self:getWidth() / 2) - (titleWidth / 2), WINDOW_PADDING, 1, 1, 1, 1, UIFont.Medium)
end

function ISAntibodiesWindow:drawTabs()
	self:drawRectBorder(
		0,
		TOP_HEIGHT,
		WINDOW_WIDTH,
		TAB_BUTTONS_HEIGHT,
		BORDER_COLOR.a,
		BORDER_COLOR.r,
		BORDER_COLOR.g,
		BORDER_COLOR.b
	)
end

function ISAntibodiesWindow:render()
	ISPanelJoypad.render(self)

	local save = self.patient:getModData()
	local medicalFile = save.medicalFile

	self.progressPanel.medicalFile = medicalFile
	self.conditionPanel.medicalFile = medicalFile
	self.woundsPanel.medicalFile = medicalFile
	self.infectionsPanel.medicalFile = medicalFile
	self.hygienePanel.medicalFile = medicalFile

	self:drawTitle()
	self:drawTabs()
end

function ISAntibodiesWindow:onGainJoypadFocus(joypadData)
	ISPanelJoypad.onGainJoypadFocus(self, joypadData)
	self:setISButtonForB(self.closeButton)
end

function ISAntibodiesWindow:onJoypadDirUp(joypadData)
	ISPanelJoypad.onJoypadDirUp(self, joypadData)
	local viewIndex = self.tabs:getActiveViewIndex()
	if viewIndex == 1 then
		self.conditionPanel:scrollUp()
	elseif viewIndex == 2 then
		self.woundsPanel:scrollUp()
	elseif viewIndex == 3 then
		self.infectionsPanel:scrollUp()
	elseif viewIndex == 4 then
		self.hygienePanel:scrollUp()
	end
end

function ISAntibodiesWindow:onJoypadDirDown(joypadData)
	ISPanelJoypad.onJoypadDirDown(self, joypadData)
	local viewIndex = self.tabs:getActiveViewIndex()
	if viewIndex == 1 then
		self.conditionPanel:scrollDown()
	elseif viewIndex == 2 then
		self.woundsPanel:scrollDown()
	elseif viewIndex == 3 then
		self.infectionsPanel:scrollDown()
	elseif viewIndex == 4 then
		self.hygienePanel:scrollDown()
	end
end

function ISAntibodiesWindow:onJoypadDown(button)
	ISPanelJoypad.onJoypadDown(self, button)
	if button == Joypad.LBumper or button == Joypad.RBumper then
		local viewIndex = self.tabs:getActiveViewIndex()
		if button == Joypad.LBumper then
			if viewIndex == 1 then
				viewIndex = #self.tabs.viewList
			else
				viewIndex = viewIndex - 1
			end
		end
		if button == Joypad.RBumper then
			if viewIndex == #self.tabs.viewList then
				viewIndex = 1
			else
				viewIndex = viewIndex + 1
			end
		end
		self.tabs:activateView(self.tabs.viewList[viewIndex].name)
	end
end

function ISAntibodiesWindow:close()
	self:setVisible(false)
	self:removeFromUIManager()
	local playerNum = self.doctor:getPlayerNum()
	if JoypadState.players[playerNum + 1] then
		setJoypadFocus(playerNum, nil)
	end
end

function ISAntibodiesWindow:onClick(button)
	if button.internal == "CLOSE" then
		self:close()
	end
end

function ISAntibodiesWindow:update()
	ISPanelJoypad.update(self)
	if self.doctor ~= self.patient then
		if
			self.doctor:getAccessLevel() == "None"
			and math.abs(self.patient:getX() - self.doctor:getX()) > 0.5
			and math.abs(self.patient:getY() - self.doctor:getY()) > 0.5
		then
			self:close()
		end
	end
end

function ISAntibodiesWindow:new(x, y, width, height, doctor, patient)
	local o = ISPanelJoypad:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.backgroundColor.a = 0.9
	o.visibleOnStartup = false
	o.moveWithMouse = true
	o.doctor = doctor
	o.patient = patient
	ISAntibodiesWindow.instance[doctor:getPlayerNum() + 1] = o
	return o
end

local function onPlayerDeath(player)
	for key, window in ipairs(ISAntibodiesWindow.instance) do
		if window.doctor == player or window.patient == player then
			window:close()
		end
	end
end
Events.OnPlayerDeath.Add(onPlayerDeath)
