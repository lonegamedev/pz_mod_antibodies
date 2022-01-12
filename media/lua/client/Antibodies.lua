-----------------------------------------------------
--DEBUG----------------------------------------------
-----------------------------------------------------

local DEBUG = true
local DEBUG_BREAKDOWN = {}
DEBUG_BREAKDOWN["MoodleEffects"] = false
DEBUG_BREAKDOWN["DamageEffects"] = false
DEBUG_BREAKDOWN["TraitsEffects"] = false

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
      effect_sum = effect_sum + (AntibodiesShared.DamageEffects["InfectedWound"] * bodyPart:getWoundInfectionLevel())
    end
  end
  return effect_sum
end

local function getTraitEffect()
  local effect_sum = 0
  local traits = getPlayer():getTraits()
  for i=0,(traits:size()-1) do 
    local key = traits:get(i)
    if AntibodiesShared.has_key(AntibodiesShared.TraitsEffects, key) then
      effect_sum = effect_sum + AntibodiesShared.TraitsEffects[key]
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
    if(AntibodiesShared.has_key(AntibodiesShared.MoodleEffects, key)) then
      local effect = AntibodiesShared.MoodleEffects[key]
      effect_sum = effect_sum + (effect * level)
    end
  end
  return effect_sum
end

local function ensureInitialization()
  local save = getPlayer():getModData()
  if not AntibodiesShared.is_number(save.virusAntibodiesLevel) then 
    save.virusAntibodiesLevel = 0.0
  end
  if not AntibodiesShared.hasOptions() then
    AntibodiesShared.applyOptions(AntibodiesShared.getCurrentOptions())
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
  local growthSum = (AntibodiesShared.General.baseAntibodyGrowth + moodleEffect + damageEffect + traitEffect)
  local infectionProgress = (bodyDamage:getInfectionLevel() / 100)
  local growthMax = math.max(0, math.abs(infectionChange) * growthSum)
  return AntibodiesShared.lerp(0.0, growthMax, AntibodiesShared.clamp(math.sin(infectionProgress * math.pi), 0.0, 1.0))
end

local function changeAntibodiesLevel(amount)
  local save = getPlayer():getModData()
  save.virusAntibodiesLevel = AntibodiesShared.clamp(save.virusAntibodiesLevel + amount, 0, 100)
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
  local newInfection = AntibodiesShared.clamp(bodyDamage:getInfectionLevel() - healStep, 0, 100)

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
  print(indent(1).."DamageEffect: "..AntibodiesShared.format_float(damageEffect))
  if DEBUG_BREAKDOWN["DamageEffects"] then
    local bodyDamage = getPlayer():getBodyDamage()
    for i = 0, bodyDamage:getBodyParts():size() - 1 do
      local bodyPart = bodyDamage:getBodyParts():get(i)
      if bodyPart:getWoundInfectionLevel() > 0 then
        local effect = AntibodiesShared.DamageEffects["InfectedWound"] * bodyPart:getWoundInfectionLevel()
        print(indent(2)..tostring(bodyPart:getType()).." [InfectedWound("..bodyPart:getWoundInfectionLevel()..")] : "..AntibodiesShared.format_float(effect))
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
      if AntibodiesShared.has_key(AntibodiesShared.TraitsEffects, key) then
        print(indent(2)..key.." : "..AntibodiesShared.format_float(AntibodiesShared.TraitsEffects[key]))
      end
    end
    print(indent(1).."---")
  end
end

local function printMoodleEffect(breakdown)
  local moodleEffect = getMoodleEffect()
  print(indent(1).."MoodleEffect: "..AntibodiesShared.format_float(moodleEffect))
  if DEBUG_BREAKDOWN["MoodleEffects"] then
    local moodles = getPlayer():getMoodles()
    local c = moodles:getNumMoodles()
    for i=0,(c-1) do 
      if not(moodles:getMoodleLevel(i) == 0) then
        local level = moodles:getMoodleLevel(i) 
        local key = tostring(moodles:getMoodleType(i))
        if(AntibodiesShared.has_key(AntibodiesShared.MoodleEffects, key)) then
          local effect = (AntibodiesShared.MoodleEffects[key] * level)
          print(indent(2)..key.." : Level "..level.." ("..moodles:getMoodleDisplayString(i)..") : "..AntibodiesShared.format_float(effect))
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
  print(indent(1).."IsInfected: "..tostring(isInfected).." ("..AntibodiesShared.format_float(infectionProgress)..")")
  print(indent(1).."Virus/Antibodies: "..AntibodiesShared.format_float(infectionLevel).." ("..AntibodiesShared.format_float(infectionChange)..") / "..AntibodiesShared.format_float(save.virusAntibodiesLevel).." ("..AntibodiesShared.format_float(antibodiesChange)..")")
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

  if isClient() then
    sendClientCommand(getPlayer(), AntibodiesShared.modId, "getOptions", {})
  end

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

local function onMainMenuEnter()
  AntibodiesShared.applyOptions(AntibodiesShared.getCurrentOptions())
end
Events.OnMainMenuEnter.Add(onMainMenuEnter)

local function onServerCommand(module, command, args)
  if isClient() then
    if module == AntibodiesShared.modId then
      if command == "postOptions" then
        AntibodiesShared.applyOptions(args)
      end
    end
  end
end
Events.OnServerCommand.Add(onServerCommand)

local function onConnected()
  sendClientCommand(getPlayer(), AntibodiesShared.modId, "getOptions", {})
end
Events.OnConnected.Add(onConnected)

local function onDisconnect()
  local default = getOptionsPreset()
  AntibodiesShared.General = default["General"]
  AntibodiesShared.DamageEffects = default["DamageEffects"]
  AntibodiesShared.MoodleEffects = default["MoodleEffects"]
  AntibodiesShared.TraitsEffects = default["TraitsEffects"]
  applyOptions(loadOptions())
end
Events.OnDisconnect.Add(onDisconnect)