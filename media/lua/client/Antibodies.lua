BetterZombification = {}
BetterZombification.version = "1.0"
BetterZombification.author = "lonegamedev.com"
BetterZombification.modName = "Better Zombificiation"

local BaseAntibodyGrowth = 1.5

local MoodleEffects = {}
MoodleEffects.Endurance = {0.0000, -0.0250, -0.0500, -0.1000, -0.2000}
MoodleEffects.Tired = {0.0000, -0.0500, -0.1000, -0.2000, -0.3000}
MoodleEffects.Hungry = {0.0000, -0.0250, -0.0500, -0.1000, -0.2000}
MoodleEffects.Panic = {0.0000, -0.0250, -0.0500, -0.1000, -0.2000}
MoodleEffects.Sick = {0.0000, -0.1000, -0.2000, -0.3000, -0.4000}
MoodleEffects.Bored = {0.0000, -0.0100, -0.0200, -0.0300, -0.0400}
MoodleEffects.Unhappy = {0.0000, -0.0100, -0.0200, -0.0300, -0.0400}
MoodleEffects.Bleeding = {0.0000,- 0.1000, -0.2000, -0.4000, -0.8000}
MoodleEffects.Wet = {0.0000, -0.0100, -0.0250, -0.0500, -0.1000}
MoodleEffects.HasACold = {0.0000, -0.0100, -0.0250, -0.0500, -0.1000}
MoodleEffects.Angry = {0.0000, 0.0000, 0.0000, 0.0000, 0.0000}
MoodleEffects.Stress = {0.0000, -0.0010, -0.0050, -0.0100, -0.0200}
MoodleEffects.Thirst = {0.0000, -0.0010, -0.0050, -0.0100, -0.0200}
MoodleEffects.Injured = {0.0000, -0.0100, -0.0200, -0.0500, -0.1000}
MoodleEffects.Pain = {0.0000, -0.0100, -0.0200, -0.0500, -0.1000}
MoodleEffects.HeavyLoad = {0.0000, -0.0100, -0.0200, -0.0500, -0.1000}
MoodleEffects.Drunk = {0.0000, 0.0100, 0.0000, -0.1000, -0.2000}
MoodleEffects.Dead = {0.0000, 0.0000, 0.0000, 0.0000, 0.0000}
MoodleEffects.Zombie = {0.0000, 0.0000, 0.0000, 0.0000, 0.0000}
MoodleEffects.Hyperthermia = {0.0000, -0.1000, -0.2000, -0.4000, -0.8000}
MoodleEffects.Hypothermia = {0.0000, -0.1000, -0.2000, -0.4000, -0.8000}
MoodleEffects.Windchill = {0.0000, -0.0100, -0.0250, -0.0500, -0.1000}
MoodleEffects.FoodEaten = {0.0000, 0.0100, 0.0250, 0.0500, 0.1000}

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

local function cureVirus()
	local player = getPlayer()
	local bodyDamage = player:getBodyDamage()
  for i = 0, bodyDamage:getBodyParts():size() - 1 do
    local bodyPart = bodyDamage:getBodyParts():get(i)
    bodyPart:SetInfected(false)
  end
  bodyDamage:setInfectionTime(player:getHoursSurvived())
  bodyDamage:setInfectionLevel(0)
  bodyDamage:setInf(false)
  player:getModData().virusAntibodiesLevel = 0.0
end

local function getMoodlesEffect()
  local effect_sum = 0
  local moodles = getPlayer():getMoodles()
  local count = moodles:getNumMoodles()
  for i = 0, count - 1 do
    local level = moodles:getMoodleLevel(i) 
    local key = tostring(moodles:getMoodleType(i))
    if(has_key(MoodleEffects, key)) then
      local effect = MoodleEffects[key]
      if(has_key(effect, level)) then
        effect_sum = effect_sum + effect[level]
      end
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
  local moodlesEffect = getMoodlesEffect();
  local infectionProgress = (bodyDamage:getInfectionLevel() / 100)
  local growthMax = math.max(0, math.abs(infectionChange) * (BaseAntibodyGrowth + moodlesEffect))
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

local function printDebug(moodlesEffectBreakdown)
  local player = getPlayer()
  local save = player:getModData()
  local bodyDamage = player:getBodyDamage()
  local isInfected = bodyDamage:IsInfected()
  local infectionLevel = bodyDamage:getInfectionLevel()
  local infectionChange = getInfectionChangeEveryTenMinutes()
  local antibodiesChange = getAntibodiesGrowth(infectionChange)
  local moodlesEffect = getMoodlesEffect()
  local infectionProgress = (infectionLevel / 100)

  print("[ VirusAntibodies ]========================>")
  print("IsInfected: "..tostring(isInfected).." ("..format_float(infectionProgress)..")")
  print("Virus/Antibodies: "..format_float(infectionLevel).." ("..format_float(infectionChange)..") / "..format_float(save.virusAntibodiesLevel).." ("..format_float(antibodiesChange)..")")
  print("MoodleEffect: "..moodlesEffect)
  if moodlesEffectBreakdown == true then
	  print("MoodleEffect breakdown:") 
  	local moodles = player:getMoodles()
  	local c = moodles:getNumMoodles()
  	for i=0,(c-1) do 
    	if not(moodles:getMoodleLevel(i) == 0) then
      	print(tostring(moodles:getMoodleType(i)).." : "..moodles:getMoodleLevel(i).." : "..moodles:getMoodleDisplayString(i).." : "..moodles:getGoodBadNeutral(i))
    	end
  	end
  end
  print("<========================[ VirusAntibodies ]")
end

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
  printDebug()
end

Events.EveryTenMinutes.Add(onEveryTenMinutes)