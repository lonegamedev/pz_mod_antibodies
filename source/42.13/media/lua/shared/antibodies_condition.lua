local AntibodiesEnum = require("antibodies_enum")
local AntibodiesUtils = require("antibodies_utils")
local AntibodiesEffects = require("antibodies_effects")

local AntibodiesCondition = {}
AntibodiesCondition.__index = AntibodiesCondition
AntibodiesCondition.__name = "AntibodiesCondition"

function AntibodiesCondition:new(player)
	local instance = setmetatable({}, self)
	instance.effects = AntibodiesEffects:new()
	instance:update(player, nil)
	return instance
end

function AntibodiesCondition.rehydrate(condition)
	if getmetatable(condition) ~= AntibodiesCondition then
		setmetatable(condition, AntibodiesCondition)
		AntibodiesEffects.rehydrate(condition.effects)
		return condition
	end
end

function AntibodiesCondition:update(player, config)
	self:probePlayer(player)
	self:calculateEffect(config)
end

function AntibodiesCondition:probePlayer(player)
	local stats = player:getStats()
	local nutrition = player:getNutrition()
	local bodyDamage = player:getBodyDamage()
	local thermoregulator = bodyDamage:getThermoregulator()

	self.raw = {}

	self.raw[AntibodiesEnum.Condition.THIRST] = AntibodiesCondition.getStatNormalized(stats, CharacterStat.THIRST)
	self.raw[AntibodiesEnum.Condition.INTOXICATION] =
		AntibodiesCondition.getStatNormalized(stats, CharacterStat.INTOXICATION)
	self.raw[AntibodiesEnum.Condition.HUNGER] = AntibodiesCondition.getStatNormalized(stats, CharacterStat.HUNGER)
	self.raw[AntibodiesEnum.Condition.WEIGHT] = AntibodiesUtils.clamp(nutrition:getWeight(), 35, 130)

	self.raw[AntibodiesEnum.Condition.CARBOHYDRATES] = AntibodiesUtils.clamp(nutrition:getCarbohydrates(), -500, 1000)
	self.raw[AntibodiesEnum.Condition.LIPIDS] = AntibodiesUtils.clamp(nutrition:getLipids(), -500, 1000)
	self.raw[AntibodiesEnum.Condition.PROTEINS] = AntibodiesUtils.clamp(nutrition:getProteins(), -500, 1700)

	self.raw[AntibodiesEnum.Condition.SICKNESS] =
		AntibodiesUtils.clamp(AntibodiesCondition.getStatNormalized(stats, CharacterStat.SICKNESS), 0, 1)
	self.raw[AntibodiesEnum.Condition.FOOD_SICKNESS] =
		AntibodiesCondition.getStatNormalized(stats, CharacterStat.FOOD_SICKNESS)

	self.raw[AntibodiesEnum.Condition.FITNESS] = AntibodiesUtils.clamp(player:getPerkLevel(Perks.Fitness), 1, 10)
	self.raw[AntibodiesEnum.Condition.STRENGTH] = AntibodiesUtils.clamp(player:getPerkLevel(Perks.Strength), 1, 10)
	self.raw[AntibodiesEnum.Condition.FATIGUE] = AntibodiesCondition.getStatNormalized(stats, CharacterStat.FATIGUE)

	self.raw[AntibodiesEnum.Condition.ENDURANCE] = AntibodiesCondition.getStatNormalized(stats, CharacterStat.ENDURANCE)
	self.raw[AntibodiesEnum.Condition.TEMPERATURE] = AntibodiesUtils.clamp(thermoregulator:getCoreTemperature(), 20, 42)

	self.raw[AntibodiesEnum.Condition.PAIN] = AntibodiesCondition.getStatNormalized(stats, CharacterStat.PAIN)
	self.raw[AntibodiesEnum.Condition.STRESS] = AntibodiesCondition.getStatNormalized(stats, CharacterStat.STRESS)
	self.raw[AntibodiesEnum.Condition.UNHAPPINESS] =
		AntibodiesCondition.getStatNormalized(stats, CharacterStat.UNHAPPINESS)
	self.raw[AntibodiesEnum.Condition.BOREDOM] = AntibodiesCondition.getStatNormalized(stats, CharacterStat.BOREDOM)
	self.raw[AntibodiesEnum.Condition.PANIC] = AntibodiesCondition.getStatNormalized(stats, CharacterStat.PANIC)
	self.raw[AntibodiesEnum.Condition.SANITY] = AntibodiesCondition.getStatNormalized(stats, CharacterStat.SANITY)
	self.raw[AntibodiesEnum.Condition.ANGER] = AntibodiesCondition.getStatNormalized(stats, CharacterStat.ANGER)

	return self
end

function AntibodiesCondition:calculateEffect(config)
	self.effects:clear()
	if not config then
		return self
	end

	local mods = config[AntibodiesEnum.Config.CONDITION]
	local curves = config[AntibodiesEnum.Config.CONDITION_CURVE]

	for _, key in ipairs(AntibodiesEnum.Condition.list()) do
		local value = 0
		if curves[key] then
			value = AntibodiesUtils.lagrange(curves[key], self.raw[key]) * mods[key]
		end
		self.effects:set(key, value)
	end

	return self
end

function AntibodiesCondition:getTotalEffect()
	return self.effects:getTotal()
end

function AntibodiesCondition.getStatNormalized(stats, stat)
	local val = stats:get(stat)
	local min = stat:getMinimumValue()
	local max = stat:getMaximumValue()
	local normalized = (val - min) / (max - min)
	return normalized
end

function AntibodiesCondition:toString()
	return self.__name .. self:__tostring()
end

function AntibodiesCondition:__tostring()
	return "{ effects=" .. self.effects:__tostring() .. "}"
end

return AntibodiesCondition
