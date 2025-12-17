AntibodiesCondition = {}
AntibodiesCondition.__index = AntibodiesCondition

local Enum = AntibodiesEnum.create_enum()

Enum.define("THIRST")
Enum.define("INTOXICATION")
Enum.define("HUNGER")
Enum.define("WEIGHT")

Enum.define("CALORIES")
Enum.define("CARBOHYDRATES")
Enum.define("LIPIDS")
Enum.define("PROTEINS")

Enum.define("SICKNESS")
Enum.define("FOOD_SICKNESS")

Enum.define("FITNESS")
Enum.define("STRENGTH")
Enum.define("FATIGUE")

Enum.define("ENDURANCE")
Enum.define("TEMPERATURE")

Enum.define("PAIN")
Enum.define("STRESS")
Enum.define("UNHAPPINESS")
Enum.define("BOREDOM")
Enum.define("PANIC")

Enum.define("SANITY")
Enum.define("ANGER")
Enum.define("FEAR")

AntibodiesCondition.Enum = Enum

function AntibodiesCondition:new(id, min, max, curve)
	local instance = {}
	setmetatable(instance, AntibodiesCondition)
	instance.id = id
	instance.min = min
	instance.max = max
	instance.curve = curve
	instance.raw = nil
	instance.computed = nil
	return instance
end

function AntibodiesCondition:get_id()
	return self.id
end

function AntibodiesCondition:set_raw(raw)
	self.raw = AntibodiesUtils.clamp(raw, self.min, self.max)
	self.computed = AntibodiesUtils.lagrange(self.curve, self.raw)
	return self.raw
end

function AntibodiesCondition:get_raw()
	return self.raw
end

function AntibodiesCondition:get_computed()
	return self.computed
end
