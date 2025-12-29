require("ISHealthPanel")

local Antibodies = require("antibodies")
local AntibodiesUI = require("ui/antibodies_ui")
local AntibodiesWindow = require("ui/antibodies_window")

local AntibodiesConfig = require("antibodies_config")
local AntibodiesEnum = require("antibodies_enum")
local AntibodiesUtils = require("antibodies_utils")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local UI_BORDER_SPACING = 10

---@diagnostic disable-next-line: duplicate-set-field
function ISHealthPanel:onKnoxInfectionClicked()
	print("ANTIBODIES BUTTON CLICKED")
	--self:showAntibodiesWindow()
end

local ISHealthPanel_createChildren = ISHealthPanel.createChildren
---@diagnostic disable-next-line: duplicate-set-field
function ISHealthPanel:createChildren()
	ISHealthPanel_createChildren(self)

	local fitnessBtn = self.fitness
	if not fitnessBtn then
		return
	end

	self._antibodiesBtn = ISButton:new(
		fitnessBtn:getRight() + UI_BORDER_SPACING,
		fitnessBtn:getY(),
		100,
		FONT_HGT_SMALL + 6,
		getText("UI_Antibodies_KnoxInfection_Button"),
		self,
		ISHealthPanel.onKnoxInfectionClicked
	)

	self._antibodiesBtn.internal = "ANTIBODIES"
	self._antibodiesBtn:initialise()
	self._antibodiesBtn:instantiate()
	self._antibodiesBtn:setVisible(true)

	self:addChild(self._antibodiesBtn)
end

local ISHealthPanel_update = ISHealthPanel.update
---@diagnostic disable-next-line: duplicate-set-field
function ISHealthPanel:update()
	ISHealthPanel_update(self)

	local showDiagnoseBtn = false
	if self._antibodiesBtn and AntibodiesConfig.current ~= nil then
		local diagnoseEnabled =
			AntibodiesConfig.current[AntibodiesEnum.Config.GENERAL][AntibodiesEnum.Config.General.DIAGNOSE_ENABLED]
		local requiredDoctorSkill =
			AntibodiesConfig.current[AntibodiesEnum.Config.GENERAL][AntibodiesEnum.Config.General.DIAGNOSE_SKILL_NEEDED]
		local doctorLevel = AntibodiesUtils.getMedicalSkill(self:getDoctor())
		showDiagnoseBtn = doctorLevel >= requiredDoctorSkill
	end
	self._antibodiesBtn:setVisible(showDiagnoseBtn)

	if not self._antibodiesBtn or not self:isReallyVisible() then
		return
	end

	local width = math.max(
		self.tabtotalwidth,
		self.healthPanel:getRight(),
		self.fitness:getRight(),
		self._antibodiesBtn:getRight(),
		self.listbox.x + self.listbox.textRight
	)
	self:setWidthAndParentWidth(width + 20 + UI_BORDER_SPACING + 1)
end

local ISHealthPanel_onGainJoypadFocus = ISHealthPanel.onGainJoypadFocus
---@diagnostic disable-next-line: duplicate-set-field
function ISHealthPanel:onGainJoypadFocus(joypadData)
	ISHealthPanel_onGainJoypadFocus(self, joypadData)
	if self._antibodiesBtn and self._antibodiesBtn:isVisible() then
		self:setISButtonForX(self._antibodiesBtn)
	end
end

local ISHealthPanel_onJoypadDown = ISHealthPanel.onJoypadDown
---@diagnostic disable-next-line: duplicate-set-field
function ISHealthPanel:onJoypadDown(button)
	if button == Joypad.XButton and self._antibodiesBtn and self._antibodiesBtn:isVisible() then
		self._antibodiesBtn:forceClick()
		return
	end
	ISHealthPanel_onJoypadDown(self, button)
end
