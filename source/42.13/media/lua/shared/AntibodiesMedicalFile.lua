local AntibodiesCondition = require("AntibodiesCondition")
local AntibodiesBody = require("AntibodiesBody")
local AntibodiesUtils = require("AntibodiesUtils")

local AntibodiesMedicalFile = {}
AntibodiesMedicalFile.__index = AntibodiesMedicalFile

function AntibodiesMedicalFile.new(player)
	local instance = setmetatable({}, AntibodiesMedicalFile)

	instance.userName = player:getUsername()
	instance.timestamp = os.time()

	instance.knoxAntibodiesLevel = 0
	instance.knoxInfectionsSurvived = 0
	instance.hoursSurvived = player:getHoursSurvived()

	instance.knoxInfectionLevel = AntibodiesMedicalFile.getKnoxInfectionLevel(player)
	instance.knoxInfectionDelta = AntibodiesMedicalFile.getKnoxInfectionDelta(player)
	instance.knoxActivationCurve = AntibodiesMedicalFile.getActivationCurve(instance.knoxInfectionLevel)
	instance.knoxAntibodiesDelta = instance:getKnoxAntibodiesDelta()

	instance.condition = AntibodiesCondition.new(player)
	instance.body = AntibodiesBody.new(player)

	return instance
end

function AntibodiesMedicalFile.of(player, forceNew)
	local data = player:getModData()
	local mf = data.antibodiesMedicalFile
	if not mf or forceNew then
		mf = AntibodiesMedicalFile.new(player)
	elseif getmetatable(mf) ~= AntibodiesMedicalFile then
		AntibodiesMedicalFile.rehydrate(mf)
	end
	return mf
end

function AntibodiesMedicalFile.fromData(data)
	return AntibodiesMedicalFile.rehydrate(AntibodiesUtils.deepCopy(data))
end

function AntibodiesMedicalFile.rehydrate(medicalFile)
	if getmetatable(medicalFile) ~= AntibodiesMedicalFile then
		setmetatable(medicalFile, AntibodiesMedicalFile)
		AntibodiesCondition.rehydrate(medicalFile.condition)
		AntibodiesBody.rehydrate(medicalFile.body)
		return medicalFile
	end
end

function AntibodiesMedicalFile:clone()
	return AntibodiesMedicalFile.rehydrate(AntibodiesUtils.deepCopy(self))
end

function AntibodiesMedicalFile:update(player, config)
	self.condition:update(player, config)
	self.body:update(player, config)
	return self
end

function AntibodiesMedicalFile:__tostring()
	return string.format(
		"AntibodiesMedicalFile(userName=%s, knoxAntibodiesLevel=%d, knoxInfectionLevel=%d)",
		self.userName,
		self.knoxAntibodiesLevel,
		self.knoxInfectionLevel
	)
end

--[[

	local save = player:getModData()
	instance.knoxAntibodiesLevel = 0
	instance.knoxInfectionsSurvived = 0
	if AntibodiesUtils.is_table(save.medicalFile) then
		if AntibodiesUtils.is_number(save.medicalFile.knoxAntibodiesLevel) then
			instance.knoxAntibodiesLevel = save.medicalFile.knoxAntibodiesLevel
		end
		if AntibodiesUtils.is_number(save.medicalFile.knoxInfectionsSurvived) then
			instance.knoxInfectionsSurvived = save.medicalFile.knoxInfectionsSurvived
		end
	end

	--result["parts_effects"] = getPartsEffects(result)
	--result["effects"] = getEffects(result)
	--result["activationCurve"] = getActivationCurve(result["knoxInfectionLevel"])
	--result["knoxAntibodiesDelta"] = getKnoxAntibodiesDelta(result)
	--result["knoxInfectionStage"] = getKnoxInfectionStage(player)
	--result["parts_effects"] = getPartsEffects(result)
	--result["effects"] = getEffects(result)
	--result["activationCurve"] = getActivationCurve(result["knoxInfectionLevel"])
	--result["knoxAntibodiesDelta"] = getKnoxAntibodiesDelta(result)
	--result["timestamp"] = os.time()

]]

function AntibodiesMedicalFile.getKnoxInfectionLevel(character)
	local bodyDamage = character:getBodyDamage()
	if not bodyDamage:isInfected() then
		return 0.0
	end
	local startTime = bodyDamage:getInfectionTime()
	local duration = bodyDamage:getInfectionMortalityDuration()
	local currentTime
	if instanceof(character, "IsoPlayer") then
		currentTime = character:getHoursSurvived()
	else
		currentTime = GameTime:getInstance():getWorldAgeHours()
	end
	local elapsed = currentTime - startTime
	local level = elapsed / duration
	return math.max(0, math.min(1, level))
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
				return Antibodies.InfectionStage.Decline
			end
			if knoxInfectionLevel < 50 then
				return Antibodies.InfectionStage.Convalescence
			end
		end
		if knoxInfectionLevel < 25 then
			return Antibodies.InfectionStage.Incubation
		end
		if knoxInfectionLevel > 25 and knoxInfectionLevel < 50 then
			return Antibodies.InfectionStage.Prodromal
		end
		if knoxInfectionLevel > 50 and knoxInfectionLevel < 75 then
			return Antibodies.InfectionStage.Illness
		end
		if knoxInfectionLevel > 75 then
			return Antibodies.InfectionStage.Terminal
		end
	end
	return Antibodies.InfectionStage.None
end

function AntibodiesMedicalFile:getKnoxAntibodiesDelta()
	--[[
	local effectSum = Antibodies.currentOptions.general.baseAntibodyGrowth
	for effect_key in pairs(medicalFile.effects) do
		effectSum = effectSum + medicalFile.effects[effect_key]
	end
	effectSum = effectSum * 0.01
	return applyActivationCurve(
		alignWithInfectionDelta(effectSum, medicalFile.knoxInfectionDelta),
		medicalFile.knoxInfectionLevel,
		medicalFile.activationCurve
	)]]
	return 0
end

function AntibodiesMedicalFile.getActivationCurve(infectionLevel)
	return AntibodiesUtils.clamp(math.sin((infectionLevel / 100) * math.pi), 0.0, 1.0)
end

return AntibodiesMedicalFile
