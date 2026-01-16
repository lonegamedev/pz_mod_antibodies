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

	function enum.hasKey(name)
		return enum[name] ~= nil
	end

	function enum.hasValue(value)
		for _key, val in pairs(enum) do
			if val == value then
				return true
			end
		end
		return false
	end

	function enum.list()
		return enumList
	end

	return enum
end

AntibodiesEnum.Network = AntibodiesEnum.createEnum()
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
AntibodiesEnum.Config.General.define("IPC_DEBUG", string.lower)

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
AntibodiesEnum.Condition.define("SMOKER_STRESS", string.lower)
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

function AntibodiesEnum.getBodyPartTranslationKey(key)
	if key == AntibodiesEnum.BodyPart.HAND_L then
		return "UI_Antibodies_BodyParts_Hand_L"
	elseif key == AntibodiesEnum.BodyPart.HAND_R then
		return "UI_Antibodies_BodyParts_Hand_R"
	elseif key == AntibodiesEnum.BodyPart.FOREARM_L then
		return "UI_Antibodies_BodyParts_ForeArm_L"
	elseif key == AntibodiesEnum.BodyPart.FOREARM_R then
		return "UI_Antibodies_BodyParts_ForeArm_R"
	elseif key == AntibodiesEnum.BodyPart.UPPERARM_L then
		return "UI_Antibodies_BodyParts_UpperArm_L"
	elseif key == AntibodiesEnum.BodyPart.UPPERARM_R then
		return "UI_Antibodies_BodyParts_UpperArm_R"
	elseif key == AntibodiesEnum.BodyPart.TORSO_UPPER then
		return "UI_Antibodies_BodyParts_Torso_Upper"
	elseif key == AntibodiesEnum.BodyPart.TORSO_LOWER then
		return "UI_Antibodies_BodyParts_Torso_Lower"
	elseif key == AntibodiesEnum.BodyPart.HEAD then
		return "UI_Antibodies_BodyParts_Head"
	elseif key == AntibodiesEnum.BodyPart.NECK then
		return "UI_Antibodies_BodyParts_Neck"
	elseif key == AntibodiesEnum.BodyPart.GROIN then
		return "UI_Antibodies_BodyParts_Groin"
	elseif key == AntibodiesEnum.BodyPart.UPPERLEG_L then
		return "UI_Antibodies_BodyParts_UpperLeg_L"
	elseif key == AntibodiesEnum.BodyPart.UPPERLEG_R then
		return "UI_Antibodies_BodyParts_UpperLeg_R"
	elseif key == AntibodiesEnum.BodyPart.LOWERLEG_L then
		return "UI_Antibodies_BodyParts_LowerLeg_L"
	elseif key == AntibodiesEnum.BodyPart.LOWERLEG_R then
		return "UI_Antibodies_BodyParts_LowerLeg_R"
	elseif key == AntibodiesEnum.BodyPart.FOOT_L then
		return "UI_Antibodies_BodyParts_Foot_L"
	elseif key == AntibodiesEnum.BodyPart.FOOT_R then
		return "UI_Antibodies_BodyParts_Foot_R"
	end
	return key
end

function AntibodiesEnum.getConditionTranslationKey(key)
	if key == AntibodiesEnum.Condition.FITNESS then
		return "UI_Antibodies_Condition_fitness"
	elseif key == AntibodiesEnum.Condition.STRENGTH then
		return "UI_Antibodies_Condition_strength"
	elseif key == AntibodiesEnum.Condition.FATIGUE then
		return "UI_Antibodies_Condition_fatigue"
	elseif key == AntibodiesEnum.Condition.ENDURANCE then
		return "UI_Antibodies_Condition_endurance"
	elseif key == AntibodiesEnum.Condition.WEIGHT then
		return "UI_Antibodies_Condition_weight"
	elseif key == AntibodiesEnum.Condition.CALORIES then
		return "UI_Antibodies_Condition_calories"
	elseif key == AntibodiesEnum.Condition.CARBOHYDRATES then
		return "UI_Antibodies_Condition_carbohydrates"
	elseif key == AntibodiesEnum.Condition.LIPIDS then
		return "UI_Antibodies_Condition_lipids"
	elseif key == AntibodiesEnum.Condition.PROTEINS then
		return "UI_Antibodies_Condition_proteins"
	elseif key == AntibodiesEnum.Condition.HUNGER then
		return "UI_Antibodies_Condition_hunger"
	elseif key == AntibodiesEnum.Condition.THIRST then
		return "UI_Antibodies_Condition_thirst"
	elseif key == AntibodiesEnum.Condition.INTOXICATION then
		return "UI_Antibodies_Condition_intoxication"
	elseif key == AntibodiesEnum.Condition.SICKNESS then
		return "UI_Antibodies_Condition_sickness"
	elseif key == AntibodiesEnum.Condition.FOOD_SICKNESS then
		return "UI_Antibodies_Condition_foodSickness"
	elseif key == AntibodiesEnum.Condition.TEMPERATURE then
		return "UI_Antibodies_Condition_temperature"
	elseif key == AntibodiesEnum.Condition.PAIN then
		return "UI_Antibodies_Condition_pain"
	elseif key == AntibodiesEnum.Condition.STRESS then
		return "UI_Antibodies_Condition_stress"
	elseif key == AntibodiesEnum.Condition.SMOKER_STRESS then
		return "UI_Antibodies_Condition_stressSmoker"
	elseif key == AntibodiesEnum.Condition.UNHAPPINESS then
		return "UI_Antibodies_Condition_unhappiness"
	elseif key == AntibodiesEnum.Condition.BOREDOM then
		return "UI_Antibodies_Condition_boredom"
	elseif key == AntibodiesEnum.Condition.PANIC then
		return "UI_Antibodies_Condition_panic"
	elseif key == AntibodiesEnum.Condition.SANITY then
		return "UI_Antibodies_Condition_sanity"
	elseif key == AntibodiesEnum.Condition.ANGER then
		return "UI_Antibodies_Condition_anger"
	end
	return key
