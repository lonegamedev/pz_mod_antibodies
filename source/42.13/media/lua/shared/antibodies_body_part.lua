local AntibodiesEnum = require("antibodies_enum")
local AntibodiesUtils = require("antibodies_utils")
local AntibodiesEffects = require("antibodies_effects")

local AntibodiesBodyPart = {}
AntibodiesBodyPart.__index = AntibodiesBodyPart
AntibodiesBodyPart.__name = "AntibodiesBodyPart"

function AntibodiesBodyPart:new(bodyPartNative)
	local instance = setmetatable({}, self)

	instance.index = bodyPartNative:getType():index()
	instance.id = AntibodiesEnum.BodyPart.fromIndex(instance.index)

	instance.treatmentSkill = {}
	for _, key in ipairs(AntibodiesEnum.BodyPart.Treatment.list()) do
		instance.treatmentSkill[key] = 0
	end

	instance.bodyBlood = 0
	instance.bodyDirt = 0

	instance.clothingBlood = 0
	instance.clothingDirt = 0
	instance.clothingPieces = 0

	instance.woundEffects = AntibodiesEffects:new()
	instance.treatmentEffects = AntibodiesEffects:new()
	instance.infectionEffects = AntibodiesEffects:new()
	instance.hygieneEffects = AntibodiesEffects:new()

	instance:update(bodyPartNative, nil)
	return instance
end

function AntibodiesBodyPart.rehydrate(bodyPart)
	if getmetatable(bodyPart) ~= AntibodiesBodyPart then
		setmetatable(bodyPart, AntibodiesBodyPart)
		setmetatable(bodyPart.woundEffects, AntibodiesEffects)
		setmetatable(bodyPart.treatmentEffects, AntibodiesEffects)
		setmetatable(bodyPart.infectionEffects, AntibodiesEffects)
		setmetatable(bodyPart.hygieneEffects, AntibodiesEffects)
	end
end

function AntibodiesBodyPart:update(bodyPartNative, config)
	self:probeBodyPart(bodyPartNative)
	self:calculateEffect(config)
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

function AntibodiesBodyPart:probeBodyPart(bodyPartNative)
	self.bodyBlood = 0
	self.bodyDirt = 0

	self.clothingBlood = 0
	self.clothingDirt = 0
	self.clothingPieces = 0

	self.wound = {}
	for _, key in ipairs(AntibodiesEnum.BodyPart.Wound.list()) do
		self.wound[key] = false
	end
	self.treatment = {}
	for _, key in ipairs(AntibodiesEnum.BodyPart.Treatment.list()) do
		self.treatment[key] = false
	end

	if bodyPartNative == nil then
		return
	end

	if bodyPartNative:getDeepWoundTime() > 0 then
		self.wound[AntibodiesEnum.BodyPart.Wound.DEEP_WOUNDED] = true
	end
	if bodyPartNative:bandaged() then
		self.treatment[AntibodiesEnum.BodyPart.Treatment.BANDAGED] = true
		if not bodyPartNative:isBandageDirty() then
			self.treatment[AntibodiesEnum.BodyPart.Treatment.CLEAN_BANDAGE] = true
			if AntibodiesUtils.isAlcoholBandage(bodyPartNative:getBandageType()) then
				self.treatment[AntibodiesEnum.BodyPart.Treatment.STERILIZED_BANDAGE] = true
			end
		end
	else
		if bodyPartNative:getBleedingTime() > 0 then
			self.wound[AntibodiesEnum.BodyPart.Wound.BLEEDING] = true
		end
	end
	if bodyPartNative:getBiteTime() > 0 then
		self.wound[AntibodiesEnum.BodyPart.Wound.BITTEN] = true
	end
	if bodyPartNative:getCutTime() > 0 then
		self.wound[AntibodiesEnum.BodyPart.Wound.CUT] = true
	end
	if bodyPartNative:getScratchTime() > 0 then
		self.wound[AntibodiesEnum.BodyPart.Wound.SCRATCHED] = true
	end
	if bodyPartNative:getBurnTime() > 0 then
		self.wound[AntibodiesEnum.BodyPart.Wound.BURNT] = true
	end
	if bodyPartNative:isNeedBurnWash() and bodyPartNative:getBurnTime() > 0 then
		self.wound[AntibodiesEnum.BodyPart.Wound.NEED_BURN_WASH] = true
	end
	if bodyPartNative:getStitchTime() > 0 then
		self.wound[AntibodiesEnum.BodyPart.Wound.STICHED] = true
	end
	if bodyPartNative:haveBullet() then
		self.wound[AntibodiesEnum.BodyPart.Wound.HAVE_BULLET] = true
	end
	if bodyPartNative:haveGlass() then
		self.wound[AntibodiesEnum.BodyPart.Wound.HAVE_GLASS] = true
	end

	if bodyPartNative:getAlcoholLevel() > 0 then
		self.treatment[AntibodiesEnum.BodyPart.Treatment.STERILIZED_WOUND] = true
	end
	if bodyPartNative:getGarlicFactor() > 0 then
		self.treatment[AntibodiesEnum.BodyPart.Treatment.GARLIC] = true
	end
	if bodyPartNative:getPlantainFactor() > 0 then
		self.treatment[AntibodiesEnum.BodyPart.Treatment.PLANTAIN] = true
	end
	if bodyPartNative:getComfreyFactor() > 0 then
		self.treatment[AntibodiesEnum.BodyPart.Treatment.COMFREY] = true
	end

	self.infection = {}
	for _, key in ipairs(AntibodiesEnum.BodyPart.Infection.list()) do
		self.infection[key] = false
	end
	if bodyPartNative:isInfectedWound() then
		self.infection[AntibodiesEnum.BodyPart.Infection.REGULAR] = true
	end
	if bodyPartNative:IsInfected() then
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

	local parentChar = bodyPartNative:getParentChar()
	local humanVisual = parentChar:getHumanVisual()
	local bloodBodyPart = BloodBodyPartType.FromIndex(bodyPartNative:getType():index())

	self.bodyBlood = humanVisual:getBlood(bloodBodyPart)
	self.bodyDirt = humanVisual:getDirt(bloodBodyPart)

	local wornItems = parentChar:getWornItems()
	if wornItems then
		if wornItems:size() > 0 then
			for index = 0, wornItems:size() - 1 do
				local clothing = wornItems:getItemByIndex(index)
				if clothing ~= nil and clothing:IsClothing() then
					if AntibodiesBodyPart.coversBodyPart(clothing, bloodBodyPart) then
						local visualItem = clothing:getVisual()
						if visualItem ~= nil then
							self.clothingBlood = self.clothingBlood + visualItem:getBlood(bloodBodyPart)
							self.clothingDirt = self.clothingDirt + visualItem:getDirt(bloodBodyPart)
							self.clothingPieces = self.clothingPieces + 1
						end
					end
				end
			end
		end
	end
	self.clothingBlood = math.min(1.0, self.clothingBlood)
	self.clothingDirt = math.min(1.0, self.clothingDirt)
