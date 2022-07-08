AntibodiesShared = {}
AntibodiesShared.__index = AntibodiesShared

-----------------------------------------------------
--CONST----------------------------------------------
-----------------------------------------------------

AntibodiesShared.version = "1.50"
AntibodiesShared.author = "lonegamedev.com"
AntibodiesShared.modName = "Antibodies"
AntibodiesShared.modId = "lgd_antibodies"

local bodyPartTypes = {"Back", "Foot_L", "Foot_R", "ForeArm_L", "ForeArm_R", "Groin", 
"Hand_L", "Hand_R", "Head", "LowerLeg_L", "LowerLeg_R", "Neck", "Torso_Lower", 
"Torso_Upper", "UpperArm_L", "UpperArm_R", "UpperLeg_L", "UpperLeg_R"}

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

local function deep_copy(val)
  local val_copy
  if type(val) == 'table' then
      val_copy = {}
      for k,v in pairs(val) do
        val_copy[k] = deep_copy(v)
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

local function to_camel_case(str)
  local len = string.len(str)
  if len < 1 then
    return str
  end
  local a = string.sub(str, 1, 1)
  local b = string.sub(str, 2, len)
  a = string.lower(a)
  return a..b
end

local function indent(num)
  local s = ""
  for i = 0, num - 1 do
    s = s.."    "
  end
  return s
end

-----------------------------------------------------
--OPTIONS--------------------------------------------
-----------------------------------------------------

local function hasOptions()
  return AntibodiesShared.currentOptions ~= nil
end

local function getDefaultOptions()
  return {
    ["general"] = {
      ["baseAntibodyGrowth"] = 1.6
    },
    ["wounds"] = {
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
      ["virusScratch"] = -0.01,
      ["virusCut"] = -0.025,
      ["virusBite"] = -0.05,
    },
    ["hygiene"] = {
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
    ["moodles"] = {
      ["bleeding"] = -0.1,
      
      ["thirst"] = -0.04,
      ["hungry"] = -0.03,
      ["sick"] = -0.02,
      ["hasACold"] = -0.02,
      ["pain"] = -0.01,
      ["tired"] = -0.01,
      ["endurance"] = -0.01,      

      ["panic"] = -0.01,
      ["stress"] = -0.01,
      ["unhappy"] = -0.01,
      ["bored"] = -0.01,
      
      ["hyperthermia"] = 0.01,
      ["hypothermia"] = -0.1,
      ["windchill"] = -0.01,
      ["wet"] = -0.01,
      ["heavyLoad"] = -0.01,

      ["drunk"] = 0.01,
      ["foodEaten"] = 0.05,

      ["injured"] = 0.0,      
      ["dead"] = 0.0,
      ["zombie"] = 0.0,
      ["angry"] = 0.0
    },
    ["traits"] = {
      ["asthmatic"] = -0.01,
      ["smoker"] = -0.01,
      
      ["unfit"] = -0.02,
      ["outOfShape"] = -0.01,
      ["athletic"] = 0.01,
    
      ["slowHealer"] = -0.01,
      ["fastHealer"] = 0.01,
      
      ["proneToIllness"] = -0.01,
      ["resilient"] = 0.01,
    
      ["weak"] = -0.02,
      ["feeble"] = -0.01,
      ["strong"] = 0.01,
      ["stout"] = 0.02,
    
      ["emaciated"] = -0.02,
      ["veryUnderweight"] = -0.01,
      ["underweight"] = -0.005,
      ["overweight"] = -0.005,
      ["obese"] = -0.02,

      ["lucky"] = 0.0,
      ["unlucky"] = 0.0
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
end

local function versionToString(version)
  return tostring(version * 100)
end

local function getSandboxOptions()
  local result = {}
  local defaults = getDefaultOptions()
  for group_index, group_key in pairs(get_keys(defaults)) do
    result[group_key] = {}
    for prop_index, prop_key in pairs(get_keys(defaults[group_key])) do
      local path = ""..AntibodiesShared.modId.."."..versionToString(AntibodiesShared.version).."."..group_key.."."..prop_key
      if has_key(SandboxVars, path) then
        result[group_key][prop_key] = SandboxVars[path]
      end
    end
  end
  return result
end

local function applyOptions(options)
  if (type(options) ~= "table") then
    return false
  end
  AntibodiesShared.currentOptions = deep_copy(options)
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

local function mergeOptions(default, loaded)
  local result = deep_copy(default)
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
  return result
end

local function getOptions()
  return mergeOptions(getDefaultOptions(), getSandboxOptions())
end

local function getLocalPlayers()
  local result = {}
  for playerIndex = 0, getNumActivePlayers()-1 do
    local player = getSpecificPlayer(playerIndex)
    if player ~= nil then
      if player:isLocalPlayer() then
        table.insert(result, player)
      end
    end
  end
  return result
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
AntibodiesShared.deep_copy = deep_copy
AntibodiesShared.parse_value = parse_value
AntibodiesShared.to_camel_case = to_camel_case
AntibodiesShared.indent = indent

AntibodiesShared.printOptions = printOptions
AntibodiesShared.bodyPartTypes = bodyPartTypes

AntibodiesShared.optionsToString = optionsToString
AntibodiesShared.stringToOptions = stringToOptions
AntibodiesShared.mergeOptions = mergeOptions

AntibodiesShared.hasOptions = hasOptions
AntibodiesShared.applyOptions = applyOptions
AntibodiesShared.getOptions = getOptions
AntibodiesShared.getDefaultOptions = getDefaultOptions
AntibodiesShared.getSandboxOptions = getSandboxOptions
AntibodiesShared.getLocalPlayers = getLocalPlayers

return AntibodiesShared
