Antibodies = Antibodies or {}

Antibodies.version = "1.13"
Antibodies.author = "lonegamedev.com"
Antibodies.modName = "Antibodies"

-----------------------------------------------------
--DEBUG----------------------------------------------
-----------------------------------------------------

local DEBUG = true
local DEBUG_BREAKDOWN = {}
DEBUG_BREAKDOWN["MoodleEffects"] = false
DEBUG_BREAKDOWN["DamageEffects"] = false
DEBUG_BREAKDOWN["TraitsEffects"] = false

-----------------------------------------------------
--STATE----------------------------------------------
-----------------------------------------------------

local General = nil
local DamageEffects = nil
local MoodleEffects = nil
local TraitsEffects = nil

local function hasOptions()
  if not General then return false end 
  if not DamageEffects then return false end
  if not MoodleEffects then return false end
  if not TraitsEffects then return false end
  return true
end

-----------------------------------------------------
--UTILS----------------------------------------------
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
--CORE-----------------------------------------------
-----------------------------------------------------

local function cureVirus()
	local player = getPlayer()
	local bodyDamage = player:getBodyDamage()
  for i = 0, bodyDamage:getBodyParts():size() - 1 do
    local bodyPart = bodyDamage:getBodyParts():get(i)
    bodyPart:SetInfected(false)
  end
  bodyDamage:setInf(false)
  bodyDamage:setInfectionLevel(0)
  bodyDamage:setInfectionTime(-1.0)
  bodyDamage:setInfectionMortalityDuration(-1.0)
  player:getModData().virusAntibodiesLevel = 0.0
end

local function getDamageEffect()
  local effect_sum = 0
  local player = getPlayer()
  local bodyDamage = player:getBodyDamage()
  for i = 0, bodyDamage:getBodyParts():size() - 1 do
    local bodyPart = bodyDamage:getBodyParts():get(i)
    if bodyPart:getWoundInfectionLevel() > 0 then
      effect_sum = effect_sum + (DamageEffects["InfectedWound"] * bodyPart:getWoundInfectionLevel())
    end
  end
  return effect_sum
end

local function getTraitEffect()
  local effect_sum = 0
  local traits = getPlayer():getTraits()
  for i=0,(traits:size()-1) do 
    local key = traits:get(i)
    if has_key(TraitsEffects, key) then
      effect_sum = effect_sum + TraitsEffects[key]
    end
  end
  return effect_sum
end

local function getMoodleEffect()
  local effect_sum = 0
  local moodles = getPlayer():getMoodles()
  local count = moodles:getNumMoodles()
  for i = 0, count - 1 do
    local level = moodles:getMoodleLevel(i) 
    local key = tostring(moodles:getMoodleType(i))
    if(has_key(MoodleEffects, key)) then
      local effect = MoodleEffects[key]
      effect_sum = effect_sum + (effect * level)
    end
  end
  return effect_sum
end

local function ensureInitialization()
  local save = getPlayer():getModData()
  if not is_number(save.virusAntibodiesLevel) then 
    save.virusAntibodiesLevel = 0.0
  end
end

local function getInfectionChangeEveryTenMinutes()
  local bodyDamage = getPlayer():getBodyDamage()
  local infectionDuration = bodyDamage:getInfectionMortalityDuration()
  if (infectionDuration > 0) then
    return (100 / infectionDuration) / 6  
  end
  return 0
end

local function getAntibodiesGrowth(infectionChange)
  local bodyDamage = getPlayer():getBodyDamage()
  local moodleEffect = getMoodleEffect()
  local damageEffect = getDamageEffect()
  local traitEffect = getTraitEffect()
  local growthSum = (General.baseAntibodyGrowth + moodleEffect + damageEffect + traitEffect)
  local infectionProgress = (bodyDamage:getInfectionLevel() / 100)
  local growthMax = math.max(0, math.abs(infectionChange) * growthSum)
  return lerp(0.0, growthMax, clamp(math.sin(infectionProgress * math.pi), 0.0, 1.0))
end

local function changeAntibodiesLevel(amount)
  local save = getPlayer():getModData()
  save.virusAntibodiesLevel = clamp(save.virusAntibodiesLevel + amount, 0, 100)
end

local function getInfectionDelta()
  local player = getPlayer()
	return (player:getModData().virusAntibodiesLevel - player:getBodyDamage():getInfectionLevel())
end

local function consumeInfection(infectionDelta, infectionChange)
  local player = getPlayer()
  local bodyDamage = player:getBodyDamage()

  local infectionTime = bodyDamage:getInfectionTime()
  local infectionDuration = bodyDamage:getInfectionMortalityDuration()
  local healStep = (infectionDelta + infectionChange)

  local newTime = infectionTime + ((healStep / 100) * infectionDuration) 
  local newInfection = clamp(bodyDamage:getInfectionLevel() - healStep, 0, 100)

  bodyDamage:setInfectionTime(newTime)
  bodyDamage:setInfectionLevel(newInfection)

  changeAntibodiesLevel(-infectionDelta)

  if(newTime >= player:getHoursSurvived()) then
  	return true --ready to cure
  end
  return false
end

-----------------------------------------------------
--OPTIONS--------------------------------------------
-----------------------------------------------------

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
    if(options["Antibodies"]["version"] ~= Antibodies.version) then
      return false
    end
  else
    return false
  end
  if(options["General"] ~= nil) then
    for k,v in pairs(General) do
      if(options["General"][k] ~= nil) then
        General[k] = options["General"][k]
      end
    end
  end
  if(options["MoodleEffects"] ~= nil) then
    for k,v in pairs(MoodleEffects) do
      if(options["MoodleEffects"][k] ~= nil) then
        MoodleEffects[k] = options["MoodleEffects"][k]
      end
    end
  end
  if(options["DamageEffects"] ~= nil) then
    for k,v in pairs(DamageEffects) do
      if(options["DamageEffects"][k] ~= nil) then
        DamageEffects[k] = options["DamageEffects"][k]
      end
    end
  end
  if(options["TraitsEffects"] ~= nil) then
    for k,v in pairs(TraitsEffects) do
      if(options["TraitsEffects"][k] ~= nil) then
        TraitsEffects[k] = options["TraitsEffects"][k]
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
      if(options["Antibodies"]["version"] == Antibodies.version) then
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

