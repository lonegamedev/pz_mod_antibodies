require("ISPanel")
local AntibodiesUI = require("ui/antibodies_ui")
local AntibodiesUtils = require("antibodies_utils")

local AntibodiesProgressPanel = ISPanel:derive("AntibodiesProgressPanel")

AntibodiesProgressPanel.SPRITE_SIZE = 160.0
AntibodiesProgressPanel.SPRITES_IN_ROW = 10
AntibodiesProgressPanel.ROW_HEIGHT = 20
AntibodiesProgressPanel.COL_WIDTH = 120
AntibodiesProgressPanel.RADIAL_TEXTURE = getTexture("media/ui/lgd_antibodies_radial_progress.png")

function AntibodiesProgressPanel:new(x, y, width, height)
	local instance = ISPanel:new(x, y, width, height)
	setmetatable(instance, self)
	self.__index = self

	instance.medicalFile = nil

	instance.doStencilRender = true
	instance.borderColor.a = 0.0
	instance.backgroundColor.a = 0.0

	return instance
end

function AntibodiesProgressPanel:initialise()
	ISPanel.initialise(self)
end

function AntibodiesProgressPanel.getSpriteFrame(index)
	local x = index % AntibodiesProgressPanel.SPRITES_IN_ROW
	local y = math.floor(index / AntibodiesProgressPanel.SPRITES_IN_ROW)
	return x, y
end

function AntibodiesProgressPanel:drawProgressCircle(x, y, progress, r, g, b, a)
	local col, row = AntibodiesProgressPanel.getSpriteFrame(math.ceil(progress) - 1)
	self.javaObject:DrawSubTextureRGBA(
		AntibodiesProgressPanel.RADIAL_TEXTURE,
		AntibodiesProgressPanel.SPRITE_SIZE * col,
		AntibodiesProgressPanel.SPRITE_SIZE * row,
		AntibodiesProgressPanel.SPRITE_SIZE,
		AntibodiesProgressPanel.SPRITE_SIZE,
		x,
		y,
		AntibodiesProgressPanel.SPRITE_SIZE,
		AntibodiesProgressPanel.SPRITE_SIZE,
		r,
		g,
		b,
		a
	)
end

function AntibodiesProgressPanel:drawProgress(x, y, virus, antibodies, stage)
	self:drawProgressCircle(x, y, 100.0, 1.0, 1.0, 1.0, 0.25)
	self:drawProgressCircle(x, y, virus, 1.0, 1.0, 1.0, 0.45)
	self:drawProgressCircle(x, y, antibodies, 1.0, 1.0, 1.0, 0.55)

	local halfSpriteSize = AntibodiesProgressPanel.SPRITE_SIZE / 2

	self:drawTextCentre(
		getText("UI_Antibodies_KnoxInfection_Stage"),
		x + halfSpriteSize,
		y + halfSpriteSize - (AntibodiesUI.FONT_HGT_SMALL / 2) - 10,
		0.55,
		0.55,
		0.55,
		1,
		UIFont.Small
	)

	local stageLabel = getText("UI_Antibodies_Infection_Stage_" .. tostring(stage))

	self:drawTextCentre(
		stageLabel,
		x + halfSpriteSize,
		y + halfSpriteSize - (AntibodiesUI.FONT_HGT_SMALL / 2) + 10,
		1,
		1,
		1,
		1,
		UIFont.Small
	)
end

function AntibodiesProgressPanel:drawAntibodiesVirusText(x, y, str)
	self:drawTextCentre(str, x, y, 1, 1, 1, 1, UIFont.Small)
end

function AntibodiesProgressPanel:render()
	ISPanel.render(self)
	if self.medicalFile then
		local knoxInfectionLevel = self.medicalFile.knoxInfectionLevel
		local knoxInfectionDelta = self.medicalFile.knoxInfectionDelta
		local knoxAntibodiesLevel = self.medicalFile.knoxAntibodiesLevel
		local knoxAntibodiesDelta = self.medicalFile.knoxAntibodiesDelta
		local knoxInfectionStage = self.medicalFile.knoxInfectionStage

		local contentHeight = AntibodiesProgressPanel.SPRITE_SIZE
		local x = (self.width - AntibodiesProgressPanel.SPRITE_SIZE) / 2
		local y = (self.height - contentHeight) / 2
		self:drawProgress(x, y, knoxInfectionLevel, knoxAntibodiesLevel, knoxInfectionStage)
		y = y + AntibodiesProgressPanel.SPRITE_SIZE + 10
		self:drawAntibodiesVirusText(
			x + (AntibodiesProgressPanel.SPRITE_SIZE / 2),
			y,
			getText(
				"UI_Antibodies_KnoxInfection_Virus",
				AntibodiesUtils.formatFloat(knoxInfectionLevel, 2),
				AntibodiesUtils.formatChange(knoxInfectionDelta, 3)
			)
		)
		y = y + AntibodiesProgressPanel.ROW_HEIGHT
		self:drawAntibodiesVirusText(
			x + (AntibodiesProgressPanel.SPRITE_SIZE / 2),
			y,
			getText(
				"UI_Antibodies_KnoxInfection_Antibodies",
				AntibodiesUtils.formatFloat(knoxAntibodiesLevel, 2),
				AntibodiesUtils.formatChange(knoxAntibodiesDelta, 3)
			)
		)
	end
