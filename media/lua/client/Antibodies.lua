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

local function getInfectionsCount(player)
  local result = { ["virus"] = 0, ["regular"] = 0 }
  local bodyDamage = player:getBodyDamage()
  for i = 0, bodyDamage:getBodyParts():size() - 1 do
    local bodyPart = bodyDamage:getBodyParts():get(i)
    if bodyPart:isInfectedWound() then
      result.regular = result.regular + 1
    end
    if bodyPart:IsInfected() then
      result.virus = result.virus + 1
    end
  end
  return result
end

local function getInfectionsEffect(player)
  local effect_sum = 0
  local infections = getInfectionsCount(player)
  return infections.virus * AntibodiesShared.currentOptions.InfectionEffects["virus"] +
         infections.regular * AntibodiesShared.currentOptions.InfectionEffects["regular"]
end

local function getBodyPartMod(bodyPart)
  local mod = 0.0
  if bodyPart:bandaged() and not bodyPart:isBandageDirty() then
    return mod
  end
  if bodyPart:getDeepWoundTime() > 0 then
    mod = mod + AntibodiesShared.currentOptions.HygineEffects["modDeepWounded"]
  end
  if bodyPart:getBiteTime() > 0 then
    mod = mod + AntibodiesShared.currentOptions.HygineEffects["modBitten"]
  end
  if bodyPart:getCutTime() > 0 then
    mod = mod + AntibodiesShared.currentOptions.HygineEffects["modCut"]
  end
  if bodyPart:getScratchTime() > 0 then
    mod = mod + AntibodiesShared.currentOptions.HygineEffects["modScratched"]
  end
  if bodyPart:getBurnTime() > 0 then
    mod = mod + AntibodiesShared.currentOptions.HygineEffects["modBurnt"]
  end
  if bodyPart:isNeedBurnWash() then
    mod = mod + AntibodiesShared.currentOptions.HygineEffects["modNeedBurnWash"]
  end
  if bodyPart:getStitchTime() > 0 then
    mod = mod + AntibodiesShared.currentOptions.HygineEffects["modStiched"]        
  end
  if bodyPart:haveBullet() then
    mod = mod + AntibodiesShared.currentOptions.HygineEffects["modHaveBullet"]
  end
  if bodyPart:haveGlass() then
    mod = mod + AntibodiesShared.currentOptions.HygineEffects["modHaveGlass"]
  end
  if bodyPart:getBleedingTime() > 0 then
    mod = mod + AntibodiesShared.currentOptions.HygineEffects["modBleeding"]
  end
  return mod
end

local function coversBodyPart(clothing, bloodBodyPartType)
  local parts = clothing:getCoveredParts()
  for i=0, parts:size()-1 do
    if parts:get(i)==bloodBodyPartType then
      return true
    end
  end
  return false
end

local function getClothingHygiene(player, bloodBodyPartType)
  local wornItems = player:getWornItems()
  local result = { ["blood"] = 0.0, ["dirt"] = 0.0 }
  if wornItems then
    if wornItems:size() > 0 then
      for index=0, wornItems:size()-1 do
        local clothing = wornItems:getItemByIndex(index)
        if clothing then
          if coversBodyPart(clothing, bloodBodyPartType) then
            result.blood = math.max(result.blood, clothing:getBloodlevel() / 100)
            result.dirt = math.max(result.dirt, clothing:getDirtyness() / 100)
          end
        end
      end
    end
  end  
  return result
end

local function getHygieneEffect(player)
  local hygieneEffect = 0.0
  local bodyDamage = player:getBodyDamage()
  local humanVisual = player:getHumanVisual()
  for part_index, part_key in pairs(AntibodiesShared.bodyPartTypes) do
    local bodyPartType = BodyPartType.FromString(part_key)
    if bodyPartType ~= BodyPartType.MAX then
      local bodyPart = bodyDamage:getBodyPart(bodyPartType)
      if bodyPart then
        local bodyPartMod = getBodyPartMod(bodyPart)
        if bodyPartMod > 0.0 then
          local bloodBodyPartType = BloodBodyPartType.FromString(part_key)
          local bloodDirt = getClothingHygiene(player, bloodBodyPartType)
          bloodDirt.blood = math.max(bloodDirt.blood, humanVisual:getBlood(bloodBodyPartType))
          bloodDirt.dirt = math.max(bloodDirt.dirt, humanVisual:getDirt(bloodBodyPartType))
          hygieneEffect = hygieneEffect + (bloodDirt.blood * bodyPartMod * AntibodiesShared.currentOptions.HygineEffects["bloodEffect"])
          hygieneEffect = hygieneEffect + (bloodDirt.dirt * bodyPartMod * AntibodiesShared.currentOptions.HygineEffects["dirtEffect"])
        end
      end
    end
  end
  return hygieneEffect
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
    AntibodiesShared.applyOptions(AntibodiesShared.getLocalOptions())
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
  local traitEffect = getTraitEffect(player)
  local hygineEffect = getHygieneEffect(player)
  local infectionEffect = getInfectionsEffect(player)
  local growthSum = (AntibodiesShared.currentOptions.General.baseAntibodyGrowth + moodleEffect + traitEffect + hygineEffect + infectionEffect)
  local infectionProgress = (bodyDamage:getInfectionLevel() / 100)
  local growthMax = math.max(0, math.abs(infectionChange) * growthSum)
  return AntibodiesShared.lerp(0.0, growthMax, AntibodiesShared.clamp(math.sin(infectionProgress * math.pi), 0.0, 1.0))
end

local function setAntibodiesLevel(player, value)
  local save = player:getModData()
  save.virusAntibodiesLevel = AntibodiesShared.clamp(value, 0, 100)
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

local function printTraitEffect(player)
  local traitEffect = getTraitEffect(player)
  print(indent(1).."TraitEffect: "..AntibodiesShared.format_float(traitEffect))
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

local function printMoodleEffect(player)
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

local function printInfectionsEffect(player)
  local infectionEffects = getInfectionsEffect(player)
  print(indent(1).."InfectionEffects: "..AntibodiesShared.format_float(infectionEffects))
  if AntibodiesShared.currentOptions.Debug["infectionEffects"] then
    local infections = getInfectionsCount(player)
    print(indent(2).."virus infected body parts: "..tostring(infections.virus))
    print(indent(2).."regular infected body parts: "..tostring(infections.regular))
    print(indent(1).."---")
  end
end

local function printHygieneEffect(player)
  local hygineEffect = getHygieneEffect(player)
  print(indent(1).."HygieneEffect: "..AntibodiesShared.format_float(hygineEffect))
  --print(indent(1).."---")
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
  printInfectionsEffect(player)
  printHygieneEffect(player)
  printMoodleEffect(player)
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
    else
      setAntibodiesLevel(player, 0)
    end 
  end
  if AntibodiesShared.currentOptions.Debug["enabled"] then
    printDebug(players)
  end
end
Events.EveryTenMinutes.Add(onEveryTenMinutes)

local function onMainMenuEnter()
  AntibodiesShared.applyOptions(AntibodiesShared.getLocalOptions())
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
  applyOptions(getLocalOptions())
end
Events.OnDisconnect.Add(onDisconnect)