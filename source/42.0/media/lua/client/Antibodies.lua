Antibodies = {}
Antibodies.__index = Antibodies

require("AntibodiesOptions")
require("AntibodiesUtils")
require("AntibodiesShared")

-----------------------------------------------------
--CONSTS---------------------------------------------
-----------------------------------------------------

Antibodies.info = {
	["version"] = AntibodiesShared.info.version,
	["optionsVersion"] = AntibodiesShared.info.optionsVersion,
	["author"] = AntibodiesShared.info.author,
	["modName"] = AntibodiesShared.info.modName,
	["modId"] = AntibodiesShared.info.modId,
	["modWorkshopId"] = AntibodiesShared.info.modWorkshopId,
}

Antibodies.InfectionStage = {
	["None"] = 0,
	["Incubation"] = 1,
	["Prodromal"] = 2,
	["Illness"] = 3,
	["Terminal"] = 4,
	["Decline"] = 5,
	["Convalescence"] = 6,
}

Antibodies.WoundTreatmentMods = {
	"bandaged",
	"cleanBandage",
	"sterilizedBandage",
	"sterilizedWound",
	"plantain",
	"garlic",
	"comfrey",
}

Antibodies.WoundTreatmentBase = {
	"deepWounded",
	"bleeding",
	"bitten",
	"cut",
	"scratched",
	"burnt",
	"needBurnWash",
	"haveBullet",
	"haveGlass",
}

Antibodies.HygieneMods = {
	"bandaged",
	"cleanBandage",
	"sterilizedBandage",
	"sterilizedWound",
	"garlic",
	"plantain",
	"comfrey",
	"deepWounded",
	"bleeding",
	"bitten",
	"cut",
	"scratched",
	"burnt",
	"needBurnWash",
	"stiched",
	"haveBullet",
	"haveGlass",
}

-----------------------------------------------------
--OPTIONS--------------------------------------------
-----------------------------------------------------

local function hasOptions()
	return Antibodies.currentOptions ~= nil
end

local function hasCurves()
	return Antibodies.currentCurves ~= nil
end

local function applyOptions(options)
	if type(options) ~= "table" then
		Antibodies.currentOptions = nil
		return
	end
	Antibodies.currentOptions = AntibodiesUtils.deep_copy(options)
end

local function ensureOptionsInitialization(player)
	if not hasOptions() then
		applyOptions(AntibodiesOptions.getOptions())
	end
	if not hasCurves() then
		Antibodies.currentCurves = AntibodiesOptions.getCurves()
	end
	if Antibodies.timeAccumlator == nil then
		Antibodies.timeAccumlator = 0
	end
end

-----------------------------------------------------
--CORE-----------------------------------------------
-----------------------------------------------------

local function getCustomBodyParts(player)
	local modData = player:getModData()
	if type(modData.bodyParts) ~= "table" then
		modData.bodyParts = {}
	end
	local bodyDamage = player:getBodyDamage()
	for i = 0, bodyDamage:getBodyParts():size() - 1 do
		local bodyPart = bodyDamage:getBodyParts():get(i)
		local bodyPartKey = bodyPart:getType():toString()
		if type(modData.bodyParts[bodyPartKey]) ~= "table" then
			modData.bodyParts[bodyPartKey] = {}
		end
	end
	return modData.bodyParts
end

local function cureKnoxVirus(player)
	local bodyDamage = player:getBodyDamage()
	for i = 0, bodyDamage:getBodyParts():size() - 1 do
		local bodyPart = bodyDamage:getBodyParts():get(i)
		bodyPart:SetInfected(false)
	end
	bodyDamage:setInfected(false)
	bodyDamage:setInfectionLevel(0.0)
	bodyDamage:setInfectionTime(-1.0)
	bodyDamage:setInfectionMortalityDuration(-1.0)
end

local function fixKnoxInstantDeath(player)
	local bodyDamage = player:getBodyDamage()
	bodyDamage:setInfectionTime(-1.0)
	bodyDamage:setInfectionMortalityDuration(-1.0)
end

