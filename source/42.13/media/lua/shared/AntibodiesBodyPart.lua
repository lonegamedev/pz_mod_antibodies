local AntibodiesEnum = require("AntibodiesEnum")
local AntibodiesUtils = require("AntibodiesUtils")

local AntibodiesBodyPart = {}
AntibodiesBodyPart.__index = AntibodiesBodyPart

function AntibodiesBodyPart.new(bodyPart)
	local instance = setmetatable({}, AntibodiesBodyPart)
	instance.type = bodyPart:getType()
	instance.id = instance.type:index()

	instance.treatmentSkill = {}
	for _, key in ipairs(AntibodiesEnum.BodyPart.Treatment.list()) do
		instance.treatmentSkill[key] = 0
	end

	instance:update(bodyPart, nil)
	return instance
end

function AntibodiesBodyPart.rehydrate(bodyPart)
	if getmetatable(bodyPart) ~= AntibodiesBodyPart then
		setmetatable(bodyPart, AntibodiesBodyPart)
	end
end

function AntibodiesBodyPart:update(bodyPart, config)
	self.bodyBlood = 0
	self.bodyDirt = 0

	self.clothingBlood = 0
	self.clothingDirt = 0

	self.totalBlood = 0
	self.totalDirt = 0

	self.woundEffect = {}
	self.totalWoundEffect = 0

	self.treatmentEffect = {}
	self.totalTreatmentEffect = 0

	self.infectionEffect = {}
	self.totalInfectionEffect = 0

	self.hygieneEffect = {}
	self.totalHygieneEffect = 0

	self:probeBodyPart(bodyPart)
	self:calculateEffect(config)
end

function AntibodiesBodyPart:probeBodyPart(bodyPart)
	self.wound = {}
	for _, key in ipairs(AntibodiesEnum.BodyPart.Wound.list()) do
		self.wound[key] = false
	end
	self.treatment = {}
	for _, key in ipairs(AntibodiesEnum.BodyPart.Treatment.list()) do
		self.treatment[key] = false
	end
	if bodyPart:getDeepWoundTime() > 0 then
		self.wound[AntibodiesEnum.BodyPart.Wound.DEEP_WOUNDED] = true
	end
	if bodyPart:bandaged() then
		if not bodyPart:isBandageDirty() then
			self.treatment[AntibodiesEnum.BodyPart.Treatment.BANDAGED] = true
			if AntibodiesUtils.isAlcoholBandage(bodyPart:getBandageType()) then
				self.treatment[AntibodiesEnum.BodyPart.Treatment.STERILIZED_BANDAGE] = true
			end
		end
	else
		if bodyPart:getBleedingTime() > 0 then
			self.wound[AntibodiesEnum.BodyPart.Wound.BLEEDING] = true
		end
	end
	if bodyPart:getBiteTime() > 0 then
		self.wound[AntibodiesEnum.BodyPart.Wound.BITTEN] = true
	end
	if bodyPart:getCutTime() > 0 then
		self.wound[AntibodiesEnum.BodyPart.Wound.CUT] = true
	end
	if bodyPart:getScratchTime() > 0 then
		self.wound[AntibodiesEnum.BodyPart.Wound.SCRATCHED] = true
	end
	if bodyPart:getBurnTime() > 0 then
		self.wound[AntibodiesEnum.BodyPart.Wound.BURNT] = true
	end
	if bodyPart:isNeedBurnWash() and bodyPart:getBurnTime() > 0 then
		self.wound[AntibodiesEnum.BodyPart.Wound.NEED_BURN_WASH] = true
	end
	if bodyPart:getStitchTime() > 0 then
		self.wound[AntibodiesEnum.BodyPart.Wound.STICHED] = true
	end
	if bodyPart:haveBullet() then
		self.wound[AntibodiesEnum.BodyPart.Wound.HAVE_BULLET] = true
	end
	if bodyPart:haveGlass() then
		self.wound[AntibodiesEnum.BodyPart.Wound.HAVE_GLASS] = true
	end

	if bodyPart:getAlcoholLevel() > 0 then
		self.treatment[AntibodiesEnum.BodyPart.Treatment.STERILIZED_WOUND] = true
	end
	if bodyPart:getGarlicFactor() > 0 then
		self.treatment[AntibodiesEnum.BodyPart.Treatment.GARLIC] = true
	end
	if bodyPart:getPlantainFactor() > 0 then
		self.treatment[AntibodiesEnum.BodyPart.Treatment.PLANTAIN] = true
	end
	if bodyPart:getComfreyFactor() > 0 then
		self.treatment[AntibodiesEnum.BodyPart.Treatment.COMFREY] = true
	end

	self.infection = {}
	for _, key in ipairs(AntibodiesEnum.BodyPart.Infection.list()) do
		self.infection[key] = false
	end
	if bodyPart:isInfectedWound() then
		self.infection[AntibodiesEnum.BodyPart.Infection.REGULAR] = true
	end
	if bodyPart:IsInfected() then
		if self.wound[AntibodiesEnum.BodyPart.Wound.BITTEN] then
			self.infection[AntibodiesEnum.BodyPart.Infection.KNOX_BITE] = true
		end
		if self.wound[AntibodiesEnum.BodyPart.Wound.CUT] then
			self.infection[AntibodiesEnum.BodyPart.Infection.KNOX_CUT] = true
		end
		if self.wound[AntibodiesEnum.BodyPart.Wound.SCRATCHED] then
			self.infection[AntibodiesEnum.BodyPart.Infection.KNOX_SCRATCH] = true
		end
	end