end

return AntibodiesProgressPanel

--[[
require("ISUI/ISPanel")
local AntibodiesProgressPanel = ISPanel:derive("AntibodiesProgressPanel")

local SPRITE_SIZE = 160.0
local SPRITES_IN_ROW = 10

local ROW_HEIGHT = 20
local COL_WIDTH = 120

local RADIAL_TEXTURE = getTexture("media/ui/lgd_antibodies_radial_progress.png")

AntibodiesProgressPanel.SPRITE_SIZE = SPRITE_SIZE

function getSpriteFrame(index)
	local x = index % SPRITES_IN_ROW
	local y = math.floor(index / SPRITES_IN_ROW)
	return x, y
end

function AntibodiesProgressPanel:initialise()
	ISPanel.initialise(self)
end

function AntibodiesProgressPanel:createChildren()
	ISPanel.createChildren(self)
	self.doStencilRender = true
	self.borderColor.a = 0.0
	self.backgroundColor.a = 0.0
end

function AntibodiesProgressPanel:prerender()
	ISPanel.prerender(self)
end

function AntibodiesProgressPanel:drawProgressCircle(x, y, progress, r, g, b, a)
	local col, row = getSpriteFrame(math.ceil(progress) - 1)
	self.javaObject:DrawSubTextureRGBA(
		RADIAL_TEXTURE,
		SPRITE_SIZE * col,
		SPRITE_SIZE * row,
		SPRITE_SIZE,
		SPRITE_SIZE,
		x,
		y,
		SPRITE_SIZE,
		SPRITE_SIZE,
		r,
		g,
		b,
		a
	)
end

function AntibodiesProgressPanel:drawProgress(x, y, virus, antibodies, stage)
	self:drawProgressCircle(x, y, 100.0, 1.0, 1.0, 1.0, 0.25)
	self:drawProgressCircle(x, y, virus, 1.0, 1.0, 1.0, 0.45)
	self:drawProgressCircle(x, y, antibodies, 1.0, 1.0, 1.0, 0.55)

	local halfSpriteSize = SPRITE_SIZE / 2

	self:drawTextCentre(
		getText("UI_Antibodies_KnoxInfection_Stage"),
		x + halfSpriteSize,
		y + halfSpriteSize - (AntibodiesUI.FONT_HGT_SMALL / 2) - 10,
		0.55,
		0.55,
		0.55,
		1,
		UIFont.Small
	)

	local stageLabel = getText("UI_Antibodies_Infection_Stage_" .. tostring(stage))

	self:drawTextCentre(
		stageLabel,
		x + halfSpriteSize,
		y + halfSpriteSize - (AntibodiesUI.FONT_HGT_SMALL / 2) + 10,
		1,
		1,
		1,
		1,
		UIFont.Small
	)
end

function AntibodiesProgressPanel:drawAntibodiesVirusText(x, y, str)
	self:drawTextCentre(str, x, y, 1, 1, 1, 1, UIFont.Small)
end

function AntibodiesProgressPanel:render()
	ISPanel.render(self)
	if self.medicalFile then
		local contentHeight = SPRITE_SIZE
		local x = (self.width - SPRITE_SIZE) / 2
		local y = (self.height - contentHeight) / 2
		self:drawProgress(
			x,
			y,
			self.medicalFile.knoxInfectionLevel,
			self.medicalFile.knoxAntibodiesLevel,
			self.medicalFile.knoxInfectionStage
		)
		y = y + SPRITE_SIZE + 10
		self:drawAntibodiesVirusText(
			x + (SPRITE_SIZE / 2),
			y,
			getText(
				"UI_Antibodies_KnoxInfection_Virus",
				AntibodiesUtils.format_float(self.medicalFile.knoxInfectionLevel, 2),
				AntibodiesUtils.format_change(self.medicalFile.knoxInfectionDelta, 3)
			)
		)
		y = y + ROW_HEIGHT
		self:drawAntibodiesVirusText(
			x + (SPRITE_SIZE / 2),
			y,
			getText(
				"UI_Antibodies_KnoxInfection_Antibodies",
				AntibodiesUtils.format_float(self.medicalFile.knoxAntibodiesLevel, 2),
				AntibodiesUtils.format_change(self.medicalFile.knoxAntibodiesDelta, 3)
			)
		)
	end
	--self:drawRect(0, 0, self.width, self.height, 0.25, 1, 0, 0);
end

return AntibodiesProgressPanel
]]
