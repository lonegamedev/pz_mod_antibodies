AntibodiesOptions = {}
AntibodiesOptions.__index = AntibodiesOptions

-----------------------------------------------------
--CONSTS---------------------------------------------
-----------------------------------------------------

AntibodiesOptions.modOptionsTweaks = {
  ["Susceptible"] = {
    ["infections"] = {
      ["virusScratch"] = 0.0,
      ["virusCut"] = 0.0,
      ["virusBite"] = 0.0
    }
  }
}

AntibodiesOptions.sandboxIgnore = {
  ["wounds"] = {
    ["bandaged"] = true,
    ["cleanBandage"] = true,
    ["sterilizedBandage"] = true,
    ["sterilizedWound"] = true
  },
  ["hygiene"] = {
    ["bandaged"] = true
  },
  ["moodles"] = {
    ["injured"] = true,      
    ["dead"] = true,
    ["zombie"] = true,
    ["angry"] = true
  }
}

AntibodiesOptions.defaultOptions = {
  ["general"] = {
    ["baseAntibodyGrowth"] = 1.6,
    ["knoxInfectionsSurvivedEffect"] = 0.0,
    ["knoxInfectionsSurvivedThreshold"] = 1.0,
    ["knoxMutationEffect"] = 0.0,
    ["knoxMutationThreshold"] = 1.0
  },
  ["wounds"] = {
    ["bandaged"] = 0.0,
    ["cleanBandage"] = 0.0,
    ["sterilizedBandage"] = 0.0,
    ["sterilizedWound"] = 0.0,

    ["deepWounded"] = -0.01,
    ["bleeding"] = -0.02,

    ["bitten"] = -0.01,
    ["cut"] = -0.008,
    ["scratched"] = -0.003,

    ["burnt"] = -0.005,
    ["needBurnWash"] = -0.01,
    ["stiched"] = -0.001,

    ["haveBullet"] = -0.02,
    ["haveGlass"] = -0.01
  },
  ["infections"] = {
    ["regular"] = -0.01,
    ["virus"] = 0.0,
    ["virusScratch"] = -0.01,
    ["virusCut"] = -0.025,
    ["virusBite"] = -0.05,
  },
  ["hygiene"] = {
    ["bloodEffect"] = -0.2,
    ["dirtEffect"] = -0.1,

    ["bandaged"] = 0.0,
    ["cleanBandage"] = 0.3,
    ["sterilizedBandage"] = 0.3,
    ["sterilizedWound"] = 0.3,

    ["deepWounded"] = -0.85,
    ["bleeding"] = -0.45,

    ["bitten"] = -0.40,
    ["cut"] = -0.20,
    ["scratched"] = -0.10,

    ["burnt"] = -0.40,
    ["needBurnWash"] = -0.60,
    ["stiched"] = -0.05,

    ["haveBullet"] = -0.60,
    ["haveGlass"] = -0.40
  },
  --[[
  ["moodles"] = {
    ["Bleeding"] = -0.1,

    ["Thirst"] = -0.04,
    ["Hungry"] = -0.03,
    ["Sick"] = -0.02,
    ["HasACold"] = -0.02,
    ["Pain"] = -0.01,
    ["Tired"] = -0.01,
    ["Endurance"] = -0.01,      

    ["Panic"] = -0.01,
    ["Stress"] = -0.01,
    ["Unhappy"] = -0.01,
    ["Bored"] = -0.01,
    
    ["Hyperthermia"] = 0.01,
    ["Hypothermia"] = -0.1,
    ["Windchill"] = -0.01,
    ["Wet"] = -0.01,
    ["HeavyLoad"] = -0.01,

    ["Drunk"] = 0.01,
    ["FoodEaten"] = 0.05,

    ["Injured"] = 0.0,      
    ["Dead"] = 0.0,
    ["Zombie"] = 0.0,
    ["Angry"] = 0.0
  },
  ["traits"] = {
    ["Asthmatic"] = -0.01,
    ["Smoker"] = -0.01,
    
    ["Unfit"] = -0.02,
    ["OutOfShape"] = -0.01,
    ["Athletic"] = 0.01,
  
    ["SlowHealer"] = -0.01,
    ["FastHealer"] = 0.01,
    
    ["ProneToIllness"] = -0.01,
    ["Resilient"] = 0.01,
  
    ["Weak"] = -0.02,
    ["Feeble"] = -0.01,
    ["Strong"] = 0.01,
    ["Stout"] = 0.02,
  
    ["Emaciated"] = -0.02,
    ["VeryUnderweight"] = -0.01,
    ["Underweight"] = -0.005,
    ["Overweight"] = -0.005,
    ["Obese"] = -0.02,

    ["Lucky"] = 0.0,
    ["Unlucky"] = 0.0
  },
  --]]
  ["condition"] = {
    ["fitness"] = 0.01,
    ["strength"] = 0.01,
    ["fatigue"] = 0.0,
    ["endurance"] = 0.0,
    ["weight"] = 0.0,
    ["calories"] = 0.0,
    ["thirst"] = 0.0,
    ["sickness"] = 0.0,
    ["foodSickness"] = 0.0,
    ["temperature"] = 0.0,
    ["drunkness"] = 0.0,
    ["hunger"] = 0.0,
    ["pain"] = -0.01,
    ["stress"] = 0.0, 
    ["unhappiness"] = 0.0,
    ["boredom"] = 0.0,
    ["panic"] = 0.0,
    ["sanity"] = 0.0,
    ["anger"] = 0.0,
    ["fear"] = 0.0
  },
  ["debug"] = {
    ["enabled"] = false,
    ["wounds"] = false,
    ["infections"] = false,
    ["hygiene"] = false,
    ["moodles"] = false,
    ["traits"] = false
  }
}