end

function AntibodiesEnum.getWoundOrTreatmentTranslationKey(key)
	if key == AntibodiesEnum.BodyPart.Wound.DEEP_WOUNDED then
		return "UI_Antibodies_Wounds_deepWounded"
	elseif key == AntibodiesEnum.BodyPart.Wound.BLEEDING then
		return "UI_Antibodies_Wounds_bleeding"
	elseif key == AntibodiesEnum.BodyPart.Wound.BITTEN then
		return "UI_Antibodies_Wounds_bitten"
	elseif key == AntibodiesEnum.BodyPart.Wound.CUT then
		return "UI_Antibodies_Wounds_cut"
	elseif key == AntibodiesEnum.BodyPart.Wound.SCRATCHED then
		return "UI_Antibodies_Wounds_scratched"
	elseif key == AntibodiesEnum.BodyPart.Wound.BURNT then
		return "UI_Antibodies_Wounds_burnt"
	elseif key == AntibodiesEnum.BodyPart.Wound.NEED_BURN_WASH then
		return "UI_Antibodies_Wounds_needBurnWash"
	elseif key == AntibodiesEnum.BodyPart.Wound.STICHED then
		return "UI_Antibodies_Wounds_stiched"
	elseif key == AntibodiesEnum.BodyPart.Wound.HAVE_BULLET then
		return "UI_Antibodies_Wounds_haveBullet"
	elseif key == AntibodiesEnum.BodyPart.Wound.HAVE_GLASS then
		return "UI_Antibodies_Wounds_haveGlass"
	elseif key == AntibodiesEnum.BodyPart.Treatment.BANDAGED then
		return "UI_Antibodies_Wounds_bandaged"
	elseif key == AntibodiesEnum.BodyPart.Treatment.CLEAN_BANDAGE then
		return "UI_Antibodies_Wounds_cleanBandage"
	elseif key == AntibodiesEnum.BodyPart.Treatment.STERILIZED_BANDAGE then
		return "UI_Antibodies_Wounds_sterilizedBandage"
	elseif key == AntibodiesEnum.BodyPart.Treatment.STERILIZED_WOUND then
		return "UI_Antibodies_Wounds_sterilizedWound"
	elseif key == AntibodiesEnum.BodyPart.Treatment.GARLIC then
		return "UI_Antibodies_Wounds_garlic"
	elseif key == AntibodiesEnum.BodyPart.Treatment.PLANTAIN then
		return "UI_Antibodies_Wounds_plantain"
	elseif key == AntibodiesEnum.BodyPart.Treatment.COMFREY then
		return "UI_Antibodies_Wounds_comfrey"
	end
	return key
end

function AntibodiesEnum.getInfectionTranslation(key)
	if key == AntibodiesEnum.BodyPart.Infection.KNOX_BITE then
		return "UI_Antibodies_Infections_virusBite"
	elseif key == AntibodiesEnum.BodyPart.Infection.KNOX_SCRATCH then
		return "UI_Antibodies_Infections_virusScratch"
	elseif key == AntibodiesEnum.BodyPart.Infection.KNOX_CUT then
		return "UI_Antibodies_Infections_virusCut"
	elseif key == AntibodiesEnum.BodyPart.Infection.REGULAR then
		return "UI_Antibodies_Infections_regular"
	end
	return key
end

return AntibodiesEnum
