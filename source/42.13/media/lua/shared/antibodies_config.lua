local AntibodiesEnum = require("antibodies_enum")

local AntibodiesConfig = {}
AntibodiesConfig.__index = AntibodiesConfig

AntibodiesConfig.current = nil

function AntibodiesConfig.new()
	local instance = setmetatable({}, AntibodiesConfig)

	instance[AntibodiesEnum.Config.GENERAL] = {
		[AntibodiesEnum.Config.General.BASE_GROWTH] = 180.0,
		[AntibodiesEnum.Config.General.RECOVERY_EFFECT] = 0.0,
		[AntibodiesEnum.Config.General.RECOVERY_THRESHOLD] = 100.0,
		[AntibodiesEnum.Config.General.MUTATION_EFFECT] = 0.0,
		[AntibodiesEnum.Config.General.MUTATION_THRESHOLD] = 100.0,
		[AntibodiesEnum.Config.General.MUTATION_START] = 2,
		[AntibodiesEnum.Config.General.HYGIENE_PANEL_ENABLED] = true,
		[AntibodiesEnum.Config.General.DIAGNOSE_ENABLED] = true,
		[AntibodiesEnum.Config.General.DIAGNOSE_SKILL_NEEDED] = 2.0,
		[AntibodiesEnum.Config.General.DOCTOR_SKILL_TREATMENT_MOD] = 1.0,
		[AntibodiesEnum.Config.General.IPC_DEBUG] = false,
	}

	instance[AntibodiesEnum.Config.CONDITION] = {
		[AntibodiesEnum.Condition.FITNESS] = 5.0,
		[AntibodiesEnum.Condition.STRENGTH] = 5.0,
		[AntibodiesEnum.Condition.FATIGUE] = -10.0,
		[AntibodiesEnum.Condition.ENDURANCE] = -10.0,

		[AntibodiesEnum.Condition.WEIGHT] = -20.0,
		[AntibodiesEnum.Condition.CALORIES] = 0.0,
		[AntibodiesEnum.Condition.CARBOHYDRATES] = 0.0,
		[AntibodiesEnum.Condition.LIPIDS] = 0.0,
		[AntibodiesEnum.Condition.PROTEINS] = 0.0,

		[AntibodiesEnum.Condition.HUNGER] = -20.0,
		[AntibodiesEnum.Condition.THIRST] = -20.0,

		[AntibodiesEnum.Condition.INTOXICATION] = 10.0,
		[AntibodiesEnum.Condition.SICKNESS] = -10.0,
		[AntibodiesEnum.Condition.FOOD_SICKNESS] = -10.0,
		[AntibodiesEnum.Condition.TEMPERATURE] = 20.0,

		[AntibodiesEnum.Condition.PAIN] = -5.0,
		[AntibodiesEnum.Condition.STRESS] = -5.0,
		[AntibodiesEnum.Condition.UNHAPPINESS] = -5.0,
		[AntibodiesEnum.Condition.BOREDOM] = -1.0,
		[AntibodiesEnum.Condition.PANIC] = -5.0,
		[AntibodiesEnum.Condition.SANITY] = 0,
		[AntibodiesEnum.Condition.ANGER] = 0,
	}

	instance[AntibodiesEnum.Config.CONDITION_CURVE] = {
		[AntibodiesEnum.Condition.FITNESS] = {
			{ 0.0, -1.0 },
			{ 5.0, 0.0 },
			{ 10.0, 1.0 },
		},
		[AntibodiesEnum.Condition.STRENGTH] = {
			{ 0.0, -1.0 },
			{ 5.0, 0.0 },
			{ 10.0, 1.0 },
		},
		[AntibodiesEnum.Condition.FATIGUE] = {
			{ 0.0, 0.0 },
			{ 1.0, 1.0 },
		},
		[AntibodiesEnum.Condition.ENDURANCE] = {
			{ 0.0, 1.0 },
			{ 1.0, 0.0 },
		},
		[AntibodiesEnum.Condition.WEIGHT] = {
			{ 35.0, 1.0 },
			{ 80.0, 0.0 },
			{ 130.0, 1.0 },
		},
		[AntibodiesEnum.Condition.THIRST] = {
			{ 0.0, 0.0 },
			{ 1.0, 1.0 },
		},
		[AntibodiesEnum.Condition.SICKNESS] = {
			{ 0.0, 0.0 },
			{ 1.0, 1.0 },
		},
		[AntibodiesEnum.Condition.FOOD_SICKNESS] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		[AntibodiesEnum.Condition.TEMPERATURE] = {
			{ 20.0, -1.0 },
			{ 36.6, 0.0 },
			{ 40.0, 1.0 },
		},
		[AntibodiesEnum.Condition.INTOXICATION] = {
			{ 0.0, 0.0 },
			{ 0.5, 1 },
			{ 1.0, 0.8 },
		},
		[AntibodiesEnum.Condition.HUNGER] = {
			{ 0.0, 0.0 },
			{ 1.0, 1.0 },
		},
		[AntibodiesEnum.Condition.PAIN] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		[AntibodiesEnum.Condition.STRESS] = {
			{ 0.0, 0.0 },
			{ 1.5, 1.0 },
		},
		[AntibodiesEnum.Condition.UNHAPPINESS] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		[AntibodiesEnum.Condition.BOREDOM] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		[AntibodiesEnum.Condition.PANIC] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		[AntibodiesEnum.Condition.SANITY] = {
			{ 0.0, 1.0 },
			{ 100.0, 0.0 },
		},
		[AntibodiesEnum.Condition.ANGER] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
	}

	instance[AntibodiesEnum.Config.WOUND] = {
		[AntibodiesEnum.BodyPart.Wound.DEEP_WOUNDED] = -4.0,
		[AntibodiesEnum.BodyPart.Wound.BLEEDING] = -4.0,

		[AntibodiesEnum.BodyPart.Wound.BITTEN] = -3.0,
		[AntibodiesEnum.BodyPart.Wound.CUT] = -2.0,
		[AntibodiesEnum.BodyPart.Wound.SCRATCHED] = -1.0,

		[AntibodiesEnum.BodyPart.Wound.BURNT] = -2.0,
		[AntibodiesEnum.BodyPart.Wound.NEED_BURN_WASH] = -3.0,
		[AntibodiesEnum.BodyPart.Wound.STICHED] = -1.0,

		[AntibodiesEnum.BodyPart.Wound.HAVE_BULLET] = -3.0,
		[AntibodiesEnum.BodyPart.Wound.HAVE_GLASS] = -2.0,
	}

	instance[AntibodiesEnum.Config.INFECTION] = {
		[AntibodiesEnum.BodyPart.Infection.REGULAR] = -1.0,
		[AntibodiesEnum.BodyPart.Infection.KNOX_SCRATCH] = -2.0,
		[AntibodiesEnum.BodyPart.Infection.KNOX_CUT] = -3.0,
		[AntibodiesEnum.BodyPart.Infection.KNOX_BITE] = -4.0,
	}

	instance[AntibodiesEnum.Config.TREATMENT] = {
		[AntibodiesEnum.BodyPart.Treatment.BANDAGED] = 0.25,
		[AntibodiesEnum.BodyPart.Treatment.CLEAN_BANDAGE] = 0.25,
		[AntibodiesEnum.BodyPart.Treatment.STERILIZED_BANDAGE] = 0.25,
		[AntibodiesEnum.BodyPart.Treatment.STERILIZED_WOUND] = 0.25,

		[AntibodiesEnum.BodyPart.Treatment.GARLIC] = 1.0,
		[AntibodiesEnum.BodyPart.Treatment.PLANTAIN] = 0.5,
		[AntibodiesEnum.BodyPart.Treatment.COMFREY] = 0.25,
	}

	instance[AntibodiesEnum.Config.HYGIENE] = {
		[AntibodiesEnum.Config.Hygiene.BLOOD_EFFECT] = -20.0,
		[AntibodiesEnum.Config.Hygiene.DIRT_EFFECT] = -10.0,
	}

	instance[AntibodiesEnum.Config.HYGIENE_WOUND_MOD] = {
		[AntibodiesEnum.BodyPart.Wound.DEEP_WOUNDED] = -0.80,
		[AntibodiesEnum.BodyPart.Wound.BLEEDING] = -0.60,

		[AntibodiesEnum.BodyPart.Wound.BITTEN] = -0.40,
		[AntibodiesEnum.BodyPart.Wound.CUT] = -0.20,
		[AntibodiesEnum.BodyPart.Wound.SCRATCHED] = -0.10,

		[AntibodiesEnum.BodyPart.Wound.BURNT] = -0.40,
		[AntibodiesEnum.BodyPart.Wound.NEED_BURN_WASH] = -0.60,
		[AntibodiesEnum.BodyPart.Wound.STICHED] = -0.10,

		[AntibodiesEnum.BodyPart.Wound.HAVE_BULLET] = -0.60,
		[AntibodiesEnum.BodyPart.Wound.HAVE_GLASS] = -0.40,
	}

	instance[AntibodiesEnum.Config.HYGIENE_TREATMENT_MOD] = {
		[AntibodiesEnum.BodyPart.Treatment.BANDAGED] = 0.25,
		[AntibodiesEnum.BodyPart.Treatment.CLEAN_BANDAGE] = 0.25,
		[AntibodiesEnum.BodyPart.Treatment.STERILIZED_BANDAGE] = 0.25,
		[AntibodiesEnum.BodyPart.Treatment.STERILIZED_WOUND] = 0.25,

		[AntibodiesEnum.BodyPart.Treatment.GARLIC] = 0.0,
		[AntibodiesEnum.BodyPart.Treatment.PLANTAIN] = 0.0,
		[AntibodiesEnum.BodyPart.Treatment.COMFREY] = 0.0,
	}

	return instance
end

return AntibodiesConfig
