require("ISUI/ISPanelJoypad")
require("ISUI/ISButton")

local AntibodiesMedicalFile = require("antibodies_medical_file")

local AntibodiesUI = require("ui/antibodies_ui")
local AntibodiesTabPanel = require("ui/antibodies_tab_panel")
local AntibodiesProgressPanel = require("ui/antibodies_progress_panel")
local AntibodiesConditionPanel = require("ui/antibodies_condition_panel")
local AntibodiesWoundsPanel = require("ui/antibodies_wounds_panel")

local AntibodiesWindow = ISPanelJoypad:derive("AntibodiesWindow")

AntibodiesWindow.WINDOW_WIDTH = 600
AntibodiesWindow.WINDOW_HEIGHT = 400
AntibodiesWindow.WINDOW_PADDING = 10
AntibodiesWindow.BORDER_COLOR = AntibodiesUI.GREY

AntibodiesWindow.TOP_HEIGHT = 40
AntibodiesWindow.BOTTOM_HEIGHT = 45

AntibodiesWindow.TAB_BUTTONS_HEIGHT = 21
AntibodiesWindow.TAB_PANEL_HEIGHT = AntibodiesWindow.WINDOW_HEIGHT
	- (AntibodiesWindow.TOP_HEIGHT + AntibodiesWindow.BOTTOM_HEIGHT)
AntibodiesWindow.TAB_BOTTOM = AntibodiesWindow.TOP_HEIGHT + AntibodiesWindow.TAB_BUTTONS_HEIGHT

AntibodiesWindow.LEFT_RIGHT_SEP = 10
AntibodiesWindow.LEFT_PANEL_WIDTH = (AntibodiesWindow.WINDOW_WIDTH * 0.4) - AntibodiesWindow.LEFT_RIGHT_SEP
AntibodiesWindow.RIGHT_PANEL_WIDTH = AntibodiesWindow.WINDOW_WIDTH
	- AntibodiesWindow.LEFT_PANEL_WIDTH
	- AntibodiesWindow.LEFT_RIGHT_SEP
AntibodiesWindow.LEFT_RIGHT_HEIGHT = AntibodiesWindow.WINDOW_HEIGHT
	- (AntibodiesWindow.TOP_HEIGHT + AntibodiesWindow.BOTTOM_HEIGHT + AntibodiesWindow.TAB_BUTTONS_HEIGHT)

AntibodiesWindow.instance = {}

function AntibodiesWindow.show(doctor, patient)
	local doctorNum = doctor:getPlayerNum()
	if JoypadState.players[doctorNum + 1] then
		getPlayerInfoPanel(doctorNum):toggleView(xpSystemText.health)
	end

	if AntibodiesWindow.instance[doctorNum + 1] then
		AntibodiesWindow.instance[doctorNum + 1]:removeFromUIManager()
		AntibodiesWindow.instance[doctorNum + 1] = nil
	end

	local rect = AntibodiesWindow.getWindowRect(doctor)
	local window = AntibodiesWindow:new(rect.x, rect.y, rect.width, rect.height, doctor, patient)
	window:initialise()
	window:addToUIManager()
	AntibodiesWindow.instance[doctorNum + 1] = window

	setJoypadFocus(doctorNum, window)
end

function AntibodiesWindow.getWindowRect(doctor)
	local playerNum = doctor:getPlayerNum()
	local width = AntibodiesWindow.WINDOW_WIDTH
	local height = AntibodiesWindow.WINDOW_HEIGHT
	local y = getPlayerScreenTop(playerNum) + (getPlayerScreenHeight(playerNum) - height) / 2
	local x = getPlayerScreenLeft(playerNum) + (getPlayerScreenWidth(playerNum) - width) / 2
	local maxX = getCore():getScreenWidth()
	x = math.max(0, math.min(x, maxX - width))
	return {
		x = x,
		y = y,
		width = width,
		height = height,
	}
end