local function getInfectionsPart(bodyPart)
	local result = {}
	for infection_key in pairs(AntibodiesOptions.defaultOptions.infections) do
		result[infection_key] = false
	end
	result.virus = false
	if bodyPart:isInfectedWound() then
		result.regular = true
	end
	if bodyPart:IsInfected() then
		if bodyPart:getBiteTime() > 0 then
			result.virusBite = true
		end
		if bodyPart:getCutTime() > 0 then
			result.virusCut = true
		end
		if bodyPart:getScratchTime() > 0 then
			result.virusScratch = true
		end
		if result.virusScratch or result.virusCut or result.virusBite then
			result.virus = true
		end
	end
	return result
end

local function getWoundsPart(bodyPart)
	local result = {}
	for wound_key in pairs(AntibodiesOptions.defaultOptions.wounds) do
		result[wound_key] = false
	end
	if bodyPart then
		if bodyPart:getDeepWoundTime() > 0 then
			result.deepWounded = true
		end
		if bodyPart:getBiteTime() > 0 then
			result.bitten = true
		end
		if bodyPart:getCutTime() > 0 then
			result.cut = true
		end
		if bodyPart:getScratchTime() > 0 then
			result.scratched = true
		end
		if bodyPart:getBurnTime() > 0 then
			result.burnt = true
		end
		if bodyPart:isNeedBurnWash() and bodyPart:getBurnTime() > 0 then
			result.needBurnWash = true
		end
		if bodyPart:getStitchTime() > 0 then
			result.stiched = true
		end
		if bodyPart:haveBullet() then
			result.haveBullet = true
		end
		if bodyPart:haveGlass() then
			result.haveGlass = true
		end
		if bodyPart:getAlcoholLevel() > 0 then
			result.sterilizedWound = true
		end
		if bodyPart:getGarlicFactor() > 0 then
			result.garlic = true
		end
		if bodyPart:getPlantainFactor() > 0 then
			result.plantain = true
		end
		if bodyPart:getComfreyFactor() > 0 then
			result.comfrey = true
		end
		if bodyPart:bandaged() and not bodyPart:isBandageDirty() then
			result.bandaged = true
			if AntibodiesUtils.isAlcoholBandage(bodyPart:getBandageType()) then
				result.sterilizedBandage = true
			end
		else
			if bodyPart:getBleedingTime() > 0 then
				result.bleeding = true
			end
		end
	end
	return result
end

local function getTreatmentPart(customBodyPart)
	local result = {}
	if customBodyPart then
		for _, key in ipairs(Antibodies.WoundTreatmentMods) do
			result[key] = AntibodiesUtils.number_or_zero(customBodyPart[key])
				* Antibodies.currentOptions.general.doctorSkillTreatmentMod
		end
	end
	return result
end

local function coversBodyPart(clothing, bloodBodyPart)
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

local function getClothingHygiene(player, bodyPart)
	local bloodBodyPart = BloodBodyPartType.FromString(tostring(bodyPart:getType()))
	local result = {
		["blood"] = 0,
		["dirt"] = 0,
		["pieces"] = 0,
	}
	local wornItems = player:getWornItems()
	if wornItems then
		if wornItems:size() > 0 then
			for index = 0, wornItems:size() - 1 do
				local clothing = wornItems:getItemByIndex(index)
				if clothing ~= nil and clothing:IsClothing() then
					if coversBodyPart(clothing, bloodBodyPart) then
						local visualItem = clothing:getVisual()
						if visualItem ~= nil then
							result.blood = result.blood + visualItem:getBlood(bloodBodyPart)
							result.dirt = result.dirt + visualItem:getDirt(bloodBodyPart)
							result.pieces = result.pieces + 1
						end
					end
				end
			end
		end
	end
	result.blood = math.min(1.0, result.blood)
	result.dirt = math.min(1.0, result.dirt)
	return result
end