end

function AntibodiesBodyPart:calculateEffect(config)
	self.woundEffects:clear()
	self.treatmentEffects:clear()
	self.infectionEffects:clear()
	self.hygieneEffects:clear()

	if not config then
		return self
	end

	local doctorSkillTreatmentMod =
		config[AntibodiesEnum.Config.GENERAL][AntibodiesEnum.Config.General.DOCTOR_SKILL_TREATMENT_MOD]

	local hygieneTreatmentMod = 0
	for _, key in ipairs(AntibodiesEnum.BodyPart.Treatment.list()) do
		if self.treatment[key] then
			local baseEffect = config[AntibodiesEnum.Config.TREATMENT][key] or 0
			local doctorSkill = self:getTreatmentSkill(key)
			self.treatmentEffects:set(key, baseEffect * doctorSkill * doctorSkillTreatmentMod)
			hygieneTreatmentMod = hygieneTreatmentMod + (config[AntibodiesEnum.Config.HYGIENE_TREATMENT_MOD][key] or 0)
		end
	end

	for _, key in ipairs(AntibodiesEnum.BodyPart.Infection.list()) do
		if self.infection[key] then
			self.infectionEffects:set(key, config[AntibodiesEnum.Config.INFECTION][key] or 0)
		end
	end

	local blood = math.max(self.bodyBlood, self.clothingBlood)
	local dirt = math.max(self.bodyDirt, self.clothingDirt)

	local bloodEffect = config[AntibodiesEnum.Config.HYGIENE][AntibodiesEnum.Config.Hygiene.BLOOD_EFFECT]
	local dirtEffect = config[AntibodiesEnum.Config.HYGIENE][AntibodiesEnum.Config.Hygiene.DIRT_EFFECT]

	for _, key in ipairs(AntibodiesEnum.BodyPart.Wound.list()) do
		if self.wound[key] then
			self.woundEffects:set(key, config[AntibodiesEnum.Config.WOUND][key] or 0)

			local hygieneWoundMod = (config[AntibodiesEnum.Config.HYGIENE_WOUND_MOD][key] or 0)
			local hygieneMod = math.min(hygieneWoundMod + hygieneTreatmentMod, 0)
			local hygieneEffect = (hygieneMod * blood * -bloodEffect) + (hygieneMod * dirt * -dirtEffect)

			self.hygieneEffects:set(key, hygieneEffect)
		end
	end

	return self
end

function AntibodiesBodyPart:getTotalEffect()
	return self.woundEffects:getTotal() + self.treatmentEffects:getTotal()
end

function AntibodiesBodyPart:isKnoxInfected()
	return self.infection[AntibodiesEnum.BodyPart.Infection.KNOX_SCRATCH]
		or self.infection[AntibodiesEnum.BodyPart.Infection.KNOX_CUT]
		or self.infection[AntibodiesEnum.BodyPart.Infection.KNOX_BITE]
end

function AntibodiesBodyPart:setTreatmentSkill(treatmentId, skill)
	self.treatmentSkill[treatmentId] = AntibodiesUtils.clamp(tonumber(skill) or 0, 0, 10)
end

function AntibodiesBodyPart:getTreatmentSkill(treatmentId)
	return self.treatmentSkill[treatmentId] or 0
end

function AntibodiesBodyPart:toString()
	return self.__name .. self:__tostring()
end

function AntibodiesBodyPart:__tostring()
	return (
		"{ "
		.. "id="
		.. tostring(self.id)
		.. " "
		.. "woundEffects="
		.. tostring(self.woundEffects)
		.. " "
		.. "treatmentEffects="
		.. tostring(self.treatmentEffects)
		.. " "
		.. "infectionEffects="
		.. tostring(self.infectionEffects)
		.. " "
		.. "hygieneEffects="
		.. tostring(self.hygieneEffects)
		.. " }"
	)
end

return AntibodiesBodyPart