function AntibodiesWindow:new(x, y, width, height, doctor, patient)
	local instance = ISPanelJoypad:new(x, y, width, height)
	setmetatable(instance, self)
	self.__index = self

	instance.joypadFocus = true
	instance.backgroundColor.a = 0.9
	instance.visibleOnStartup = false
	instance.moveWithMouse = true

	instance.doctor = doctor
	instance.patient = patient

	instance.progressPanel = nil
	instance.conditionPanel = nil
	instance.woundsPanel = nil

	return instance
end

function AntibodiesWindow:initialise()
	ISPanelJoypad.initialise(self)
end

function AntibodiesWindow:onClick(button)
	if button.internal == "CLOSE" then
		self:close()
	end
end

function AntibodiesWindow:close()
	ISPanelJoypad.close(self)
	local doctorNum = self.doctor:getPlayerNum()

	if AntibodiesWindow.instance[doctorNum + 1] then
		AntibodiesWindow.instance[doctorNum + 1]:removeFromUIManager()
		AntibodiesWindow.instance[doctorNum + 1] = nil
	end

	if JoypadState.players[doctorNum] then
		setJoypadFocus(doctorNum, nil)
	end
end

function AntibodiesWindow:createCloseBtn()
	local btnWid = 100
	local btnHgt = math.max(AntibodiesUI.FONT_HGT_SMALL + 3 * 2, 25)
	self.closeButton = ISButton:new(
		self:getWidth() - AntibodiesWindow.WINDOW_PADDING - btnWid,
		self:getHeight() - AntibodiesWindow.WINDOW_PADDING - btnHgt,
		btnWid,
		btnHgt,
		getText("UI_Close"),
		self,
		AntibodiesWindow.onClick
	)
	self.closeButton.internal = "CLOSE"
	self.closeButton.anchorLeft = false
	self.closeButton.anchorRight = true
	self.closeButton.anchorTop = false
	self.closeButton.anchorBottom = true
	self.closeButton:initialise()
	self.closeButton:instantiate()
	self.closeButton.borderColor = AntibodiesWindow.BORDER_COLOR
	self:addChild(self.closeButton)
end

function AntibodiesWindow:createChildren()
	ISPanelJoypad.createChildren(self)

	self.tabs = AntibodiesTabPanel:new(
		0,
		AntibodiesWindow.TOP_HEIGHT,
		AntibodiesWindow.WINDOW_WIDTH,
		AntibodiesWindow.TAB_PANEL_HEIGHT
	)
	self.tabs.target = self
	self.tabs:initialise()
	self:addChild(self.tabs)

	self.progressPanel = AntibodiesProgressPanel:new(
		0,
		AntibodiesWindow.TAB_BOTTOM,
		AntibodiesWindow.LEFT_PANEL_WIDTH,
		AntibodiesWindow.LEFT_RIGHT_HEIGHT
	)
	self.progressPanel:initialise()
	self:addChild(self.progressPanel)

	self.conditionPanel = AntibodiesConditionPanel:new(
		AntibodiesWindow.LEFT_RIGHT_SEP + AntibodiesWindow.LEFT_PANEL_WIDTH,
		AntibodiesWindow.TAB_BOTTOM,
		AntibodiesWindow.RIGHT_PANEL_WIDTH,
		AntibodiesWindow.LEFT_RIGHT_HEIGHT
	)
	self.conditionPanel:initialise()

	self.woundsPanel = AntibodiesWoundsPanel:new(
		AntibodiesWindow.LEFT_RIGHT_SEP + AntibodiesWindow.LEFT_PANEL_WIDTH,
		AntibodiesWindow.TAB_BOTTOM,
		AntibodiesWindow.RIGHT_PANEL_WIDTH,
		AntibodiesWindow.LEFT_RIGHT_HEIGHT
	)
	self.woundsPanel:initialise()

	self.tabs:addView(getText("UI_Antibodies_KnoxInfection_ConditionEffects"), self.conditionPanel)
	self.tabs:addView(getText("UI_Antibodies_KnoxInfection_WoundEffects"), self.woundsPanel)
	--self.tabs:addView(getText("UI_Antibodies_KnoxInfection_InfectionEffects"), self.infectionsPanel)
	--self.tabs:addView(getText("UI_Antibodies_KnoxInfection_HygieneEffects"), self.hygienePanel)

	self:createCloseBtn()
