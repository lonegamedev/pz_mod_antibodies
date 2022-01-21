-----------------------------------------------------
--CORE-----------------------------------------------
-----------------------------------------------------

local function cureVirus(player)
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

local function getDamageEffect(player)
  local effect_sum = 0
  local bodyDamage = player:getBodyDamage()
  for i = 0, bodyDamage:getBodyParts():size() - 1 do
    local bodyPart = bodyDamage:getBodyParts():get(i)
    if bodyPart:getWoundInfectionLevel() > 0 then
      effect_sum = effect_sum + (AntibodiesShared.currentOptions.DamageEffects["InfectedWound"] * bodyPart:getWoundInfectionLevel())
    end
  end
  return effect_sum
end

local function getTraitEffect(player)
  local effect_sum = 0
  local traits = player:getTraits()
  for i=0,(traits:size()-1) do 
    local key = traits:get(i)
    if AntibodiesShared.has_key(AntibodiesShared.currentOptions.TraitsEffects, key) then
      effect_sum = effect_sum + AntibodiesShared.currentOptions.TraitsEffects[key]
    end
  end
  return effect_sum
end

local function getMoodleEffect(player)
  local effect_sum = 0
  local moodles = player:getMoodles()
  local count = moodles:getNumMoodles()
  for i = 0, count - 1 do
    local level = moodles:getMoodleLevel(i) 
    local key = tostring(moodles:getMoodleType(i))
    if(AntibodiesShared.has_key(AntibodiesShared.currentOptions.MoodleEffects, key)) then
      local effect = AntibodiesShared.currentOptions.MoodleEffects[key]
      effect_sum = effect_sum + (effect * level)
    end
  end
  return effect_sum
end

local function ensureInitialization(player)
  local save = player:getModData()
  if not AntibodiesShared.is_number(save.virusAntibodiesLevel) then 
    save.virusAntibodiesLevel = 0.0
  end
  if not AntibodiesShared.hasOptions() then
    AntibodiesShared.applyOptions(AntibodiesShared.getOptions())
  end
end

local function getInfectionChangeEveryTenMinutes(player)
  local bodyDamage = player:getBodyDamage()
  local infectionDuration = bodyDamage:getInfectionMortalityDuration()
  if (infectionDuration > 0) then
    return (100 / infectionDuration) / 6  
  end
  return 0
end

local function getAntibodiesGrowth(player, infectionChange)
  local bodyDamage = player:getBodyDamage()
  local moodleEffect = getMoodleEffect(player)
  local damageEffect = getDamageEffect(player)
  local traitEffect = getTraitEffect(player)
  local growthSum = (AntibodiesShared.currentOptions.General.baseAntibodyGrowth + moodleEffect + damageEffect + traitEffect)
  local infectionProgress = (bodyDamage:getInfectionLevel() / 100)
  local growthMax = math.max(0, math.abs(infectionChange) * growthSum)
  return AntibodiesShared.lerp(0.0, growthMax, AntibodiesShared.clamp(math.sin(infectionProgress * math.pi), 0.0, 1.0))
end

local function changeAntibodiesLevel(player, amount)
  local save = player:getModData()
  save.virusAntibodiesLevel = AntibodiesShared.clamp(save.virusAntibodiesLevel + amount, 0, 100)
end

local function getInfectionDelta(player)
	return (player:getModData().virusAntibodiesLevel - player:getBodyDamage():getInfectionLevel())
end

local function consumeInfection(player, infectionDelta, infectionChange)
  local bodyDamage = player:getBodyDamage()

  local infectionTime = bodyDamage:getInfectionTime()
  local infectionDuration = bodyDamage:getInfectionMortalityDuration()
  local healStep = (infectionDelta + infectionChange)

  local newTime = infectionTime + ((healStep / 100) * infectionDuration) 
  local newInfection = AntibodiesShared.clamp(bodyDamage:getInfectionLevel() - healStep, 0, 100)

  bodyDamage:setInfectionTime(newTime)
  bodyDamage:setInfectionLevel(newInfection)

  changeAntibodiesLevel(player, -infectionDelta)

  if(newTime >= player:getHoursSurvived()) then
  	return true --ready to cure
  end
  return false
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
--DEBUG-UTILS----------------------------------------
-----------------------------------------------------

local function indent(num)
  local s = ""
  for i = 0, num - 1 do
    s = s.."    "
  end
  return s
end

