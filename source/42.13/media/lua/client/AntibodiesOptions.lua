--[[
local AntibodiesUtils = require("AntibodiesUtils")
local AntibodiesCondition = require("AntibodiesCondition")
local AntibodiesBodyPart = require("AntibodiesBodyPart")

local AntibodiesOptions = {}
AntibodiesOptions.__index = AntibodiesOptions

-----------------------------------------------------
--CONSTS---------------------------------------------
-----------------------------------------------------

AntibodiesOptions.defaultOptions = {
	["general"] = {
		["baseAntibodyGrowth"] = 180.0,
		["knoxInfectionsSurvivedEffect"] = 0.0,
		["knoxInfectionsSurvivedThreshold"] = 100.0,
		["knoxMutationEffect"] = 0.0,
		["knoxMutationThreshold"] = 100.0,
		["knoxMutationStart"] = 2,
		["hygienePanelEnabled"] = true,
		["diagnoseEnabled"] = true,
		["diagnoseSkillNeeded"] = 2.0,
		["doctorSkillTreatmentMod"] = 1.0,
		["debug"] = false,
	},
	["condition"] = {
		[AntibodiesCondition.Enum.FITNESS] = 5.0,
		[AntibodiesCondition.Enum.STRENGTH] = 5.0,
		[AntibodiesCondition.Enum.FATIGUE] = -10.0,
		[AntibodiesCondition.Enum.ENDURANCE] = -10.0,
		[AntibodiesCondition.Enum.WEIGHT] = -20.0,
		[AntibodiesCondition.Enum.THIRST] = -20.0,
		[AntibodiesCondition.Enum.SICKNESS] = -10.0,
		[AntibodiesCondition.Enum.FOOD_SICKNESS] = -10.0,
		[AntibodiesCondition.Enum.TEMPERATURE] = 20.0,
		[AntibodiesCondition.Enum.INTOXICATION] = 10.0,
		[AntibodiesCondition.Enum.HUNGER] = -20.0,
		[AntibodiesCondition.Enum.PAIN] = -5.0,
		[AntibodiesCondition.Enum.STRESS] = -5.0,
		[AntibodiesCondition.Enum.UNHAPPINESS] = -5.0,
		[AntibodiesCondition.Enum.BOREDOM] = -1.0,
		[AntibodiesCondition.Enum.PANIC] = -5.0,
		[AntibodiesCondition.Enum.SANITY] = 0.0,
		[AntibodiesCondition.Enum.ANGER] = 0.0,
	},
	["wounds"] = {
		[AntibodiesBodyPart.TreatmentEnum.BANDAGED] = 0.25,
		[AntibodiesBodyPart.TreatmentEnum.CLEAN_BANDAGE] = 0.25,
		[AntibodiesBodyPart.TreatmentEnum.STERILIZED_BANDAGE] = 0.25,
		[AntibodiesBodyPart.TreatmentEnum.STERILIZED_WOUND] = 0.25,

		[AntibodiesBodyPart.TreatmentEnum.GARLIC] = 1.0,
		[AntibodiesBodyPart.TreatmentEnum.PLANTAIN] = 0.5,
		[AntibodiesBodyPart.TreatmentEnum.COMFREY] = 0.25,

		[AntibodiesBodyPart.WoundEnum.DEEP_WOUNDED] = -4.0,
		[AntibodiesBodyPart.WoundEnum.BLEEDING] = -4.0,

		[AntibodiesBodyPart.WoundEnum.BITTEN] = -3.0,
		[AntibodiesBodyPart.WoundEnum.CUT] = -2.0,
		[AntibodiesBodyPart.WoundEnum.SCRATCHED] = -1.0,

		[AntibodiesBodyPart.WoundEnum.BURNT] = -2.0,
		[AntibodiesBodyPart.WoundEnum.NEED_BURN_WASH] = -3.0,
		[AntibodiesBodyPart.WoundEnum.STICHED] = -1.0,

		[AntibodiesBodyPart.WoundEnum.HAVE_BULLET] = -3.0,
		[AntibodiesBodyPart.WoundEnum.HAVE_GLASS] = -2.0,
	},
	["infections"] = {
		["virus"] = 0.0,
		["regular"] = -1.0,
		["virusScratch"] = -2.0,
		["virusCut"] = -3.0,
		["virusBite"] = -4.0,
	},
	["hygiene"] = {
		["bloodEffect"] = -20.0,
		["dirtEffect"] = -10.0,

		["bandaged"] = 0.25,
		["cleanBandage"] = 0.25,
		["sterilizedBandage"] = 0.25,
		["sterilizedWound"] = 0.25,

		["garlic"] = 0.0,
		["plantain"] = 0.0,
		["comfrey"] = 0.0,

		["deepWounded"] = -0.80,
		["bleeding"] = -0.60,

		["bitten"] = -0.40,
		["cut"] = -0.20,
		["scratched"] = -0.10,

		["burnt"] = -0.40,
		["needBurnWash"] = -0.60,
		["stiched"] = -0.10,

		["haveBullet"] = -0.60,
		["haveGlass"] = -0.40,
	},
}

-----------------------------------------------------
--CORE-----------------------------------------------
-----------------------------------------------------

local getSandboxOptionPath = function(group, prop)
	return "" .. Antibodies.info.modId .. "_" .. Antibodies.info.optionsVersion .. "_" .. group .. "_" .. prop
end

local getAntibodiesSandboxOptions = function()
	local result = {}
	local defaults = AntibodiesOptions.defaultOptions
	for group_index, group_key in pairs(AntibodiesUtils.get_keys(defaults)) do
		result[group_key] = {}
		for prop_index, prop_key in pairs(AntibodiesUtils.get_keys(defaults[group_key])) do
			local path = getSandboxOptionPath(group_key, prop_key)
			if AntibodiesUtils.has_key(SandboxVars, path) then
				result[group_key][prop_key] = SandboxVars[path]
			end
		end
	end
	return result
end

local mergeOptions = function(default, loaded)
	local result = AntibodiesUtils.deep_copy(default)
	if type(loaded) ~= "table" then
		return default
	end
	local groups = AntibodiesUtils.get_keys(AntibodiesOptions.defaultOptions)
	for group_index, group_key in pairs(groups) do
		if type(loaded[group_key]) == "table" then
			for prop_key, prop_val in pairs(default[group_key]) do
				if loaded[group_key][prop_key] ~= nil then
					
					if result[group_key][prop_key] ~= loaded[group_key][prop_key] then
						print(
							string.format(
								"%s overriding sandbox option %s %s %s %s %s %s",
								Antibodies.info.modId,
								group_key,
								prop_key,
								"from",
								tostring(result[group_key][prop_key]),
								"to",
								tostring(loaded[group_key][prop_key])
							)
						)
					end
					
					result[group_key][prop_key] = loaded[group_key][prop_key]
				end
			end
		end
	end
	return result
end

local getOptions = function()
	return AntibodiesOptions.defaultOptions
	--return mergeOptions(AntibodiesOptions.defaultOptions, getAntibodiesSandboxOptions())
end

local getCurves = function()
	return {
		[AntibodiesCondition.Enum.FITNESS] = {
			{ 0.0, -1.0 },
			{ 5.0, 0.0 },
			{ 10.0, 1.0 },
		},
		[AntibodiesCondition.Enum.STRENGTH] = {
			{ 0.0, -1.0 },
			{ 5.0, 0.0 },
			{ 10.0, 1.0 },
		},
		[AntibodiesCondition.Enum.FATIGUE] = {
			{ 0.0, 0.0 },
			{ 1.0, 1.0 },
		},
		[AntibodiesCondition.Enum.ENDURANCE] = {
			{ 0.0, 1.0 },
			{ 1.0, 0.0 },
		},
		[AntibodiesCondition.Enum.WEIGHT] = {
			{ 35.0, 1.0 },
			{ 80.0, 0.0 },
			{ 130.0, 1.0 },
		},
		[AntibodiesCondition.Enum.THIRST] = {
			{ 0.0, 0.0 },
			{ 1.0, 1.0 },
		},
		[AntibodiesCondition.Enum.SICKNESS] = {
			{ 0.0, 0.0 },
			{ 1.0, 1.0 },
		},
		[AntibodiesCondition.Enum.FOOD_SICKNESS] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		[AntibodiesCondition.Enum.TEMPERATURE] = {
			{ 20.0, -1.0 },
			{ 36.6, 0.0 },
			{ 40.0, 1.0 },
		},
		[AntibodiesCondition.Enum.INTOXICATION] = {
			{ 0.0, 0.0 },
			{ 0.5, 1 },
			{ 1.0, 0.8 },
		},
		[AntibodiesCondition.Enum.HUNGER] = {
			{ 0.0, 0.0 },
			{ 1.0, 1.0 },
		},
		[AntibodiesCondition.Enum.PAIN] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		[AntibodiesCondition.Enum.STRESS] = {
			{ 0.0, 0.0 },
			{ 1.5, 1.0 },
		},
		[AntibodiesCondition.Enum.UNHAPPINESS] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		[AntibodiesCondition.Enum.BOREDOM] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		[AntibodiesCondition.Enum.PANIC] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		[AntibodiesCondition.Enum.SANITY] = {
			{ 0.0, 1.0 },
			{ 100.0, 0.0 },
		},
		[AntibodiesCondition.Enum.ANGER] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
	}
end

-----------------------------------------------------
--EXPORTS--------------------------------------------
-----------------------------------------------------

AntibodiesOptions.getOptions = getOptions
AntibodiesOptions.getCurves = getCurves

return AntibodiesOptions
]]