end

function AntibodiesWindow:drawTitle()
	local title = getText("UI_Antibodies_KnoxInfection_TitleSelf")
	if self.patient ~= self.doctor then
		title = getText(
			"UI_Antibodies_KnoxInfection_TitleOther",
			self.patient:getDescriptor():getForename() .. " " .. self.patient:getDescriptor():getSurname()
		)
	end
	local titleWidth = getTextManager():MeasureStringX(UIFont.Medium, title)
	self:drawText(
		title,
		(self:getWidth() / 2) - (titleWidth / 2),
		AntibodiesWindow.WINDOW_PADDING,
		1,
		1,
		1,
		1,
		UIFont.Medium
	)
end

function AntibodiesWindow:drawTabsBox()
	self:drawRectBorder(
		0,
		AntibodiesWindow.TOP_HEIGHT,
		AntibodiesWindow.WINDOW_WIDTH,
		AntibodiesWindow.TAB_BUTTONS_HEIGHT,
		AntibodiesWindow.BORDER_COLOR.a,
		AntibodiesWindow.BORDER_COLOR.r,
		AntibodiesWindow.BORDER_COLOR.g,
		AntibodiesWindow.BORDER_COLOR.b
	)
end

function AntibodiesWindow:render()
	ISPanelJoypad.render(self)

	self:drawTitle()

	local medicalFile = AntibodiesMedicalFile.of(self.patient)
	self.progressPanel.medicalFile = medicalFile
	self.conditionPanel.medicalFile = medicalFile
	self.woundsPanel.medicalFile = medicalFile
	--self.infectionsPanel.medicalFile = medicalFile
	--self.hygienePanel.medicalFile = medicalFile
end

function AntibodiesWindow:onGainJoypadFocus(joypadData)
	ISPanelJoypad.onGainJoypadFocus(self, joypadData)
	if self.closeButton and self.closeButton:isVisible() then
		self:setISButtonForB(self.closeButton)
	end

	--[[
	if self.tabs then
		local tabButton = self.tabs:getTabButton(self.tabs.activeView)
		if tabButton then
			tabButton:setJoypadFocused(true)
			self.joypadFocused = tabButton
		end
	end
	]]
end

function AntibodiesWindow:getCurrentView()
	local viewWrapper = self.tabs.viewList[self.tabs:getActiveViewIndex()]
	if viewWrapper and viewWrapper.view then
		return viewWrapper.view
	end
	return nil
end

function AntibodiesWindow:onJoypadDown(button, joypadData)
	ISPanelJoypad.onJoypadDown(self, joypadData)
	if button == Joypad.BButton then
		self:close()
	end
	if button == Joypad.LBumper or button == Joypad.RBumper then
		local count = #self.tabs.viewList
		if count <= 1 then
			return
		end
		local dir = (button == Joypad.RBumper) and 1 or -1
		local index = self.tabs:getActiveViewIndex()
		if dir == 1 then
			index = index + 1
			if index > count then
				index = 1
			end
		elseif dir == -1 then
			index = index - 1
			if index <= 0 then
				index = count
			end
		end
		self.tabs:activateView(self.tabs.viewList[index].name)
	end
end

function AntibodiesWindow:onJoypadDirUp(joypadData)
	ISPanelJoypad.onJoypadDirUp(self, joypadData)
	local view = self:getCurrentView()
	if view then
		view:scrollUp()
	end
end

function AntibodiesWindow:onJoypadDirDown(joypadData)
	ISPanelJoypad.onJoypadDirDown(self, joypadData)
	local view = self:getCurrentView()
	if view then
		view:scrollDown()
	end
end

-----------------------------------------------------
--CALLBACKS------------------------------------------
-----------------------------------------------------

local function onPlayerDeath(player)
	for key, window in ipairs(AntibodiesWindow.instance) do
		if window.doctor == player or window.patient == player then
			window:close()
		end
	end
end
Events.OnPlayerDeath.Add(onPlayerDeath)

-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------

return AntibodiesWindow
