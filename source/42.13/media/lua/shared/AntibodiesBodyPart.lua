local AntibodiesEnum = require("AntibodiesEnum")
local AntibodiesUtils = require("AntibodiesUtils")
local AntibodiesEffects = require("AntibodiesEffects")

local AntibodiesBodyPart = {}
AntibodiesBodyPart.__index = AntibodiesBodyPart
AntibodiesBodyPart.__name = "AntibodiesBodyPart"

function AntibodiesBodyPart.new(bodyPart)
	local instance = setmetatable({}, AntibodiesBodyPart)
	instance.type = bodyPart:getType()
	instance.id = instance.type:index()

	instance.treatmentSkill = {}
	for _, key in ipairs(AntibodiesEnum.BodyPart.Treatment.list()) do
		instance.treatmentSkill[key] = 0
	end

	instance.bodyBlood = 0
	instance.bodyDirt = 0

	instance.clothingBlood = 0
	instance.clothingDirt = 0
	instance.clothingPieces = 0

	instance.woundEffects = AntibodiesEffects.new()
	instance.treatmentEffects = AntibodiesEffects.new()
	instance.infectionEffects = AntibodiesEffects.new()
	instance.hygieneEffects = AntibodiesEffects.new()

	instance:update(bodyPart, nil)
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

function AntibodiesBodyPart:update(bodyPart, config)
	self:probeBodyPart(bodyPart)
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

function AntibodiesBodyPart:probeBodyPart(bodyPart)
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

	local parentChar = bodyPart:getParentChar()
	local humanVisual = parentChar:getHumanVisual()
	local bloodBodyPart = BloodBodyPartType.FromIndex(bodyPart:getType():index())

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
	if not config then
		return self
	end

	for _, key in ipairs(AntibodiesEnum.BodyPart.Wound.list()) do
		local wound_val = 0
		local hygiene_val = 0
		if self.wound[key] then
			wound_val = config[AntibodiesEnum.Config.WOUND][key]
			if not self.treatment[AntibodiesEnum.BodyPart.Treatment.BANDAGED] then
				local blood = math.max(self.bodyBlood, self.clothingBlood)
				local dirt = math.max(self.bodyDirt, self.clothingDirt)

				local blood_effect = config[AntibodiesEnum.Config.HYGIENE][AntibodiesEnum.Config.Hygiene.BLOOD_EFFECT]
				local dirt_effect = config[AntibodiesEnum.Config.HYGIENE][AntibodiesEnum.Config.Hygiene.DIRT_EFFECT]

				local wound_mod = config[AntibodiesEnum.Config.HYGIENE_WOUND_MOD][key] or 0
				hygiene_val = hygiene_val + (wound_mod * blood * -blood_effect)
				hygiene_val = hygiene_val + (wound_mod * dirt * -dirt_effect)

				local treament_mod = config[AntibodiesEnum.Config.HYGIENE_TREATMENT_MOD][key] or 0
				hygiene_val = hygiene_val + (treament_mod * blood * -blood_effect)
				hygiene_val = hygiene_val + (treament_mod * dirt * -dirt_effect)
			end
			hygiene_val = math.min(0, hygiene_val)
		end
		self.woundEffects:set(key, wound_val)
		self.hygieneEffects:set(key, hygiene_val)
	end

	for _, key in ipairs(AntibodiesEnum.BodyPart.Treatment.list()) do
		local val = 0
		if self.treatment[key] then
			val = config[AntibodiesEnum.Config.TREATMENT][key]
		end
		self.treatmentEffects:set(key, val)
	end

	for _, key in ipairs(AntibodiesEnum.BodyPart.Infection.list()) do
		local val = 0
		if self.infection[key] then
			val = config[AntibodiesEnum.Config.INFECTION][key]
		end
		self.infectionEffects:set(key, val)
	end

	return self
end

function AntibodiesBodyPart:getEffect()
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
	if self.treatmentSkill[treatmentId] then
		return self.treatmentSkill[treatmentId]
	end
	return 0
end

function AntibodiesBodyPart:toString()
	return self.__name .. self:__tostring()
end

function AntibodiesBodyPart:__tostring()
	return (
		"{ "
		.. "type="
		.. tostring(self.type)
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
