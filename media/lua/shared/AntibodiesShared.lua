AntibodiesShared = {}
AntibodiesShared.__index = AntibodiesShared

-----------------------------------------------------
--CONST----------------------------------------------
-----------------------------------------------------

AntibodiesShared.version = "1.40"
AntibodiesShared.author = "lonegamedev.com"
AntibodiesShared.modName = "Antibodies"
AntibodiesShared.modId = "lgd_antibodies"

local zeroMoodles = {"Angry", "Dead", "Zombie", "Injured"}

local bodyPartTypes = {"Back", "Foot_L", "Foot_R", "ForeArm_L", "ForeArm_R", "Groin", 
"Hand_L", "Hand_R", "Head", "LowerLeg_L", "LowerLeg_R", "Neck", "Torso_Lower", 
"Torso_Upper", "UpperArm_L", "UpperArm_R", "UpperLeg_L", "UpperLeg_R"}

local noAutoMigrationVersions = {"1.30", "1.40"}

-----------------------------------------------------
--STATE----------------------------------------------
-----------------------------------------------------

AntibodiesShared.currentOptions = nil

-----------------------------------------------------
--COMMON---------------------------------------------
-----------------------------------------------------

local function has_value(table, val)
  for k,v in pairs(table) do
    if v == val then
      return true
    end
  end
  return false
end

local function has_key(table, key)
    return table[key] ~= nil
end

local function get_keys(table)
  local keys={}
  local n=0
  for k,v in pairs(table) do
    n=n+1
    keys[n]=k
  end
  return keys
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

local function parse_value(txt)
  if txt == "true" then return true end
  if txt == "false" then return false end
  local num = tonumber(txt)
  if num == nil then
    return txt
  end
  return num
end

local function printOptions(options)
  for group_key, group in pairs(options) do
    for prop_key, prop_val in pairs(group) do
      print(group_key.."."..prop_key.." = "..tostring(prop_val))
    end
  end
end

-----------------------------------------------------
--OPTIONS--------------------------------------------
-----------------------------------------------------

local function hasOptions()
  --validate
  return AntibodiesShared.currentOptions ~= nil
end

