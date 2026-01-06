require("ISUI/ISPanel")
ISAntibodiesProgressPanel = ISPanel:derive("ISAntibodiesProgressPanel")

local SPRITE_SIZE = 160.0
local SPRITES_IN_ROW = 10

local ROW_HEIGHT = 20
local COL_WIDTH = 120

local RADIAL_TEXTURE = getTexture("media/ui/lgd_antibodies_radial_progress.png")

ISAntibodiesProgressPanel.SPRITE_SIZE = SPRITE_SIZE

function getSpriteFrame(index)
	local x = index % SPRITES_IN_ROW
	local y = math.floor(index / SPRITES_IN_ROW)
	return x, y
end

function ISAntibodiesProgressPanel:initialise()
	ISPanel.initialise(self)
end

function ISAntibodiesProgressPanel:createChildren()
	ISPanel.createChildren(self)
	self.doStencilRender = true
	self.borderColor.a = 0.0
	self.backgroundColor.a = 0.0
end

function ISAntibodiesProgressPanel:prerender()
	ISPanel.prerender(self)
end

function ISAntibodiesProgressPanel:drawProgressCircle(x, y, progress, r, g, b, a)
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

function ISAntibodiesProgressPanel:drawProgress(x, y, virus, antibodies, stage)
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

function ISAntibodiesProgressPanel:drawAntibodiesVirusText(x, y, str)
	self:drawTextCentre(str, x, y, 1, 1, 1, 1, UIFont.Small)
end

function ISAntibodiesProgressPanel:render()
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