local function getHygienePart(player, bodyPart, wounds)
	local result = {
		["blood"] = 0,
		["dirt"] = 0,
		["mod"] = 0,
		["mods"] = {},
		["clothingPieces"] = 0,
		["clothingBlood"] = 0,
		["clothingDirt"] = 0,
		["clothing"] = 0,
		["bodyBlood"] = 0,
		["bodyDirt"] = 0,
		["body"] = 0,
	}
	local bloodBodyPartType = BloodBodyPartType.FromString(bodyPart:getType():toString())
	local humanVisual = player:getHumanVisual()
	local clothing = getClothingHygiene(player, bodyPart)

	result.clothingPieces = clothing.pieces
	result.clothingBlood = clothing.blood
	result.clothingDirt = clothing.dirt
	result.bodyBlood = humanVisual:getBlood(bloodBodyPartType)
	result.bodyDirt = humanVisual:getDirt(bloodBodyPartType)

	result.clothing = math.min(1.0, result.clothingBlood + result.clothingDirt)
	result.body = math.min(1.0, result.bodyBlood + result.bodyDirt)

	result.blood = math.min(1.0, result.clothingBlood + result.bodyBlood)
	result.dirt = math.min(1.0, result.clothingDirt + result.clothingDirt)

	for wound_key in pairs(wounds) do
		if wounds[wound_key] and Antibodies.currentOptions.hygiene[wound_key] then
			local m = Antibodies.currentOptions.hygiene[wound_key]
			if math.abs(m) >= 0.1 then
				result.mods[wound_key] = m
				result.mod = result.mod + m
			end
		end
	end

	return result
end

local function getRawConditions(player)
	local stats = player:getStats()
	local nutrition = player:getNutrition()
	local bodyDamage = player:getBodyDamage()

	return {
		["thirst"] = AntibodiesUtils.clamp(stats:getThirst(), 0, 1),
		["drunkness"] = AntibodiesUtils.clamp(stats:getDrunkenness() / 100, 0, 1),
		["hunger"] = AntibodiesUtils.clamp(stats:getHunger(), 0, 1),
		["weight"] = AntibodiesUtils.clamp(nutrition:getWeight(), 35, 130),

		["carbohydrates"] = AntibodiesUtils.clamp(nutrition:getCarbohydrates(), -500, 1000),
		["lipids"] = AntibodiesUtils.clamp(nutrition:getLipids(), -500, 1000),
		["proteins"] = AntibodiesUtils.clamp(nutrition:getProteins(), -500, 1700),

		["sickness"] = AntibodiesUtils.clamp(stats:getSickness(), 0, 1),
		["foodSickness"] = AntibodiesUtils.clamp(bodyDamage:getFoodSicknessLevel(), 0, 100),

		["fitness"] = AntibodiesUtils.clamp(player:getPerkLevel(Perks.Fitness), 1, 10),
		["strength"] = AntibodiesUtils.clamp(player:getPerkLevel(Perks.Strength), 1, 10),
		["fatigue"] = AntibodiesUtils.clamp(stats:getFatigue(), 0, 1),

		["endurance"] = AntibodiesUtils.clamp(stats:getEndurance(), 0, 1),
		["temperature"] = AntibodiesUtils.clamp(bodyDamage:getTemperature(), 20, 40),

		["pain"] = AntibodiesUtils.clamp(stats:getPain(), 0, 100),
		["stress"] = AntibodiesUtils.clamp(stats:getStress(), 0, 1.5),
		["unhappiness"] = AntibodiesUtils.clamp(bodyDamage:getUnhappynessLevel(), 0, 100),
		["boredom"] = AntibodiesUtils.clamp(stats:getBoredom(), 0, 100),
		["panic"] = AntibodiesUtils.clamp(stats:getPanic(), 0, 100),

		["sanity"] = AntibodiesUtils.clamp(stats:getSanity(), 0, 100),
		["anger"] = AntibodiesUtils.clamp(stats:getAnger(), 0, 100),
		["fear"] = AntibodiesUtils.clamp(stats:getFear(), 0, 100),
	}
end

local function getComputedConditions(rawConditions)
	local result = {}
	for key in pairs(rawConditions) do
		if Antibodies.currentCurves[key] then
			result[key] = AntibodiesUtils.lagrange(Antibodies.currentCurves[key], rawConditions[key])
		else
			result[key] = 0.0
		end
	end
	return result
end

local function getEffectConditions(computed)
	local result = {}
	for key in pairs(computed) do
		local curve = computed[key]
		local mod = Antibodies.currentOptions.condition[key]
		if mod then
			result[key] = (curve * mod)
		end
	end
	return result
end

