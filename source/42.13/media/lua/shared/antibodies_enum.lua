local AntibodiesEnum = {}

function AntibodiesEnum.createEnum()
	local enum = {}
	local enumList = {}

	function enum.define(name, value)
		if value == nil then
			value = name
		elseif type(value) == "function" then
			value = value(name)
		end
		enum[name] = value
		table.insert(enumList, value)
		return value
	end

	function enum.list()
		return enumList
	end

	return enum
end

AntibodiesEnum.Network = AntibodiesEnum.createEnum()
AntibodiesEnum.Network.define("REQUEST_MEDICAL_FILE", "requestMedicalFile")
AntibodiesEnum.Network.define("SHARE_MEDICAL_FILE", "shareMedicalFile")

AntibodiesEnum.InfectionStage = AntibodiesEnum.createEnum()
AntibodiesEnum.InfectionStage.define("NONE", 0)
AntibodiesEnum.InfectionStage.define("INCUBATION", 1)
AntibodiesEnum.InfectionStage.define("PRODROMAL", 2)
AntibodiesEnum.InfectionStage.define("ILLNESS", 3)
AntibodiesEnum.InfectionStage.define("TERMINAL", 4)
AntibodiesEnum.InfectionStage.define("DECLINE", 5)
AntibodiesEnum.InfectionStage.define("CONVALESCENCE", 6)

AntibodiesEnum.Config = AntibodiesEnum.createEnum()
AntibodiesEnum.Config.define("GENERAL", string.lower)
AntibodiesEnum.Config.define("CONDITION", string.lower)
AntibodiesEnum.Config.define("CONDITION_CURVE", string.lower)
AntibodiesEnum.Config.define("WOUND", string.lower)
AntibodiesEnum.Config.define("TREATMENT", string.lower)
AntibodiesEnum.Config.define("WOUND_AND_TREATMENT", string.lower)
AntibodiesEnum.Config.define("INFECTION", string.lower)
AntibodiesEnum.Config.define("HYGIENE", string.lower)
AntibodiesEnum.Config.define("HYGIENE_WOUND_MOD", string.lower)
AntibodiesEnum.Config.define("HYGIENE_TREATMENT_MOD", string.lower)

AntibodiesEnum.Config.General = AntibodiesEnum.createEnum()
AntibodiesEnum.Config.General.define("BASE_GROWTH", string.lower)
AntibodiesEnum.Config.General.define("RECOVERY_EFFECT", string.lower)
AntibodiesEnum.Config.General.define("RECOVERY_THRESHOLD", string.lower)
AntibodiesEnum.Config.General.define("MUTATION_EFFECT", string.lower)
AntibodiesEnum.Config.General.define("MUTATION_THRESHOLD", string.lower)
AntibodiesEnum.Config.General.define("MUTATION_START", string.lower)
AntibodiesEnum.Config.General.define("HYGIENE_PANEL_ENABLED", string.lower)
AntibodiesEnum.Config.General.define("DIAGNOSE_ENABLED", string.lower)
AntibodiesEnum.Config.General.define("DIAGNOSE_SKILL_NEEDED", string.lower)
AntibodiesEnum.Config.General.define("DOCTOR_SKILL_TREATMENT_MOD", string.lower)
AntibodiesEnum.Config.General.define("DEBUG", string.lower)

AntibodiesEnum.Config.Hygiene = AntibodiesEnum.createEnum()
AntibodiesEnum.Config.Hygiene.define("BLOOD_EFFECT", string.lower)
AntibodiesEnum.Config.Hygiene.define("DIRT_EFFECT", string.lower)

AntibodiesEnum.Condition = AntibodiesEnum.createEnum()
AntibodiesEnum.Condition.define("FITNESS", string.lower)
AntibodiesEnum.Condition.define("STRENGTH", string.lower)
AntibodiesEnum.Condition.define("FATIGUE", string.lower)
AntibodiesEnum.Condition.define("ENDURANCE", string.lower)
AntibodiesEnum.Condition.define("WEIGHT", string.lower)
AntibodiesEnum.Condition.define("CALORIES", string.lower)
AntibodiesEnum.Condition.define("CARBOHYDRATES", string.lower)
AntibodiesEnum.Condition.define("LIPIDS", string.lower)
AntibodiesEnum.Condition.define("PROTEINS", string.lower)
AntibodiesEnum.Condition.define("HUNGER", string.lower)
AntibodiesEnum.Condition.define("THIRST", string.lower)
AntibodiesEnum.Condition.define("INTOXICATION", string.lower)
AntibodiesEnum.Condition.define("SICKNESS", string.lower)
AntibodiesEnum.Condition.define("FOOD_SICKNESS", string.lower)
AntibodiesEnum.Condition.define("TEMPERATURE", string.lower)
AntibodiesEnum.Condition.define("PAIN", string.lower)
AntibodiesEnum.Condition.define("STRESS", string.lower)
AntibodiesEnum.Condition.define("UNHAPPINESS", string.lower)
AntibodiesEnum.Condition.define("BOREDOM", string.lower)
AntibodiesEnum.Condition.define("PANIC", string.lower)
AntibodiesEnum.Condition.define("SANITY", string.lower)
AntibodiesEnum.Condition.define("ANGER", string.lower)

