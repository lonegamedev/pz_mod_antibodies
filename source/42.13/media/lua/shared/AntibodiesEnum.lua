AntibodiesEnum = {}
AntibodiesEnum.__index = AntibodiesEnum

local function createEnum()
	local enum = {}
	local enumList = {}
	function enum.define(name)
		local value = string.lower(name)
		enum[name] = value
		table.insert(enumList, value)
		return value
	end
	function enum.list()
		return enumList
	end
	return enum
end

AntibodiesEnum.create_enum = createEnum

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

local Condition = createEnum()

Condition.define("THIRST")
Condition.define("INTOXICATION")
Condition.define("HUNGER")
Condition.define("WEIGHT")

Condition.define("CALORIES")
Condition.define("CARBOHYDRATES")
Condition.define("LIPIDS")
Condition.define("PROTEINS")

Condition.define("SICKNESS")
Condition.define("FOOD_SICKNESS")

Condition.define("FITNESS")
Condition.define("STRENGTH")
Condition.define("FATIGUE")

Condition.define("ENDURANCE")
Condition.define("TEMPERATURE")

Condition.define("PAIN")
Condition.define("STRESS")
Condition.define("UNHAPPINESS")
Condition.define("BOREDOM")
Condition.define("PANIC")

Condition.define("SANITY")
Condition.define("ANGER")
Condition.define("FEAR")

AntibodiesEnum.Condition = Condition

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
