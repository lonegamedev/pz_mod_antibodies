AntibodiesShared = {}
AntibodiesShared.__index = AntibodiesShared

-----------------------------------------------------
--CONST----------------------------------------------
-----------------------------------------------------

AntibodiesShared.version = "1.14"
AntibodiesShared.author = "lonegamedev.com"
AntibodiesShared.modName = "Antibodies"
AntibodiesShared.modId = "lgd_antibodies"

-----------------------------------------------------
--STATE----------------------------------------------
-----------------------------------------------------

AntibodiesShared.General = nil
AntibodiesShared.DamageEffects = nil
AntibodiesShared.MoodleEffects = nil
AntibodiesShared.TraitsEffects = nil

-----------------------------------------------------
--COMMON---------------------------------------------
-----------------------------------------------------

local function has_key(table,key)
    return table[key] ~= nil
end

local function lerp(v0, v1, t)
  return (1.0 - t) * v0 + t * v1
end

local function format_float(num)
  return string.format("%.4f", num)
end

local function is_number(num)
    if type(num) == "number" then
        return true
    else
        return false
    end
end

local function clamp(num, min, max)
  return math.max(min, math.min(num, max))
end

local function deepcopy(val)
  local val_copy
  if type(val) == 'table' then
      val_copy = {}
      for k,v in pairs(val) do
        val_copy[k] = deepcopy(v)
      end
  else
      val_copy = val
  end
  return val_copy
end

-----------------------------------------------------
--OPTIONS--------------------------------------------
-----------------------------------------------------

local function hasOptions()
  if not AntibodiesShared.General then return false end 
  if not AntibodiesShared.DamageEffects then return false end
  if not AntibodiesShared.MoodleEffects then return false end
  if not AntibodiesShared.TraitsEffects then return false end
  return true
end

local function getOptionsPreset(preset)
  --todo: add presets
  return {
    ["General"] = {
      ["baseAntibodyGrowth"] = 1.6
    },
    ["DamageEffects"] = {
      ["InfectedWound"] = -0.001
    },
    ["MoodleEffects"] = {
      ["Bleeding"] = -0.1,
      ["Hypothermia"] = -0.1,
      ["Injured"] = 0.0,
      
      ["Thirst"] = -0.04,
      ["Hungry"] = -0.03,
      ["Sick"] = -0.02,
      ["HasACold"] = -0.02,

      ["Tired"] = -0.01,
      ["Endurance"] = -0.01,
      ["Pain"] = -0.01,
      ["Wet"] = -0.01,
      ["HeavyLoad"] = -0.01,
      ["Windchill"] = -0.01,
      
      ["Panic"] = -0.01,
      ["Stress"] = -0.01,
      ["Unhappy"] = -0.01,
      ["Bored"] = -0.01,
      
      ["Hyperthermia"] = 0.01,
      ["Drunk"] = 0.01,
      ["FoodEaten"] = 0.05,
      
      ["Dead"] = 0.0,
      ["Zombie"] = 0.0,
      ["Angry"] = 0.0,
    },
    ["TraitsEffects"] = {
      ["Asthmatic"] = -0.01,
      ["Smoker"] = -0.01,
      
      ["Unfit"] = -0.02,
      ["Out of Shape"] = -0.01,
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
      ["Very Underweight"] = -0.01,
      ["Underweight"] = 0.005,
      ["Overweight"] = 0.005,
      ["Obese"] = -0.02
    }
  }
end