AntibodiesEnum.BodyPart = AntibodiesEnum.createEnum()
AntibodiesEnum.BodyPart.define("HAND_L", string.lower)
AntibodiesEnum.BodyPart.define("HAND_R", string.lower)
AntibodiesEnum.BodyPart.define("FOREARM_L", string.lower)
AntibodiesEnum.BodyPart.define("FOREARM_R", string.lower)
AntibodiesEnum.BodyPart.define("UPPERARM_L", string.lower)
AntibodiesEnum.BodyPart.define("UPPERARM_R", string.lower)
AntibodiesEnum.BodyPart.define("TORSO_UPPER", string.lower)
AntibodiesEnum.BodyPart.define("TORSO_LOWER", string.lower)
AntibodiesEnum.BodyPart.define("HEAD", string.lower)
AntibodiesEnum.BodyPart.define("NECK", string.lower)
AntibodiesEnum.BodyPart.define("GROIN", string.lower)
AntibodiesEnum.BodyPart.define("UPPERLEG_L", string.lower)
AntibodiesEnum.BodyPart.define("UPPERLEG_R", string.lower)
AntibodiesEnum.BodyPart.define("LOWERLEG_L", string.lower)
AntibodiesEnum.BodyPart.define("LOWERLEG_R", string.lower)
AntibodiesEnum.BodyPart.define("FOOT_L", string.lower)
AntibodiesEnum.BodyPart.define("FOOT_R", string.lower)
function AntibodiesEnum.BodyPart.toIndex(enumValue)
	for i, value in ipairs(AntibodiesEnum.BodyPart.list()) do
		if value == enumValue then
			return i - 1
		end
	end
	return nil
end
function AntibodiesEnum.BodyPart.fromIndex(index)
	return AntibodiesEnum.BodyPart.list()[index + 1]
end

AntibodiesEnum.BodyPart.Wound = AntibodiesEnum.createEnum()
AntibodiesEnum.BodyPart.Wound.define("DEEP_WOUNDED", string.lower)
AntibodiesEnum.BodyPart.Wound.define("BLEEDING", string.lower)
AntibodiesEnum.BodyPart.Wound.define("BITTEN", string.lower)
AntibodiesEnum.BodyPart.Wound.define("CUT", string.lower)
AntibodiesEnum.BodyPart.Wound.define("SCRATCHED", string.lower)
AntibodiesEnum.BodyPart.Wound.define("BURNT", string.lower)
AntibodiesEnum.BodyPart.Wound.define("NEED_BURN_WASH", string.lower)
AntibodiesEnum.BodyPart.Wound.define("STICHED", string.lower)
AntibodiesEnum.BodyPart.Wound.define("HAVE_BULLET", string.lower)
AntibodiesEnum.BodyPart.Wound.define("HAVE_GLASS", string.lower)

AntibodiesEnum.BodyPart.Infection = AntibodiesEnum.createEnum()
AntibodiesEnum.BodyPart.Infection.define("KNOX_BITE", string.lower)
AntibodiesEnum.BodyPart.Infection.define("KNOX_SCRATCH", string.lower)
AntibodiesEnum.BodyPart.Infection.define("KNOX_CUT", string.lower)
AntibodiesEnum.BodyPart.Infection.define("REGULAR", string.lower)

AntibodiesEnum.BodyPart.Treatment = AntibodiesEnum.createEnum()
AntibodiesEnum.BodyPart.Treatment.define("BANDAGED", string.lower)
AntibodiesEnum.BodyPart.Treatment.define("CLEAN_BANDAGE", string.lower)
AntibodiesEnum.BodyPart.Treatment.define("STERILIZED_BANDAGE", string.lower)
AntibodiesEnum.BodyPart.Treatment.define("STERILIZED_WOUND", string.lower)
AntibodiesEnum.BodyPart.Treatment.define("GARLIC", string.lower)
AntibodiesEnum.BodyPart.Treatment.define("PLANTAIN", string.lower)
AntibodiesEnum.BodyPart.Treatment.define("COMFREY", string.lower)

return AntibodiesEnum