local function getDefaultOptions()
  return {
    ["Antibodies"] = {
      ["version"] = AntibodiesShared.version,
      ["author"] = AntibodiesShared.author,
      ["modName"] = AntibodiesShared.modName,
      ["modId"] = AntibodiesShared.modId
    },
    ["General"] = {
      ["baseAntibodyGrowth"] = 1.6
    },
    ["Debug"] = {
      ["enabled"] = false,
      ["woundEffects"] = false,
      ["infectionEffects"] = false,
      ["hygieneEffects"] = false,
      ["moodleEffects"] = false,
      ["traitsEffects"] = false
    },
    ["WoundEffects"] = {
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
    ["InfectionEffects"] = {
      ["regular"] = -0.01,
      ["virusScratch"] = -0.01,
      ["virusCut"] = -0.025,
      ["virusBite"] = -0.05,
    },
    ["HygineEffects"] = {
      ["bloodEffect"] = -0.2,
      ["dirtEffect"] = -0.1,

      ["modCleanBandage"] = 0.3,
      ["modSterilizedBandage"] = 0.3,
      ["modSterilizedWound"] = 0.3,

      ["modDeepWounded"] = -0.85,
      ["modBleeding"] = -0.45,

      ["modBitten"] = -0.40,
      ["modCut"] = -0.20,
      ["modScratched"] = -0.10,

      ["modBurnt"] = -0.40,
      ["modNeedBurnWash"] = -0.60,
      ["modStiched"] = -0.05,

      ["modHaveBullet"] = -0.60,
      ["modHaveGlass"] = -0.40
    },
    ["MoodleEffects"] = {
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
    ["TraitsEffects"] = {
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
    }
  }
end

local function applyOptions(options)
  if (type(options) ~= "table") then
    return false
  end
  AntibodiesShared.currentOptions = deepcopy(options)
end

local function parseLine(options, control, line)
  if (type(line) ~= "string") then
    return false
  end
  line = line:trim()
  if line ~= "" then
  local k,v = line:match("^([^=%[]+)=([^=]+)$")
    if k then
      if control.group then
        k = k:trim()
        if control.group == "Antibodies" then         
          options[control.group][k] = v:trim()
        else
          options[control.group][k] = parse_value(v:trim())
        end
      end
    else
      local group = line:match("^%[([^%[%]%%]+)%]$")
      if group then
        control.group = group:trim()
        options[control.group] = {}
      end
    end
  end
end

local function loadOptions()
  local options = {}
  local control = { ["group"] = nil }
  local reader = getFileReader("antibodies_options.ini", false)
  if not reader then
    return false
  end
  while true do
    local line = reader:readLine()
    if not line then
		  reader:close()
		  break
		end
    parseLine(options, control, line)
  end
  if(options["Antibodies"] == nil) then 
    return false
  end
  if options["Antibodies"]["author"] ~= AntibodiesShared.author then
    return false
  end
  if options["Antibodies"]["modName"] ~= AntibodiesShared.modName then
    return false
  end
  if options["Antibodies"]["modId"] ~= AntibodiesShared.modId then
    return false
  end
  if(options["Antibodies"]["version"] == nil) then 
    return false
  end
  return options
end

local function optionsToString(options)
  if (type(options) ~= "table") then
    return false
  end
  local str = ""
  for id,group in pairs(options) do
    str = str.."\r\n["..id.."]\r\n"
    for k,v in pairs(group) do
      str = str..k..' = '..tostring(v).."\r\n"
    end
  end
  return str
end

local function stringToOptions(str)
  if (type(str) ~= "string") then
    return false
  end
  local options = {}
  local control = { ["group"] = nil }
  for line in str:gmatch("([^\n]*)\n?") do
    parseLine(options, control, line)
  end
  return options
end


local function saveHostOptions(options)
  if isClient() then
    sendClientCommand(getPlayer(), AntibodiesShared.modId, "saveOptions", options)
  end
end

local function saveOptions(options, alt_filename)
  if (type(options) ~= "table") then
    return false
  end
  local filename = "antibodies_options.ini"
  if alt_filename ~= nil then
    filename = alt_filename
  end
  local writer = getFileWriter(filename, true, false)
  for id,group in pairs(options) do
    writer:write("\r\n["..id.."]\r\n")
    for k,v in pairs(group) do
      writer:write(k..' = '..tostring(v).."\r\n")
    end
	end
  writer:close()
  return true
end

local function mergeOptions(default, loaded)
  local result = deepcopy(default)
  if type(loaded) ~= "table" then
    return default
  end
  local groups = get_keys(getDefaultOptions())
  for group_index, group_key in pairs(groups) do
    if type(loaded[group_key]) == "table" then
      for prop_key, prop_val in pairs(default[group_key]) do
        if loaded[group_key][prop_key] ~= nil then
          result[group_key][prop_key] = loaded[group_key][prop_key]
        end
      end
    end
  end
  for moodle_index, moodle_key in pairs(zeroMoodles) do
    result["MoodleEffects"][moodle_key] = 0
  end
  return result
end

local function optionsCanBeMigrated(current_version)
  local source = tonumber(current_version)
  local target = tonumber(AntibodiesShared.version)
  if source == target then
    return true
  end
  if source > target then
    return false
  end
  for index, version in pairs(AntibodiesShared.noAutoMigrationVersions) do
    local step = tonumber(version)
    if step > source and step <= target then
      return false
    end
  end
  return true
end

local function isOptionsVersionCurrent(options)
  if type(options) ~= "table" then
    return false
  end
  if options["Antibodies"] ~= nil then
    if options["Antibodies"]["version"] ~= nil then
      if optionsCanBeMigrated(options["Antibodies"]["version"]) then
        return true
      end
    end
  end
  return false
end

local function getLocalOptions()
  local options = loadOptions()
  if isOptionsVersionCurrent(options) then
    return mergeOptions(getDefaultOptions(), loadOptions())
  else
    saveOptions(options, "antibodies_options.bk.ini")
    return getDefaultOptions()
  end
end

-----------------------------------------------------
--EXPORTS--------------------------------------------
-----------------------------------------------------

AntibodiesShared.has_value = has_value
AntibodiesShared.has_key = has_key
AntibodiesShared.get_keys = get_keys
AntibodiesShared.lerp = lerp
AntibodiesShared.format_float = format_float
AntibodiesShared.is_number = is_number
AntibodiesShared.clamp = clamp
AntibodiesShared.deepcopy = deepcopy
AntibodiesShared.parse_value = parse_value

AntibodiesShared.printOptions = printOptions
AntibodiesShared.zeroMoodles = zeroMoodles
AntibodiesShared.bodyPartTypes = bodyPartTypes
AntibodiesShared.noAutoMigrationVersions = noAutoMigrationVersions

AntibodiesShared.optionsToString = optionsToString
AntibodiesShared.stringToOptions = stringToOptions
AntibodiesShared.mergeOptions = mergeOptions

AntibodiesShared.hasOptions = hasOptions
AntibodiesShared.applyOptions = applyOptions
AntibodiesShared.getLocalOptions = getLocalOptions
AntibodiesShared.loadOptions = loadOptions
AntibodiesShared.saveOptions = saveOptions
AntibodiesShared.saveHostOptions = saveHostOptions
AntibodiesShared.getDefaultOptions = getDefaultOptions

return AntibodiesShared