local function getSortedAndFilteredKeys(effects)
	local keys = {}
	for key, value in pairs(effects) do
		if math.abs(value) >= 0.01 then
			table.insert(keys, key)
		end
	end
	local function compare(a, b)
		return math.abs(effects[a]) > math.abs(effects[b])
	end
	table.sort(keys, compare)
	return keys
end

local function getCondition(player)
	local raw = getRawConditions(player)
	local computed = getComputedConditions(raw)
	local effect = getEffectConditions(computed)
	local sorted_keys = getSortedAndFilteredKeys(effect)
	return {
		["raw"] = raw,
		["computed"] = computed,
		["effect"] = effect,
		["sorted_keys"] = sorted_keys,
	}
end

local function getWounds(parts)
	local result = {}
	for wound_key in pairs(AntibodiesOptions.defaultOptions.wounds) do
		result[wound_key] = 0
	end
	for part_key, part in pairs(parts) do
		local wounds = part.wounds
		for result_key in pairs(result) do
			if wounds[result_key] == true then
				result[result_key] = result[result_key] + 1
			end
		end
	end
	return result
end

local function getInfections(parts)
	local result = {}
	for infection_key in pairs(AntibodiesOptions.defaultOptions.infections) do
		result[infection_key] = 0
	end
	result.virus = 0
	for part_key in pairs(parts) do
		local infections = parts[part_key].infections
		for infection_key in pairs(result) do
			if infections[infection_key] then
				result[infection_key] = result[infection_key] + 1
			end
		end
	end
	return result
end

local function getHygiene(parts)
	local result = {
		["clothing"] = 0,
		["body"] = 0,
		["hasClothes"] = false,
	}
	local totalClothing = 0
	local totalBody = 0
	for part_key, part in pairs(parts) do
		local hygiene = part.hygiene
		if hygiene.clothingPieces > 0 and hygiene.clothing > 0 then
			totalClothing = totalClothing + 1
			result.clothing = result.clothing + hygiene.clothing
		end
		if hygiene.body > 0 then
			totalBody = totalBody + 1
			result.body = result.body + hygiene.body
		end
	end
	if totalClothing > 1 then
		result.clothing = result.clothing / totalClothing
	end
	if totalBody > 1 then
		result.body = result.body / totalBody
	end
	result.hasClothes = totalClothing > 0
	return result
end

local function getStatus(player)
	local bodyDamage = player:getBodyDamage()
	local customBodyParts = getCustomBodyParts(player)
	local result = {
		["parts"] = {},
	}
	for i = 0, bodyDamage:getBodyParts():size() - 1 do
		local bodyPart = bodyDamage:getBodyParts():get(i)
		local bodyPartKey = bodyPart:getType():toString()
		local infections = getInfectionsPart(bodyPart)
		local treatment = getTreatmentPart(customBodyParts[bodyPartKey])
		local wounds = getWoundsPart(bodyPart)
		local hygiene = getHygienePart(player, bodyPart, wounds)
		result.parts[bodyPartKey] = {
			["infections"] = infections,
			["wounds"] = wounds,
			["treatment"] = treatment,
			["hygiene"] = hygiene,
		}
	end
	result.condition = getCondition(player)
	return result
end

local function getKnoxInfectionStage(player)
	local bodyDamage = player:getBodyDamage()
	local isInfected = bodyDamage:IsInfected()
	if isInfected then
		local save = player:getModData()
		local infectionLevel = bodyDamage:getInfectionLevel()
		if AntibodiesUtils.is_table(save.medicalFile) then
			if save.medicalFile.knoxAntibodiesLevel > infectionLevel then
				if infectionLevel > 50 then
					return Antibodies.InfectionStage.Decline
				end
				if infectionLevel < 50 then
					return Antibodies.InfectionStage.Convalescence
				end
			end
		end
		if infectionLevel < 25 then
			return Antibodies.InfectionStage.Incubation
		end
		if infectionLevel > 25 and infectionLevel < 50 then
			return Antibodies.InfectionStage.Prodromal
		end
		if infectionLevel > 50 and infectionLevel < 75 then
			return Antibodies.InfectionStage.Illness
		end
		if infectionLevel > 75 then
			return Antibodies.InfectionStage.Terminal
		end
	end
	return Antibodies.InfectionStage.None