local function getOptions()
  if not hasOptions() then
    local default = getOptionsPreset()
    General = default["General"]
    DamageEffects = default["DamageEffects"]
    MoodleEffects = default["MoodleEffects"]
    TraitsEffects = default["TraitsEffects"]
    applyOptions(loadOptions())
  end
  local options = {}
  options["Antibodies"] = {}
  options["Antibodies"]["version"] = Antibodies.version
  options["Antibodies"]["author"] = Antibodies.author
  options["Antibodies"]["modName"] = Antibodies.modName
  options["General"] = deepcopy(General)
  options["MoodleEffects"] = deepcopy(MoodleEffects)
  options["DamageEffects"] = deepcopy(DamageEffects)
  options["TraitsEffects"] = deepcopy(TraitsEffects)
  return options
end

-----------------------------------------------------
--DEBUG-UTILS----------------------------------------
-----------------------------------------------------

local function indent(num)
  local s = ""
  for i = 0, num - 1 do
    s = s.."    "
  end
  return s
end

local function printDamageEffect()
  local damageEffect = getDamageEffect()
  print(indent(1).."DamageEffect: "..format_float(damageEffect))
  if DEBUG_BREAKDOWN["DamageEffects"] then
    local bodyDamage = getPlayer():getBodyDamage()
    for i = 0, bodyDamage:getBodyParts():size() - 1 do
      local bodyPart = bodyDamage:getBodyParts():get(i)
      if bodyPart:getWoundInfectionLevel() > 0 then
        local effect = DamageEffects["InfectedWound"] * bodyPart:getWoundInfectionLevel()
        print(indent(2)..tostring(bodyPart:getType()).." [InfectedWound("..bodyPart:getWoundInfectionLevel()..")] : "..format_float(effect))
      end
    end
    print(indent(1).."---")
  end
end

local function printTraitEffect(breakdown)
  local traitEffect = getTraitEffect()
  print(indent(1).."TraitEffect: "..traitEffect)
  if DEBUG_BREAKDOWN["TraitsEffects"] then
    local traits = getPlayer():getTraits()
    for i=0,(traits:size()-1) do 
      local key = traits:get(i)
      if has_key(TraitsEffects, key) then
        print(indent(2)..key.." : "..format_float(TraitsEffects[key]))
      end
    end
    print(indent(1).."---")
  end
end

local function printMoodleEffect(breakdown)
  local moodleEffect = getMoodleEffect()
  print(indent(1).."MoodleEffect: "..format_float(moodleEffect))
  if DEBUG_BREAKDOWN["MoodleEffects"] then
    local moodles = getPlayer():getMoodles()
    local c = moodles:getNumMoodles()
    for i=0,(c-1) do 
      if not(moodles:getMoodleLevel(i) == 0) then
        local level = moodles:getMoodleLevel(i) 
        local key = tostring(moodles:getMoodleType(i))
        if(has_key(MoodleEffects, key)) then
          local effect = (MoodleEffects[key] * level)
          print(indent(2)..key.." : Level "..level.." ("..moodles:getMoodleDisplayString(i)..") : "..format_float(effect))
        end         
      end
    end
    print(indent(1).."---")
  end
end

local function printDebug()
  local player = getPlayer()
  local save = player:getModData()
  local bodyDamage = player:getBodyDamage()
  local isInfected = bodyDamage:IsInfected()
  local infectionLevel = bodyDamage:getInfectionLevel()
  local infectionChange = getInfectionChangeEveryTenMinutes()
  local antibodiesChange = getAntibodiesGrowth(infectionChange)
  local infectionProgress = (infectionLevel / 100)

  print("[ Antibodies ]========================>")
  print(indent(1).."IsInfected: "..tostring(isInfected).." ("..format_float(infectionProgress)..")")
  print(indent(1).."Virus/Antibodies: "..format_float(infectionLevel).." ("..format_float(infectionChange)..") / "..format_float(save.virusAntibodiesLevel).." ("..format_float(antibodiesChange)..")")
  printMoodleEffect()
  printDamageEffect()
  printTraitEffect()
  print("<========================[ Antibodies ]")
end

-----------------------------------------------------
--MAIN-----------------------------------------------
-----------------------------------------------------

local function onEveryTenMinutes()
  ensureInitialization()
  if getPlayer():getBodyDamage():IsInfected() then
    local infectionChange = getInfectionChangeEveryTenMinutes()
    local infectionDelta = getInfectionDelta()
    if infectionDelta > infectionChange then
    	if consumeInfection(infectionDelta, infectionChange) then
        cureVirus()
      end
    else
	  	changeAntibodiesLevel(getAntibodiesGrowth(infectionChange))
    end
  end  
  if DEBUG then
    printDebug()
  end
end

Events.EveryTenMinutes.Add(onEveryTenMinutes)

Events.OnMainMenuEnter.Add(function()
  getOptions() --make sure options are loaded
end)

Antibodies.applyOptions = applyOptions
Antibodies.getOptions = getOptions
Antibodies.loadOptions = loadOptions
Antibodies.saveOptions = saveOptions
Antibodies.getOptionsPreset = getOptionsPreset

return Antibodies