local Antibodies = require("antibodies")
local AntibodiesCondition = require("antibodies_condition")
local AntibodiesBody = require("antibodies_body")
local AntibodiesUtils = require("antibodies_utils")
local AntibodiesEnum = require("antibodies_enum")
local AntibodiesEffects = require("antibodies_effects")

local AntibodiesMedicalFile = {}
AntibodiesMedicalFile.__index = AntibodiesMedicalFile
AntibodiesMedicalFile.__name = "AntibodiesMedicalFile"

function AntibodiesMedicalFile:new(player)
	local instance = setmetatable({}, self)

	instance.userName = player:getUsername()
	instance.timestamp = os.time()
	instance.version = Antibodies.info.version

	instance.knoxAntibodiesLevel = 0
	instance.knoxAntibodiesDelta = 0
	instance.knoxInfectionsSurvived = 0
	instance.knoxAntibodiesLevel = 0
	instance.knoxInfectionDelta = 0

	instance.recoveryEffect = 0
	instance.mutationEffect = 0

	instance.adaptiveEffects = AntibodiesEffects:new()
	instance.condition = AntibodiesCondition:new(player)
	instance.body = AntibodiesBody:new(player)

	instance:update(player, 0, nil)

	return instance
end

function AntibodiesMedicalFile.of(player, forceNew)
	local md = Antibodies.getNamespacedModData(player)
	if not md.medicalFile or forceNew then
		md.medicalFile = AntibodiesMedicalFile:new(player)
	elseif getmetatable(md.medicalFile) ~= AntibodiesMedicalFile then
		AntibodiesMedicalFile.rehydrate(md.medicalFile)
	end
	return md.medicalFile
end

function AntibodiesMedicalFile.migrateData(medicalFile)
	--todo: no migrations needed at this moment
	medicalFile.version = Antibodies.info.version
	return medicalFile
end

function AntibodiesMedicalFile.rehydrate(medicalFile)
	medicalFile = AntibodiesMedicalFile.migrateData(medicalFile)
	if not medicalFile then
		return nil
	end
	if getmetatable(medicalFile) ~= AntibodiesMedicalFile then
		setmetatable(medicalFile, AntibodiesMedicalFile)
		AntibodiesCondition.rehydrate(medicalFile.condition)
		AntibodiesBody.rehydrate(medicalFile.body)
		return medicalFile
	end
	return medicalFile
end

function AntibodiesMedicalFile.fromData(data)
	return AntibodiesMedicalFile.rehydrate(AntibodiesUtils.deepCopy(data))
end

function AntibodiesMedicalFile:clone()
	return AntibodiesMedicalFile.rehydrate(AntibodiesUtils.deepCopy(self))
end

function AntibodiesMedicalFile:update(player, minutesElapsed, config)
	self.timestamp = os.time()

	self.condition:update(player, config)
	self.body:update(player, config)

	self:updateAdaptiveEffects(config)
	self:updateKnoxInfection(player)

	if self.knoxInfectionStage == AntibodiesEnum.InfectionStage.NONE then
		self:cureKnoxVirus(player)
		self.knoxAntibodiesLevel = 0
	else
		self.knoxAntibodiesDelta = self:getKnoxAntibodiesDelta(config, minutesElapsed)
		self.knoxAntibodiesLevel = self.knoxAntibodiesLevel + self.knoxAntibodiesDelta
		if self:consumeKnoxInfection(player) then
			self:cureKnoxVirus(player)
			self.knoxAntibodiesLevel = 0
			self.knoxInfectionsSurvived = self.knoxInfectionsSurvived + 1
		end
	end

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
	self.knoxInfectionLevel = self:getKnoxInfectionLevel(player)
	self.knoxInfectionDelta = self:getKnoxInfectionDelta(player)
	self.knoxActivationCurve = self:getActivationCurve()
	self.knoxInfectionStage = self:getKnoxInfectionStage()
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

function AntibodiesMedicalFile:getKnoxInfectionLevel(character)
	local bodyDamage = character:getBodyDamage()
	if bodyDamage:isInfected() or self.body:isKnoxInfected() then
		local startTime = bodyDamage:getInfectionTime()
		local duration = bodyDamage:getInfectionMortalityDuration()
		local elapsed = self.hoursSurvived - startTime
		local level = (elapsed / duration) * 100
		return math.max(0.001, math.min(100, level))
	end
	return 0.0
end

function AntibodiesMedicalFile:getKnoxInfectionDelta(player, minutesElapsed)
	local bodyDamage = player:getBodyDamage()
	local infectionDuration = bodyDamage:getInfectionMortalityDuration()
	if infectionDuration > 0 then
		local perMinute = (100 / infectionDuration) / 60
		return perMinute
	end
	return 0
end

function AntibodiesMedicalFile:getKnoxInfectionStage()
	if self.knoxInfectionLevel > 0 then
		if self.knoxAntibodiesLevel > self.knoxInfectionLevel then
			if self.knoxInfectionLevel > 50 then
				return AntibodiesEnum.InfectionStage.DECLINE
			end
			if self.knoxInfectionLevel < 50 then
				return AntibodiesEnum.InfectionStage.CONVALESCENCE
			end
		end
		if self.knoxInfectionLevel < 25 then
			return AntibodiesEnum.InfectionStage.INCUBATION
		end
		if self.knoxInfectionLevel >= 25 and self.knoxInfectionLevel < 50 then
			return AntibodiesEnum.InfectionStage.PRODROMAL
		end
		if self.knoxInfectionLevel >= 50 and self.knoxInfectionLevel < 75 then
			return AntibodiesEnum.InfectionStage.ILLNESS
		end
		if self.knoxInfectionLevel >= 75 then
			return AntibodiesEnum.InfectionStage.TERMINAL
		end
	end
	return AntibodiesEnum.InfectionStage.NONE
end

function AntibodiesMedicalFile:getKnoxAntibodiesDelta(config, minutesElapsed)
	if not config then
		return 0.0
	end
	local effectSum = config[AntibodiesEnum.Config.GENERAL][AntibodiesEnum.Config.General.BASE_GROWTH]
	effectSum = effectSum + self.condition:getTotalEffect()
	effectSum = effectSum + self.body:getTotalEffect()
	effectSum = effectSum + self.recoveryEffect
	effectSum = effectSum + self.mutationEffect
	effectSum = effectSum * 0.01
	local antibodiesGrowth = math.max(0, math.abs(self.knoxInfectionDelta) * effectSum * minutesElapsed)
	return AntibodiesUtils.lerp(0.0, antibodiesGrowth, self.knoxActivationCurve)
end

function AntibodiesMedicalFile:getActivationCurve()
	return AntibodiesUtils.clamp(math.sin((self.knoxInfectionLevel / 100) * math.pi), 0.0, 1.0)
end

function AntibodiesMedicalFile:consumeKnoxInfection(player)
	local difference = self.knoxAntibodiesLevel - self.knoxInfectionLevel

	if difference <= 0 then
		return false
	end

	local bodyDamage = player:getBodyDamage()
	local infectionTime = bodyDamage:getInfectionTime()
	local infectionDuration = bodyDamage:getInfectionMortalityDuration()

	local healStep = self.knoxInfectionDelta + difference
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
		"{ userName=%s, version=%s, knoxAntibodiesLevel=%.2f, knoxInfectionLevel=%.2f, knoxInfectionStage=%s }",
		self.userName,
		self.version,
		self.knoxAntibodiesLevel,
		self.knoxInfectionLevel,
		getText("UI_Antibodies_Infection_Stage_" .. tostring(self.knoxInfectionStage))
	)
end

return AntibodiesMedicalFile