local function printDamageEffect(player)
  local damageEffect = getDamageEffect(player)
  print(indent(1).."DamageEffect: "..AntibodiesShared.format_float(damageEffect))
  if AntibodiesShared.currentOptions.Debug["damageEffects"] then
    local bodyDamage = player:getBodyDamage()
    for i = 0, bodyDamage:getBodyParts():size() - 1 do
      local bodyPart = bodyDamage:getBodyParts():get(i)
      if bodyPart:getWoundInfectionLevel() > 0 then
        local effect = AntibodiesShared.currentOptions.DamageEffects["InfectedWound"] * bodyPart:getWoundInfectionLevel()
        print(indent(2)..tostring(bodyPart:getType()).." [InfectedWound("..bodyPart:getWoundInfectionLevel()..")] : "..AntibodiesShared.format_float(effect))
      end
    end
    print(indent(1).."---")
  end
end

local function printTraitEffect(player, breakdown)
  local traitEffect = getTraitEffect(player)
  print(indent(1).."TraitEffect: "..traitEffect)
  if AntibodiesShared.currentOptions.Debug["traitsEffects"] then
    local traits = player:getTraits()
    for i=0,(traits:size()-1) do 
      local key = traits:get(i)
      if AntibodiesShared.has_key(AntibodiesShared.currentOptions.TraitsEffects, key) then
        print(indent(2)..key.." : "..AntibodiesShared.format_float(AntibodiesShared.currentOptions.TraitsEffects[key]))
      end
    end
    print(indent(1).."---")
  end
end

local function printMoodleEffect(player, breakdown)
  local moodleEffect = getMoodleEffect(player)
  print(indent(1).."MoodleEffect: "..AntibodiesShared.format_float(moodleEffect))
  if AntibodiesShared.currentOptions.Debug["moodleEffects"] then
    local moodles = player:getMoodles()
    local c = moodles:getNumMoodles()
    for i=0,(c-1) do 
      if not(moodles:getMoodleLevel(i) == 0) then
        local level = moodles:getMoodleLevel(i) 
        local key = tostring(moodles:getMoodleType(i))
        if(AntibodiesShared.has_key(AntibodiesShared.currentOptions.MoodleEffects, key)) then
          local effect = (AntibodiesShared.currentOptions.MoodleEffects[key] * level)
          print(indent(2)..key.." : Level "..level.." ("..moodles:getMoodleDisplayString(i)..") : "..AntibodiesShared.format_float(effect))
        end         
      end
    end
    print(indent(1).."---")
  end
end

local function printPlayerDebug(player, last)
  local save = player:getModData()
  local bodyDamage = player:getBodyDamage()
  local isInfected = bodyDamage:IsInfected()
  local infectionLevel = bodyDamage:getInfectionLevel()
  local infectionChange = getInfectionChangeEveryTenMinutes(player)
  local antibodiesChange = getAntibodiesGrowth(player, infectionChange)
  local infectionProgress = (infectionLevel / 100)

  print(indent(1).."Player: "..player:getUsername())
  print(indent(1).."IsInfected: "..tostring(isInfected).." ("..AntibodiesShared.format_float(infectionProgress)..")")
  print(indent(1).."Virus/Antibodies: "..AntibodiesShared.format_float(infectionLevel).." ("..AntibodiesShared.format_float(infectionChange)..") / "..AntibodiesShared.format_float(save.virusAntibodiesLevel).." ("..AntibodiesShared.format_float(antibodiesChange)..")")
  printMoodleEffect(player)
  printDamageEffect(player)
  printTraitEffect(player)
end

local function printDebug(players)
  print("( "..AntibodiesShared.modName..":"..AntibodiesShared.version.." )========================>")
  for key, player in ipairs(players) do
    printPlayerDebug(player)
    if key ~= #players then
      print("------------------------")
    end
  end
  print("<========================( Antibodies )")
end

-----------------------------------------------------
--MAIN-----------------------------------------------
-----------------------------------------------------

local function onEveryTenMinutes()
  local players = getLocalPlayers()
  for key, player in ipairs(players) do
    ensureInitialization(player)
    if isClient() then
      sendClientCommand(player, AntibodiesShared.modId, "getOptions", {})
    end
    if player:getBodyDamage():IsInfected() then
      local infectionChange = getInfectionChangeEveryTenMinutes(player)
      local infectionDelta = getInfectionDelta(player)
      if infectionDelta > infectionChange then
        if consumeInfection(player, infectionDelta, infectionChange) then
          cureVirus(player)
        end
      else
        changeAntibodiesLevel(player, getAntibodiesGrowth(player, infectionChange))
      end
    end  
  end
  if AntibodiesShared.currentOptions.Debug["enabled"] then
    printDebug(players)
  end
end
Events.EveryTenMinutes.Add(onEveryTenMinutes)

local function onMainMenuEnter()
  AntibodiesShared.applyOptions(AntibodiesShared.getOptions())
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
  for key, player in ipairs(getLocalPlayers()) do
    sendClientCommand(player, AntibodiesShared.modId, "getOptions", {})
  end
end
Events.OnConnected.Add(onConnected)

local function onDisconnect()
  applyOptions(getOptions())
end
Events.OnDisconnect.Add(onDisconnect)