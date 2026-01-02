local Antibodies = require("antibodies")
local AntibodiesCondition = require("antibodies_condition")
local AntibodiesBody = require("antibodies_body")
local AntibodiesUtils = require("antibodies_utils")
local AntibodiesEnum = require("antibodies_enum")
local AntibodiesEffects = require("antibodies_effects")

local AntibodiesMedicalFile = {}
AntibodiesMedicalFile.__index = AntibodiesMedicalFile
AntibodiesMedicalFile.__name = "AntibodiesMedicalFile"

function AntibodiesMedicalFile.new(player)
	local instance = setmetatable({}, AntibodiesMedicalFile)

	instance.userName = player:getUsername()
	instance.timestamp = os.time()

	instance.knoxAntibodiesLevel = 0
	instance.knoxInfectionsSurvived = 0

	instance.adaptiveEffects = AntibodiesEffects.new()
	instance.condition = AntibodiesCondition.new(player)
	instance.body = AntibodiesBody.new(player)

	instance:update(player, nil)

	return instance
end

function AntibodiesMedicalFile.of(player, forceNew)
	local md = Antibodies.getNamespacedModData(player)
	if not md.medicalFile or forceNew then
		md.medicalFile = AntibodiesMedicalFile.new(player)
	elseif getmetatable(md.medicalFile) ~= AntibodiesMedicalFile then
		AntibodiesMedicalFile.rehydrate(md.medicalFile)
	end
	return md.medicalFile
end

function AntibodiesMedicalFile.rehydrate(medicalFile)
	if getmetatable(medicalFile) ~= AntibodiesMedicalFile then
		setmetatable(medicalFile, AntibodiesMedicalFile)
		AntibodiesCondition.rehydrate(medicalFile.condition)
		AntibodiesBody.rehydrate(medicalFile.body)
		return medicalFile
	end
end

function AntibodiesMedicalFile.fromData(data)
	return AntibodiesMedicalFile.rehydrate(AntibodiesUtils.deepCopy(data))
end

function AntibodiesMedicalFile:clone()
	return AntibodiesMedicalFile.rehydrate(AntibodiesUtils.deepCopy(self))
end

function AntibodiesMedicalFile:update(player, config)
	self.timestamp = os.time()

	self.condition:update(player, config)
	self.body:update(player, config)

	self:updateAdaptiveEffects(config)
	self:updateKnoxInfection(player)

	if self.knoxInfectionStage == AntibodiesEnum.InfectionStage.NONE then
		self:cureKnoxVirus(player)
		self.knoxAntibodiesLevel = 0
	else
		self.knoxAntibodiesDelta = self:getKnoxAntibodiesDelta(config)
		self.knoxAntibodiesLevel = self.knoxAntibodiesLevel + self.knoxAntibodiesDelta
		if self:consumeKnoxInfection(player) then
			self:cureKnoxVirus(player)
			self.knoxAntibodiesLevel = 0
			self.knoxInfectionsSurvived = self.knoxInfectionsSurvived + 1
		end
	end

	--print(self:toString())
	--print(self.condition:toString())
	--print("HAND_L: ", self.body.bodyParts[AntibodiesEnum.BodyPart.HAND_L])

	return self
end

function AntibodiesMedicalFile:updateAdaptiveEffects(config)
	if config then
		self.recoveryEffect = self:getKnoxRecoveryEffect(config)
		self.mutationEffect = self:getKnoxMutationEffect(config)
	else
		self.recoveryEffect = 0
		self.mutationEffect = 0
	end
end

function AntibodiesMedicalFile:updateKnoxInfection(player)
	if instanceof(player, "IsoPlayer") then
		self.hoursSurvived = player:getHoursSurvived()
	else
		self.hoursSurvived = GameTime:getInstance():getWorldAgeHours()
	end
	self.knoxInfectionLevel = AntibodiesMedicalFile.getKnoxInfectionLevel(player, self.hoursSurvived)
	self.knoxInfectionDelta = AntibodiesMedicalFile.getKnoxInfectionDelta(player)
	self.knoxActivationCurve = AntibodiesMedicalFile.getActivationCurve(self.knoxInfectionLevel)
	self.knoxInfectionStage =
		AntibodiesMedicalFile.getKnoxInfectionStage(self.knoxInfectionLevel, self.knoxAntibodiesLevel)
end

function AntibodiesMedicalFile:getKnoxRecoveryEffect(config)
	if not config then
		return 0.0
	end
	local recoveryEffect = config[AntibodiesEnum.Config.GENERAL][AntibodiesEnum.Config.General.RECOVERY_EFFECT]
	local recoveryThreshold = config[AntibodiesEnum.Config.GENERAL][AntibodiesEnum.Config.General.RECOVERY_THRESHOLD]
	return AntibodiesUtils.clamp(self.knoxInfectionsSurvived * recoveryEffect, -recoveryThreshold, recoveryThreshold)
end