local function applyOptions(options)
  if (type(options) ~= "table") then
    return false
  end
  if(options["Antibodies"] ~= nil) then
    if(options["Antibodies"]["version"] ~= AntibodiesShared.version) then
      return false
    end
  else
    return false
  end
  if(options["General"] ~= nil) then
    for k,v in pairs(AntibodiesShared.General) do
      if(options["General"][k] ~= nil) then
        AntibodiesShared.General[k] = options["General"][k]
      end
    end
  end
  if(options["MoodleEffects"] ~= nil) then
    for k,v in pairs(AntibodiesShared.MoodleEffects) do
      if(options["MoodleEffects"][k] ~= nil) then
        AntibodiesShared.MoodleEffects[k] = options["MoodleEffects"][k]
      end
    end
  end
  if(options["DamageEffects"] ~= nil) then
    for k,v in pairs(AntibodiesShared.DamageEffects) do
      if(options["DamageEffects"][k] ~= nil) then
        AntibodiesShared.DamageEffects[k] = options["DamageEffects"][k]
      end
    end
  end
  if(options["TraitsEffects"] ~= nil) then
    for k,v in pairs(AntibodiesShared.TraitsEffects) do
      if(options["TraitsEffects"][k] ~= nil) then
        AntibodiesShared.TraitsEffects[k] = options["TraitsEffects"][k]
      end
    end
  end
  return true
end

local function loadOptions()
  local options = {}
	local reader = getFileReader("antibodies_options.ini", false)
	if not reader then
    return false
	end
  local current_group = nil
	while true do
		local line = reader:readLine()
		if not line then
			reader:close()
			break
		end
		line = line:trim()
		if line ~= "" then
			local k,v = line:match("^([^=%[]+)=([^=]+)$")
			if k then
        if not current_group then
        else
			k = k:trim()
			options[current_group][k] = v:trim()
        end
      	else
			local group = line:match("^%[([^%[%]%%]+)%]$")
			if group then
				current_group = group:trim()
          	options[current_group] = {}
        end
      end
	end
  end
  if(options["Antibodies"] ~= nil) then
    if(options["Antibodies"]["version"] ~= nil) then
      if(options["Antibodies"]["version"] == AntibodiesShared.version) then
        return options
      end
    end
  end
  return false
end

local function saveOptions(options)
  if (type(options) ~= "table") then
    return false
  end
  local writer = getFileWriter("antibodies_options.ini", true, false)
  for id,group in pairs(options) do
    writer:write("\r\n["..id.."]\r\n")
    for k,v in pairs(group) do
      writer:write(k..' = '..v.."\r\n")
    end
	end
  writer:close();
  return true
end

local function getCurrentOptions()
  if not hasOptions() then
    local default = getOptionsPreset()
    AntibodiesShared.General = default["General"]
    AntibodiesShared.DamageEffects = default["DamageEffects"]
    AntibodiesShared.MoodleEffects = default["MoodleEffects"]
    AntibodiesShared.TraitsEffects = default["TraitsEffects"]
    applyOptions(loadOptions())
  end
  local options = {}
  options["Antibodies"] = {}
  options["Antibodies"]["version"] = AntibodiesShared.version
  options["Antibodies"]["author"] = AntibodiesShared.author
  options["Antibodies"]["modName"] = AntibodiesShared.modName
  options["Antibodies"]["modId"] = AntibodiesShared.modId
  options["General"] = deepcopy(AntibodiesShared.General)
  options["MoodleEffects"] = deepcopy(AntibodiesShared.MoodleEffects)
  options["DamageEffects"] = deepcopy(AntibodiesShared.DamageEffects)
  options["TraitsEffects"] = deepcopy(AntibodiesShared.TraitsEffects)
  return options
end

-----------------------------------------------------
--EXPORTS--------------------------------------------
-----------------------------------------------------

AntibodiesShared.has_key = has_key
AntibodiesShared.lerp = lerp
AntibodiesShared.format_float = format_float
AntibodiesShared.is_number = is_number
AntibodiesShared.clamp = clamp
AntibodiesShared.deepcopy = deepcopy

AntibodiesShared.hasOptions = hasOptions
AntibodiesShared.applyOptions = applyOptions
AntibodiesShared.getCurrentOptions = getCurrentOptions
AntibodiesShared.loadOptions = loadOptions
AntibodiesShared.saveOptions = saveOptions
AntibodiesShared.getOptionsPreset = getOptionsPreset

return AntibodiesShared