end

local function getKnoxInfectionDelta(player)
	local bodyDamage = player:getBodyDamage()
	local infectionDuration = bodyDamage:getInfectionMortalityDuration()
	if infectionDuration > 0 then
		return (100 / infectionDuration) / 60 --every in-game minute
	end
	return 0
end

local function getKnoxInfectionLevel(player)
	return player:getBodyDamage():getInfectionLevel()
end

local function getActivationCurve(infectionLevel)
	return AntibodiesUtils.clamp(math.sin((infectionLevel / 100) * math.pi), 0.0, 1.0)
end

local function applyActivationCurve(antibodiesGrowth, infectionLevel, activationCurve)
	return AntibodiesUtils.lerp(0.0, antibodiesGrowth, activationCurve)
end

local function alignWithInfectionDelta(effectSum, infectionDelta)
	return math.max(0, math.abs(infectionDelta) * effectSum)
end

local function getKnoxAntibodiesDelta(medicalFile)
	local effectSum = Antibodies.currentOptions.general.baseAntibodyGrowth
	for effect_key in pairs(medicalFile.effects) do
		effectSum = effectSum + medicalFile.effects[effect_key]
	end
	effectSum = effectSum * 0.01
	return applyActivationCurve(
		alignWithInfectionDelta(effectSum, medicalFile.knoxInfectionDelta),
		medicalFile.knoxInfectionLevel,
		medicalFile.activationCurve
	)
end

local function getKnoxRecoveryEffect(medicalFile)
	return AntibodiesUtils.clamp(
		medicalFile.knoxInfectionsSurvived * Antibodies.currentOptions.general.knoxInfectionsSurvivedEffect,
		-Antibodies.currentOptions.general.knoxInfectionsSurvivedThreshold,
		Antibodies.currentOptions.general.knoxInfectionsSurvivedThreshold
	)
end

local function getKnoxMutationEffect(medicalFile)
	local days = 0
	if Antibodies.currentOptions.general.knoxMutationStart == 1 then
		days = getGameTime():getWorldAgeHours() / 24.0
	elseif Antibodies.currentOptions.general.knoxMutationStart == 2 then
		days = medicalFile.hoursSurvived / 24.0
	end
	return AntibodiesUtils.clamp(
		days * Antibodies.currentOptions.general.knoxMutationEffect,
		-Antibodies.currentOptions.general.knoxMutationThreshold,
		Antibodies.currentOptions.general.knoxMutationThreshold
	)
end

local function getWoundsEffect(medicalFile)
	local result = 0.0
	local wounds = medicalFile.parts_effects.wounds
	for _, key in pairs(wounds.sorted_keys) do
		result = result + wounds.values[key]
	end
	return result
end

local function getInfectionsEffect(medicalFile)
	local result = 0.0
	local infections = medicalFile.parts_effects.infections
	for _, key in pairs(infections.sorted_keys) do
		result = result + infections.values[key]
	end
	return result
end

local function getHygieneEffect(medicalFile)
	local result = 0.0
	local hygiene = medicalFile.parts_effects.hygiene
	for _, key in pairs(hygiene.sorted_keys) do
		result = result + hygiene.values[key]
	end
	return result
end

local function getConditionEffect(medicalFile)
	local total = 0.0
	local effect = medicalFile.status.condition.effect
	local sorted_keys = medicalFile.status.condition.sorted_keys
	for _, key in pairs(sorted_keys) do
		total = total + effect[key]
	end
	return total
end

