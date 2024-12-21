AntibodiesOptions = {}
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
		["fitness"] = 5.0,
		["strength"] = 5.0,
		["fatigue"] = -10.0,
		["endurance"] = -10.0,
		["weight"] = -20.0,
		["thirst"] = -20.0,
		["sickness"] = -10.0,
		["foodSickness"] = -10.0,
		["temperature"] = 20.0,
		["drunkness"] = 10.0,
		["hunger"] = -20.0,
		["pain"] = -5.0,
		["stress"] = -5.0,
		["unhappiness"] = -5.0,
		["boredom"] = -1.0,
		["panic"] = -5.0,
		["sanity"] = 0.0,
		["anger"] = 0.0,
		["fear"] = 0.0,
	},
	["wounds"] = {
		["bandaged"] = 0.25,
		["cleanBandage"] = 0.25,
		["sterilizedBandage"] = 0.25,
		["sterilizedWound"] = 0.25,

		["garlic"] = 1.0,
		["plantain"] = 0.5,
		["comfrey"] = 0.25,

		["deepWounded"] = -4.0,
		["bleeding"] = -4.0,

		["bitten"] = -3.0,
		["cut"] = -2.0,
		["scratched"] = -1.0,

		["burnt"] = -2.0,
		["needBurnWash"] = -3.0,
		["stiched"] = -1.0,

		["haveBullet"] = -3.0,
		["haveGlass"] = -2.0,
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
					--[[
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
					]]
					result[group_key][prop_key] = loaded[group_key][prop_key]
				end
			end
		end
	end
	return result
end

local getOptions = function()
	--return AntibodiesOptions.defaultOptions
	return mergeOptions(AntibodiesOptions.defaultOptions, getAntibodiesSandboxOptions())
end

local getCurves = function()
	return {
		["fitness"] = {
			{ 0.0, -1.0 },
			{ 5.0, 0.0 },
			{ 10.0, 1.0 },
		},
		["strength"] = {
			{ 0.0, -1.0 },
			{ 5.0, 0.0 },
			{ 10.0, 1.0 },
		},
		["fatigue"] = {
			{ 0.0, 0.0 },
			{ 1.0, 1.0 },
		},
		["endurance"] = {
			{ 0.0, 1.0 },
			{ 1.0, 0.0 },
		},
		["weight"] = {
			{ 35.0, 1.0 },
			{ 80.0, 0.0 },
			{ 130.0, 1.0 },
		},
		["thirst"] = {
			{ 0.0, 0.0 },
			{ 1.0, 1.0 },
		},
		["sickness"] = {
			{ 0.0, 0.0 },
			{ 1.0, 1.0 },
		},
		["foodSickness"] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		["temperature"] = {
			{ 20.0, -1.0 },
			{ 36.6, 0.0 },
			{ 40.0, 1.0 },
		},
		["drunkness"] = {
			{ 0.0, 0.0 },
			{ 0.5, 1 },
			{ 1.0, 0.8 },
		},
		["hunger"] = {
			{ 0.0, 0.0 },
			{ 1.0, 1.0 },
		},
		["pain"] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		["stress"] = {
			{ 0.0, 0.0 },
			{ 1.5, 1.0 },
		},
		["unhappiness"] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		["boredom"] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		["panic"] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		["sanity"] = {
			{ 0.0, 1.0 },
			{ 100.0, 0.0 },
		},
		["anger"] = {
			{ 0.0, 0.0 },
			{ 100.0, 1.0 },
		},
		["fear"] = {
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