-----------------------------------------------------
--CORE-----------------------------------------------
-----------------------------------------------------

local getSandboxOptionPath = function(group, prop)
  return ""..Antibodies.info.modId.."_"..AntibodiesUtils.flatten_version(Antibodies.info.optionsVersion).."_"..group.."_"..prop
end

local isIgnoredPath = function(group, prop)
  if not AntibodiesOptions.sandboxIgnore[group] then
    return false
  end
  return AntibodiesOptions.sandboxIgnore[group][prop] == true
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
      else
        if not isIgnoredPath(group_key, prop_key) then
          --error("Antibodies: Can't find SandboxVars property: "..path)
        end
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
          result[group_key][prop_key] = loaded[group_key][prop_key]
        end
      end
    end
  end
  return result
end

local tweakForMods = function(options)
  local mods = getActivatedMods()
  for i=1, mods:size() do
    local id = mods:get(i - 1)
    if AntibodiesUtils.has_key(AntibodiesOptions.modOptionsTweaks, id) then
      options = mergeOptions(options, AntibodiesOptions.modOptionsTweaks[id])
    end
  end
  return options
end

local getOptions = function()
  return tweakForMods(
    mergeOptions(
      AntibodiesOptions.defaultOptions,
      getAntibodiesSandboxOptions()
    )
  )
end

local getCurves = function()
  return {
    ["fitness"] = {
      {0.0, 0.0},
      {10.0, 1.0}
    },
    ["strength"] = {
      {0.0, 0.0},
      {10.0, 1.0}
    },
    ["fatigue"] = {
      {0.0, 0.0},
      {1.0, 1.0}
    },
    ["endurance"] = {
      {0.0, 0.0},
      {1.0, 1.0}
    },
    ["weight"] = {
      {35.0, 1.0},
      {80.0, 0.0},
      {130.0, 1.0}
    },
    ["calories"] = {
      {2200.0, -1.0},
      {750.0, 0.0},
      {3700.0, 1.0}
    },
    ["thirst"] = {
      {0.0, 0.0},
      {1.0, 1.0}
    },
    ["sickness"] = {
      {0.0, 0.0},
      {1.0, 1.0}
    },
    ["foodSickness"] = {
      {0.0, 0.0},
      {1.0, 1.0}
    },
    ["temperature"] = {
      {20.0, -1.0},
      {36.6, 0.0},
      {40.0, 1.0}
    },
    ["drunkness"] = {
      {0.0, 0.0},
      {0.5, 1},
      {1.0, 0.8}
    },
    ["hunger"] = {
      {0.0, 0.0},
      {1.0, 1.0}
    },
    ["pain"] = {
      {0.0, 0.0},
      {1.0, 1.0}
    },
    ["stress"] = {
      {0.0, 0.0},
      {1.5, 1.0}
    },
    ["unhappiness"] = {
      {0.0, 0.0},
      {100.0, 1.0}
    },
    ["boredom"] = {
      {0.0, 0.0},
      {100.0, 1.0}
    },
    ["panic"] = {
      {0.0, 0.0},
      {100.0, 1.0}
    },
    ["sanity"] = {
      {0.0, 1.0},
      {100.0, 0.0}
    },
    ["anger"] = {
      {0.0, 0.0},
      {100.0, 1.0}
    },
    ["fear"] = {
      {0.0, 0.0},
      {100.0, 1.0}
    }
  }
end

-----------------------------------------------------
--EXPORTS--------------------------------------------
-----------------------------------------------------

AntibodiesOptions.getOptions = getOptions
AntibodiesOptions.getCurves = getCurves

-----------------------------------------------------
--CALLBACKS------------------------------------------
-----------------------------------------------------

--[[
local function initOptions()
  print("BOOTING")
  local option = DoubleSandboxOption.new(getSandboxOptions(), "TEST_FIELD",  0.0, 1.0, 0.0)
  option:setPageName("lgd_antibodies_debug")
  option:setTranslation("debug_traits")
  option:setCustom()
  option:setValue(0.0)
  --getSandboxOptions():toLua()
  --getSandboxOptions():set()
  --getSandboxOptions():toLua()
  --getSandboxOptions():updateFromLua()
  getSandboxOptions():initSandboxVars()

end

local function onCreateUI()
  initOptions()
end
Events.OnCreateUI.Add(onCreateUI)

local function onMainMenuEnter()
  initOptions()
end
Events.OnMainMenuEnter.Add(onMainMenuEnter)

local function onGameBoot()
  initOptions()
end
Events.OnGameBoot.Add(onGameBoot)
]]