local function getPartsEffects(medicalFile)
	local result = {
		["wounds"] = {
			["values"] = {},
			["sorted_keys"] = {},
		},
		["infections"] = {
			["values"] = {},
			["sorted_keys"] = {},
		},
		["hygiene"] = {
			["values"] = {},
			["sorted_keys"] = {},
		},
	}
	for part_key in pairs(medicalFile.status.parts) do
		local val = 0
		local part_wounds = medicalFile.status.parts[part_key].wounds
		local part_infections = medicalFile.status.parts[part_key].infections
		local part_hygiene = medicalFile.status.parts[part_key].hygiene

		for key in pairs(part_wounds) do
			local treatmentMod = 1
			if AntibodiesUtils.has_value(Antibodies.WoundTreatmentMods, key) then
				treatmentMod = medicalFile.status.parts[part_key].treatment[key]
			end
			val = val
				+ (
					AntibodiesUtils.bool_to_number(part_wounds[key])
					* AntibodiesUtils.number_or_zero(Antibodies.currentOptions.wounds[key])
					* treatmentMod
				)
		end
		if val > 0.0 then
			val = 0.0 --dont provide positive effect
		end
		result.wounds.values[part_key] = val
		val = 0

		for key in pairs(part_infections) do
			val = val
				+ (AntibodiesUtils.bool_to_number(part_infections[key]) * Antibodies.currentOptions.infections[key])
		end
		result.infections.values[part_key] = val
		val = 0

		--negating blood and dirt effect to make options more readable
		local part_blood_effect = (part_hygiene.blood * part_hygiene.mod)
			* -Antibodies.currentOptions.hygiene.bloodEffect
		local part_dirt_effect = (part_hygiene.dirt * part_hygiene.mod) * -Antibodies.currentOptions.hygiene.dirtEffect

		--prevent positive effect
		result.hygiene.values[part_key] = math.min(0.0, part_blood_effect + part_dirt_effect)
	end
	result.wounds.sorted_keys = getSortedAndFilteredKeys(result.wounds.values)
	result.infections.sorted_keys = getSortedAndFilteredKeys(result.infections.values)
	result.hygiene.sorted_keys = getSortedAndFilteredKeys(result.hygiene.values)
	return result
end

local function getEffects(medicalFile)
	local result = {}
	result["knoxRecovery"] = getKnoxRecoveryEffect(medicalFile)
	result["knoxMutation"] = getKnoxMutationEffect(medicalFile)
	result["wounds"] = getWoundsEffect(medicalFile)
	result["infections"] = getInfectionsEffect(medicalFile)
	result["hygiene"] = getHygieneEffect(medicalFile)
	result["condition"] = getConditionEffect(medicalFile)
	return result
end

local function createMedicalFile(player)
	local save = player:getModData()
	local result = {}
	result["userName"] = player:getUsername()
	result["status"] = getStatus(player)
	result["hoursSurvived"] = player:getHoursSurvived()
	result["knoxInfectionLevel"] = getKnoxInfectionLevel(player)
	result["knoxInfectionDelta"] = getKnoxInfectionDelta(player)
	result["knoxAntibodiesLevel"] = 0
	result["knoxInfectionsSurvived"] = 0
	if AntibodiesUtils.is_table(save.medicalFile) then
		if AntibodiesUtils.is_number(save.medicalFile.knoxAntibodiesLevel) then
			result["knoxAntibodiesLevel"] = save.medicalFile.knoxAntibodiesLevel
		end
		if AntibodiesUtils.is_number(save.medicalFile.knoxInfectionsSurvived) then
			result["knoxInfectionsSurvived"] = save.medicalFile.knoxInfectionsSurvived
		end
	end
	result["knoxInfectionStage"] = getKnoxInfectionStage(player)
	result["parts_effects"] = getPartsEffects(result)
	result["effects"] = getEffects(result)
	result["activationCurve"] = getActivationCurve(result["knoxInfectionLevel"])
	result["knoxAntibodiesDelta"] = getKnoxAntibodiesDelta(result)
	result["timestamp"] = os.time()
	return result
end

local function migratePlayerData(save)
	--migrations 1.50 -> 1.60
	if AntibodiesUtils.is_number(save.virusAntibodiesLevel) then
		save.medicalFile.knoxAntibodiesLevel = save.virusAntibodiesLevel
		save.virusAntibodiesLevel = nil
	end
	if AntibodiesUtils.is_number(save.virusInfectionsSurvived) then
		save.medicalFile.knoxInfectionsSurvived = save.virusInfectionsSurvived
		save.virusInfectionsSurvived = nil
	end
end

local function ensurePlayerInitialization(player)
	local save = player:getModData()
	if not AntibodiesUtils.is_table(save.medicalFile) then
		save.medicalFile = createMedicalFile(player)
	end
	migratePlayerData(save)
end