end

function AntibodiesBodyPart:calculateEffect(config)
	self.effect = {}
	self.totalEffect = 0.0

	if not config then
		return self
	end

	return self
end

function AntibodiesBodyPart:isKnoxInfected()
	return self.infection[AntibodiesEnum.BodyPart.Infection.KNOX_SCRATCH]
		or self.infection[AntibodiesEnum.BodyPart.Infection.KNOX_CUT]
		or self.infection[AntibodiesEnum.BodyPart.Infection.KNOX_BITE]
end

function AntibodiesBodyPart:setTreatmentSkill(treatmentId, skill)
	self.treatmentSkill[treatmentId] = AntibodiesUtils.clamp(tonumber(skill) or 0, 0, 10)
end

--[[

function AntibodiesBodyPart.newTreatments()
	local res = {}
	for _, key in ipairs(TreatmentEnum.list()) do
		res[key] = 0
	end
	return res
end

function AntibodiesBodyPart.coversBodyPart(clothing, bloodBodyPart)
	if clothing == nil then
		return false
	end
	local parts = clothing:getCoveredParts()
	if parts ~= nil then
		for i = 0, parts:size() - 1 do
			if parts:get(i) == bloodBodyPart then
				return true
			end
		end
	end
	return false
end

function AntibodiesBodyPart.getClothingHygiene(bodyPart)
	local res = {
		[HygieneEnum.CLOTHING_BLOOD] = 0,
		[HygieneEnum.CLOTHING_DIRT] = 0,
		[HygieneEnum.CLOTHING_PIECES] = 0,
	}
	local parentChar = bodyPart:getParentChar()
	local bloodBodyPart = BloodBodyPartType.FromIndex(bodyPart:getType():index())
	local wornItems = parentChar:getWornItems()
	if wornItems then
		if wornItems:size() > 0 then
			for index = 0, wornItems:size() - 1 do
				local clothing = wornItems:getItemByIndex(index)
				if clothing ~= nil and clothing:IsClothing() then
					if AntibodiesBodyPart.coversBodyPart(clothing, bloodBodyPart) then
						local visualItem = clothing:getVisual()
						if visualItem ~= nil then
							res[HygieneEnum.CLOTHING_BLOOD] = res[HygieneEnum.CLOTHING_BLOOD]
								+ visualItem:getBlood(bloodBodyPart)
							res[HygieneEnum.CLOTHING_DIRT] = res[HygieneEnum.CLOTHING_DIRT]
								+ visualItem:getDirt(bloodBodyPart)
							res[HygieneEnum.CLOTHING_PIECES] = res[HygieneEnum.CLOTHING_PIECES] + 1
						end
					end
				end
			end
		end
	end
	res[HygieneEnum.CLOTHING_BLOOD] = math.min(1.0, res[HygieneEnum.CLOTHING_BLOOD])
	res[HygieneEnum.CLOTHING_DIRT] = math.min(1.0, res[HygieneEnum.CLOTHING_DIRT])
	return res
end

function AntibodiesBodyPart.newHygiene(bodyPart, wounds, treatments)
	local res = {
		[HygieneEnum.BODY_BLOOD] = 0,
		[HygieneEnum.BODY_DIRT] = 0,
		[HygieneEnum.CLOTHING_BLOOD] = 0,
		[HygieneEnum.CLOTHING_DIRT] = 0,
		[HygieneEnum.CLOTHING_PIECES] = 0,
		[HygieneEnum.TOTAL_BLOOD] = 0,
		[HygieneEnum.TOTAL_DIRT] = 0,
	}

	local humanVisual = bodyPart:getParentChar():getHumanVisual()
	local bloodBodyPart = BloodBodyPartType.FromIndex(bodyPart:getType():index())
	res[HygieneEnum.BODY_BLOOD] = humanVisual:getBlood(bloodBodyPart)
	res[HygieneEnum.BODY_DIRT] = humanVisual:getDirt(bloodBodyPart)

	local clothingHygiene = AntibodiesBodyPart.getClothingHygiene(bodyPart)
	res[HygieneEnum.CLOTHING_BLOOD] = clothingHygiene[HygieneEnum.CLOTHING_BLOOD]
	res[HygieneEnum.CLOTHING_DIRT] = clothingHygiene[HygieneEnum.CLOTHING_DIRT]
	res[HygieneEnum.CLOTHING_PIECES] = clothingHygiene[HygieneEnum.CLOTHING_PIECES]

	res[HygieneEnum.TOTAL_BLOOD] = math.max(1.0, res[HygieneEnum.BODY_BLOOD] + res[HygieneEnum.CLOTHING_BLOOD])
	res[HygieneEnum.TOTAL_DIRT] = math.max(1.0, res[HygieneEnum.BODY_DIRT] + res[HygieneEnum.CLOTHING_DIRT])

	return res
end

]]

return AntibodiesBodyPart

--[[
		for wound_key in pairs(wounds) do
			if wounds[wound_key] and Antibodies.currentOptions.hygiene[wound_key] then
				local m = Antibodies.currentOptions.hygiene[wound_key]
				if math.abs(m) >= 0.1 then
					result.mods[wound_key] = m
					result.mod = result.mod + m
				end
			end
		end
]]