function AntibodiesMedicalFile:getKnoxMutationEffect(config)
	if not config then
		return 0.0
	end
	local days = 0
	local mutationStart = config[AntibodiesEnum.Config.GENERAL][AntibodiesEnum.Config.General.MUTATION_START]
	local mutationThreshold = config[AntibodiesEnum.Config.GENERAL][AntibodiesEnum.Config.General.MUTATION_THRESHOLD]
	local mutationEffect = config[AntibodiesEnum.Config.GENERAL][AntibodiesEnum.Config.General.MUTATION_EFFECT]
	if mutationStart == 1 then
		days = getGameTime():getWorldAgeHours() / 24.0
	elseif mutationStart == 2 then
		days = self.hoursSurvived / 24.0
	end
	return AntibodiesUtils.clamp(days * mutationEffect, -mutationThreshold, mutationThreshold)
end

function AntibodiesMedicalFile.getKnoxInfectionLevel(character, survivedTime)
	local bodyDamage = character:getBodyDamage()
	if not bodyDamage:isInfected() then
		return 0.0
	end
	local startTime = bodyDamage:getInfectionTime()
	local duration = bodyDamage:getInfectionMortalityDuration()
	local elapsed = survivedTime - startTime
	local level = (elapsed / duration) * 100
	return math.max(0, math.min(100, level))
end

function AntibodiesMedicalFile.getKnoxInfectionDelta(player)
	local bodyDamage = player:getBodyDamage()
	local infectionDuration = bodyDamage:getInfectionMortalityDuration()
	if infectionDuration > 0 then
		return (100 / infectionDuration) / 60 --every in-game minute
	end
	return 0
end

function AntibodiesMedicalFile.getKnoxInfectionStage(knoxInfectionLevel, knoxAntibodiesLevel)
	if knoxInfectionLevel > 0 then
		if knoxAntibodiesLevel > knoxInfectionLevel then
			if knoxInfectionLevel > 50 then
				return AntibodiesEnum.InfectionStage.DECLINE
			end
			if knoxInfectionLevel < 50 then
				return AntibodiesEnum.InfectionStage.CONVALESCENCE
			end
		end
		if knoxInfectionLevel < 25 then
			return AntibodiesEnum.InfectionStage.INCUBATION
		end
		if knoxInfectionLevel > 25 and knoxInfectionLevel < 50 then
			return AntibodiesEnum.InfectionStage.PRODROMAL
		end
		if knoxInfectionLevel > 50 and knoxInfectionLevel < 75 then
			return AntibodiesEnum.InfectionStage.ILLNESS
		end
		if knoxInfectionLevel > 75 then
			return AntibodiesEnum.InfectionStage.TERMINAL
		end
	end
	return AntibodiesEnum.InfectionStage.NONE
end

function AntibodiesMedicalFile:getKnoxAntibodiesDelta(config)
	if not config then
		return 0.0
	end
	local effectSum = config[AntibodiesEnum.Config.GENERAL][AntibodiesEnum.Config.General.BASE_GROWTH]
	effectSum = effectSum + self.condition:getTotalEffect()
	effectSum = effectSum + self.body:getTotalEffect()
	effectSum = effectSum + self.recoveryEffect
	effectSum = effectSum + self.mutationEffect
	effectSum = effectSum * 0.01
	local antibodiesGrowth = math.max(0, math.abs(self.knoxInfectionDelta) * effectSum)
	return AntibodiesUtils.lerp(0.0, antibodiesGrowth, self.knoxActivationCurve)
end

function AntibodiesMedicalFile.getActivationCurve(infectionLevel)
	return AntibodiesUtils.clamp(math.sin((infectionLevel / 100) * math.pi), 0.0, 1.0)
end

function AntibodiesMedicalFile:consumeKnoxInfection(player)
	local difference = self.knoxAntibodiesLevel - self.knoxInfectionLevel
	if difference <= 0 then
		return false
	end

	local bodyDamage = player:getBodyDamage()
	local infectionTime = bodyDamage:getInfectionTime()
	local infectionDuration = bodyDamage:getInfectionMortalityDuration()
	local healStep = (self.knoxInfectionDelta + difference) * 2.0

	local newTime = infectionTime + ((healStep / 100) * infectionDuration)
	bodyDamage:setInfectionTime(newTime)
	self.knoxAntibodiesLevel = AntibodiesUtils.clamp(self.knoxAntibodiesLevel - difference, 0, 100)

	if newTime >= player:getHoursSurvived() then
		return true --ready to cure
	end

	return false
end

function AntibodiesMedicalFile:cureKnoxVirus(player)
	local bodyDamage = player:getBodyDamage()
	for i = 0, bodyDamage:getBodyParts():size() - 1 do
		local bodyPart = bodyDamage:getBodyParts():get(i)
		bodyPart:SetInfected(false)
	end
	bodyDamage:setInfected(false)
	bodyDamage:setInfectionTime(-1.0)
	bodyDamage:setInfectionMortalityDuration(-1.0)
end

function AntibodiesMedicalFile:toString()
	return self.__name .. self:__tostring()
end

function AntibodiesMedicalFile:__tostring()
	return string.format(
		"{ userName=%s, knoxAntibodiesLevel=%.2f, knoxInfectionLevel=%.2f, knoxInfectionStage=%s }",
		self.userName,
		self.knoxAntibodiesLevel,
		self.knoxInfectionLevel,
		getText("UI_Antibodies_Infection_Stage_" .. tostring(self.knoxInfectionStage))
	)
end

return AntibodiesMedicalFile