local function consumeKnoxInfection(player, medicalFile)
	local difference = medicalFile.knoxAntibodiesLevel - medicalFile.knoxInfectionLevel

	if difference <= 0 then
		return false
	end

	local infectionDelta = getKnoxInfectionDelta(player)

	local bodyDamage = player:getBodyDamage()
	local infectionTime = bodyDamage:getInfectionTime()
	local infectionDuration = bodyDamage:getInfectionMortalityDuration()
	local healStep = (infectionDelta + difference)

	local newTime = infectionTime + ((healStep / 100) * infectionDuration)
	local newInfection = AntibodiesUtils.clamp(bodyDamage:getInfectionLevel() - healStep, 0, 100)

	bodyDamage:setInfectionTime(newTime)
	bodyDamage:setInfectionLevel(newInfection)

	medicalFile.knoxAntibodiesLevel = AntibodiesUtils.clamp(medicalFile.knoxAntibodiesLevel - difference, 0, 100)

	if newTime >= player:getHoursSurvived() then
		return true --ready to cure
	end

	return false
end

local function updateKnoxAntibodies(player)
	ensurePlayerInitialization(player)
	local save = player:getModData()
	local medicalFile = createMedicalFile(player)

	--[[
	if Antibodies.currentOptions.general.debug then
		print(string.format("%s: %s", Antibodies.info.modId, AntibodiesUtils.tableToJson(medicalFile)))
	end
	]]
	if medicalFile.knoxInfectionStage == Antibodies.InfectionStage.None then
		cureKnoxVirus(player)
		medicalFile.knoxAntibodiesLevel = 0
	else
		medicalFile.knoxAntibodiesLevel = medicalFile.knoxAntibodiesLevel + medicalFile.knoxAntibodiesDelta
		if consumeKnoxInfection(player, medicalFile) then
			cureKnoxVirus(player)
			medicalFile.knoxAntibodiesLevel = 0
			medicalFile.knoxInfectionsSurvived = medicalFile.knoxInfectionsSurvived + 1
		end
	end
	save.medicalFile = medicalFile
end

local function updatePlayers()
	local players = AntibodiesUtils.getLocalPlayers()
	for key, player in ipairs(players) do
		updateKnoxAntibodies(player)
	end
end

local function networkSync(player)
	if isClient() then
		Antibodies.timeAccumlator = Antibodies.timeAccumlator + getGameTime():getInvMultiplier()
		if Antibodies.timeAccumlator >= 1.0 then
			local players = AntibodiesUtils.getLocalPlayers()
			for key, player in ipairs(players) do
				local save = player:getModData()
				sendClientCommand(
					player,
					Antibodies.info.modId,
					AntibodiesShared.networkCommand.shareMedicalFile,
					{ playerOnlineId = player:getOnlineID(), medicalFile = save.medicalFile }
				)
			end
		end
		Antibodies.timeAccumlator = 0.0
	end
end

-----------------------------------------------------
--GLOBALS--------------------------------------------
-----------------------------------------------------

Antibodies.currentOptions = nil
Antibodies.currentCurves = nil
Antibodies.getCustomBodyParts = getCustomBodyParts
Antibodies.maxAbsConditionValue = 1
Antibodies.createMedicalFile = createMedicalFile

-----------------------------------------------------
--CALLBACKS------------------------------------------
-----------------------------------------------------

local function onGameStart()
	applyOptions(nil)
end
Events.OnGameStart.Add(onGameStart)

local function onMainMenuEnter()
	applyOptions(nil)
end
Events.OnMainMenuEnter.Add(onMainMenuEnter)

local function onServerCommand(module, command, arguments)
	if module == Antibodies.info.modId then
		if command == AntibodiesShared.networkCommand.shareMedicalFile then
			local player = getPlayerByOnlineID(arguments.playerOnlineId)
			if player and not player:isLocalPlayer() then
				local modData = player:getModData()
				modData.medicalFile = arguments.medicalFile
			end
		end
	end
end
Events.OnServerCommand.Add(onServerCommand)

local function onEveryOneMinute()
	ensureOptionsInitialization()
	updatePlayers()
	networkSync()
end
Events.EveryOneMinute.Add(onEveryOneMinute)
