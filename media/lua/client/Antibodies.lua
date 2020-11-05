Antibodies = {}
Antibodies.version = "1.1"
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
--BALANCE--------------------------------------------
-----------------------------------------------------

--base antibody growth per infection unit
local BaseAntibodyGrowth = 1.6

-----------------------------------------------------

--multiplied by effect level 0-4
local MoodleEffects = {}

MoodleEffects["Bleeding"] = -0.1
MoodleEffects["Hypothermia"] = -0.1
MoodleEffects["Injured"] = 0.0

MoodleEffects["Thirst"] = -0.04
MoodleEffects["Hungry"] = -0.03
MoodleEffects["Sick"] = -0.02
MoodleEffects["HasACold"] = -0.02

MoodleEffects["Tired"] = -0.01
MoodleEffects["Endurance"] = -0.01
MoodleEffects["Pain"] = -0.01
MoodleEffects["Wet"] = -0.01
MoodleEffects["HeavyLoad"] = -0.01
MoodleEffects["Windchill"] = -0.01

MoodleEffects["Panic"] = -0.01
MoodleEffects["Stress"] = -0.01
MoodleEffects["Unhappy"] = -0.01
MoodleEffects["Bored"] = -0.01

MoodleEffects["Hyperthermia"] = 0.01
MoodleEffects["Drunk"] = 0.01
MoodleEffects["FoodEaten"] = 0.05

MoodleEffects["Dead"] = 0.0
MoodleEffects["Zombie"] = 0.0
MoodleEffects["Angry"] = 0.0

-----------------------------------------------------

local DamageEffects = {}
--per bodyPart, multiplied by infection level
DamageEffects["InfectedWound"] = -0.001

-----------------------------------------------------

local TraitsEffects = {}

TraitsEffects["Asthmatic"] = -0.01
TraitsEffects["Smoker"] = -0.01

TraitsEffects["Unfit"] = -0.02
TraitsEffects["Out of Shape"] = -0.01
TraitsEffects["Athletic"] = 0.01

TraitsEffects["SlowHealer"] = -0.01
TraitsEffects["FastHealer"] = 0.01

TraitsEffects["ProneToIllness"] = -0.01
TraitsEffects["Resilient"] = 0.01

TraitsEffects["Weak"] = -0.02
TraitsEffects["Feeble"] = -0.01
TraitsEffects["Strong"] = 0.01
TraitsEffects["Stout"] = 0.02

TraitsEffects["Emaciated"] = -0.02
TraitsEffects["Very Underweight"] = -0.01
TraitsEffects["Underweight"] = 0.005
TraitsEffects["Overweight"] = 0.005
TraitsEffects["Obese"] = -0.02

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
  local growthSum = (BaseAntibodyGrowth + moodleEffect + damageEffect + traitEffect)
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

  print("[ VirusAntibodies ]========================>")
  print(indent(1).."IsInfected: "..tostring(isInfected).." ("..format_float(infectionProgress)..")")
  print(indent(1).."Virus/Antibodies: "..format_float(infectionLevel).." ("..format_float(infectionChange)..") / "..format_float(save.virusAntibodiesLevel).." ("..format_float(antibodiesChange)..")")
  printMoodleEffect()
  printDamageEffect()
  printTraitEffect()
  print("<========================[ VirusAntibodies ]")
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