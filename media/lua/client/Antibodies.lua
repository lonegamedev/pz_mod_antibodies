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
  local result = { 
    ["virusScratch"] = 0, 
    ["virusCut"] = 0, 
    ["virusBite"] = 0, 
    ["regular"] = 0 
  }
  local bodyDamage = player:getBodyDamage()
  for i = 0, bodyDamage:getBodyParts():size() - 1 do
    local bodyPart = bodyDamage:getBodyParts():get(i)
    if bodyPart:isInfectedWound() then
      result.regular = result.regular + 1
    end
    if bodyPart:IsInfected() then
      if bodyPart:getBiteTime() > 0 then
        result.virusBite = result.virusBite + 1
      end
      if bodyPart:getCutTime() > 0 then
        result.virusCut = result.virusCut + 1
      end
      if bodyPart:getScratchTime() > 0 then
        result.virusScratch = result.virusScratch + 1
      end
    end
  end
  return result
end

local function getWoundsCount(player)
  local result = { 
    ["deepWounded"] = 0,
    ["bleeding"] = 0,
    ["bitten"] = 0,
    ["cut"] = 0,
    ["scratched"] = 0,
    ["burnt"] = 0,
    ["needBurnWash"] = 0,
    ["stiched"] = 0,
    ["haveBullet"] = 0,
    ["haveGlass"] = 0
  }
  local bodyDamage = player:getBodyDamage()
  for part_index, part_key in pairs(AntibodiesShared.bodyPartTypes) do
    local bodyPartType = BodyPartType.FromString(part_key)
    if bodyPartType ~= BodyPartType.MAX then
      local bodyPart = bodyDamage:getBodyPart(bodyPartType)
      if bodyPart then
        if bodyPart:getDeepWoundTime() > 0 then
          result["deepWounded"] = result["deepWounded"] + 1
        end
        if bodyPart:getBiteTime() > 0 then
          result["bitten"] = result["bitten"] + 1
        end
        if bodyPart:getCutTime() > 0 then
          result["cut"] = result["cut"] + 1
        end
        if bodyPart:getScratchTime() > 0 then
          result["scratched"] = result["scratched"] + 1
        end
        if bodyPart:getBurnTime() > 0 then
          result["burnt"] = result["burnt"] + 1
        end
        if bodyPart:isNeedBurnWash() then
          result["needBurnWash"] = result["needBurnWash"] + 1
        end
        if bodyPart:getStitchTime() > 0 then
          result["stiched"] = result["stiched"] + 1
        end
        if bodyPart:haveBullet() then
          result["haveBullet"] = result["haveBullet"] + 1
        end
        if bodyPart:haveGlass() then
          result["haveGlass"] = result["haveGlass"] + 1
        end
        if bodyPart:getBleedingTime() > 0 then
          result["bleeding"] = result["bleeding"] + 1
        end
      end
    end
  end
  return result
end

local function getWoundsEffect(player)
  local woundsEffect = 0.0
  local wounds = getWoundsCount(player)
  for part_key in pairs(wounds) do
    if wounds[part_key] > 0 then
      woundsEffect = woundsEffect + (wounds[part_key] * AntibodiesShared.currentOptions.wounds[part_key])
    end
  end
  return woundsEffect
end

local function getInfectionsEffect(player)
  local infections = getInfectionsCount(player)
  return infections.virusScratch * AntibodiesShared.currentOptions.infections.virusScratch +
         infections.virusCut * AntibodiesShared.currentOptions.infections.virusCut +
         infections.virusBite * AntibodiesShared.currentOptions.infections.virusBite +
         infections.regular * AntibodiesShared.currentOptions.infections.regular
end

local function isAlcoholBandage(bandageType)
  return string.match(bandageType, "Alcohol")
end

local function getBodyPartHygineMod(bodyPart)
  local mod = 0.0

  if bodyPart:bandaged() and not bodyPart:isBandageDirty() then
    mod = mod + AntibodiesShared.currentOptions.hygiene.modCleanBandage
    if isAlcoholBandage(bodyPart:getBandageType()) then
      mod = mod + AntibodiesShared.currentOptions.hygiene.modSterilizedBandage
    end
  end

  if bodyPart:getAlcoholLevel() > 0 then
    mod = mod + AntibodiesShared.currentOptions.hygiene.modSterilizedWound
  end

  if bodyPart:getDeepWoundTime() > 0 then
    mod = mod + AntibodiesShared.currentOptions.hygiene.modDeepWounded
  end
  if bodyPart:getBiteTime() > 0 then
    mod = mod + AntibodiesShared.currentOptions.hygiene.modBitten
  end
  if bodyPart:getCutTime() > 0 then
    mod = mod + AntibodiesShared.currentOptions.hygiene.modCut
  end
  if bodyPart:getScratchTime() > 0 then
    mod = mod + AntibodiesShared.currentOptions.hygiene.modScratched
  end
  if bodyPart:getBurnTime() > 0 then
    mod = mod + AntibodiesShared.currentOptions.hygiene.modBurnt
  end
  if bodyPart:isNeedBurnWash() then
    mod = mod + AntibodiesShared.currentOptions.hygiene.modNeedBurnWash
  end
  if bodyPart:getStitchTime() > 0 then
    mod = mod + AntibodiesShared.currentOptions.hygiene.modStiched        
  end
  if bodyPart:haveBullet() then
    mod = mod + AntibodiesShared.currentOptions.hygiene.modHaveBullet
  end
  if bodyPart:haveGlass() then
    mod = mod + AntibodiesShared.currentOptions.hygiene.modHaveGlass
  end
  if bodyPart:getBleedingTime() > 0 then
    mod = mod + AntibodiesShared.currentOptions.hygiene.modBleeding
  end

  return math.min(mod, 0.0)
end

local function coversBodyPart(clothing, bloodBodyPartType)
  if clothing == nil then
    return false
  end
  local parts = clothing:getCoveredParts()
  if parts ~= nil then
    for i=0, parts:size()-1 do
      if parts:get(i)==bloodBodyPartType then
        return true
      end
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
        if clothing ~=nil and clothing:IsClothing() then
          if coversBodyPart(clothing, bloodBodyPartType) then
            local visualItem = clothing:getVisual()
            if visualItem ~=nil then
              result.blood = result.blood + visualItem:getBlood(bloodBodyPartType)
              result.dirt = result.dirt + visualItem:getDirt(bloodBodyPartType)
            end
          end
        end
      end
    end
  end
  result.blood = math.min(1.0, result.blood)
  result.dirt = math.min(1.0, result.dirt)
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
        local bodyPartMod = getBodyPartHygineMod(bodyPart)
        if bodyPartMod < 0.0 then
          local bloodBodyPartType = BloodBodyPartType.FromString(part_key)
          local bloodDirt = getClothingHygiene(player, bloodBodyPartType)
          bloodDirt.blood = math.min(1.0, bloodDirt.blood + humanVisual:getBlood(bloodBodyPartType))
          bloodDirt.dirt = math.min(1.0, bloodDirt.dirt + humanVisual:getDirt(bloodBodyPartType))
          hygieneEffect = hygieneEffect + (bloodDirt.blood * -bodyPartMod * AntibodiesShared.currentOptions.hygiene.bloodEffect)
          hygieneEffect = hygieneEffect + (bloodDirt.dirt * -bodyPartMod * AntibodiesShared.currentOptions.hygiene.dirtEffect)
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
    local key = AntibodiesShared.to_camel_case(traits:get(i))
    if AntibodiesShared.has_key(AntibodiesShared.currentOptions.traits, key) then
      effect_sum = effect_sum + AntibodiesShared.currentOptions.traits[key]
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
    local key = AntibodiesShared.to_camel_case(tostring(moodles:getMoodleType(i)))
    if(AntibodiesShared.has_key(AntibodiesShared.currentOptions.moodles, key)) then
      local effect = AntibodiesShared.currentOptions.moodles[key]
      effect_sum = effect_sum + (effect * level)
    end
  end
  return effect_sum
end

local function ensureOptionsInitialization(player)
  if not AntibodiesShared.hasOptions() then
    AntibodiesShared.applyOptions(AntibodiesShared.getOptions())
  end
end

local function ensurePlayerInitialization(player)
  local save = player:getModData()
  if not AntibodiesShared.is_number(save.virusAntibodiesLevel) then 
    save.virusAntibodiesLevel = 0.0
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
  local hygieneEffect = getHygieneEffect(player)
  local infectionEffect = getInfectionsEffect(player)
  local woundsEffect = getWoundsEffect(player)
  local growthSum = (AntibodiesShared.currentOptions.general.baseAntibodyGrowth + moodleEffect + traitEffect + hygieneEffect + infectionEffect + woundsEffect)
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

-----------------------------------------------------
--DEBUG-UTILS----------------------------------------
-----------------------------------------------------

local function printTraitsEffect(player)
  local traitEffect = getTraitEffect(player)
  print(AntibodiesShared.indent(1).."Traits: "..AntibodiesShared.format_float(traitEffect))
  if AntibodiesShared.currentOptions.debug["traits"] then
    local traits = player:getTraits()
    for i=0,(traits:size()-1) do 
      local key = AntibodiesShared.to_camel_case(traits:get(i))
      if AntibodiesShared.has_key(AntibodiesShared.currentOptions.traits, key) then
        print(AntibodiesShared.indent(2)..key.." : "..AntibodiesShared.format_float(AntibodiesShared.currentOptions.traits[key]))
      end
    end
  end
end

local function printMoodlesEffect(player)
  local moodleEffect = getMoodleEffect(player)
  print(AntibodiesShared.indent(1).."Moodles: "..AntibodiesShared.format_float(moodleEffect))
  if AntibodiesShared.currentOptions.debug["moodles"] then
    local moodles = player:getMoodles()
    local c = moodles:getNumMoodles()
    for i=0,(c-1) do 
      if not(moodles:getMoodleLevel(i) == 0) then
        local level = moodles:getMoodleLevel(i) 
        local key = AntibodiesShared.to_camel_case(tostring(moodles:getMoodleType(i)))
        if(AntibodiesShared.has_key(AntibodiesShared.currentOptions.moodles, key)) then
          local effect = (AntibodiesShared.currentOptions.moodles[key] * level)
          print(AntibodiesShared.indent(2)..key.." : Level "..level.." ("..moodles:getMoodleDisplayString(i)..") : "..AntibodiesShared.format_float(effect))
        end         
      end
    end
  end
end

local function printWoundsEffect(player)
  local woundsEffects = getWoundsEffect(player)
  print(AntibodiesShared.indent(1).."Wounds: "..AntibodiesShared.format_float(woundsEffects))
  if AntibodiesShared.currentOptions.debug["wounds"] then
    local wounds = getWoundsCount(player)
    for part_key in pairs(wounds) do
      if wounds[part_key] > 0 then
        print(AntibodiesShared.indent(2)..part_key..": "..tostring(wounds[part_key]).." ("..tostring(wounds[part_key] * AntibodiesShared.currentOptions.wounds[part_key]..")"))
      end
    end
  end
end

local function printInfectionsEffect(player)
  local infectionEffects = getInfectionsEffect(player)
  print(AntibodiesShared.indent(1).."Infections: "..AntibodiesShared.format_float(infectionEffects))
  if AntibodiesShared.currentOptions.debug["infections"] then
    local infections = getInfectionsCount(player)
    for infection_key in pairs(infections) do
      if infections[infection_key] > 0 then
        print(AntibodiesShared.indent(2)..infection_key..": "..tostring(infections[infection_key]).." ("..tostring(infections[infection_key] * AntibodiesShared.currentOptions.infections[infection_key])..")")
      end
    end
  end
end

local function printHygieneEffect(player)
  local hygieneEffect = getHygieneEffect(player)
  print(AntibodiesShared.indent(1).."Hygiene: "..AntibodiesShared.format_float(hygieneEffect))
  if AntibodiesShared.currentOptions.debug["hygiene"] then
    local bodyDamage = player:getBodyDamage()
    local humanVisual = player:getHumanVisual()
    for part_index, part_key in pairs(AntibodiesShared.bodyPartTypes) do
      local bodyPartType = BodyPartType.FromString(part_key)
      if bodyPartType ~= BodyPartType.MAX then
        local bodyPart = bodyDamage:getBodyPart(bodyPartType)
        local bodyPartMod = getBodyPartHygineMod(bodyPart)
        local bloodBodyPartType = BloodBodyPartType.FromString(part_key)
        local bloodDirt = getClothingHygiene(player, bloodBodyPartType)
        bloodDirt.blood = math.max(bloodDirt.blood, humanVisual:getBlood(bloodBodyPartType))
        bloodDirt.dirt = math.max(bloodDirt.dirt, humanVisual:getDirt(bloodBodyPartType))
        if (bloodDirt.blood > 0 or bloodDirt.dirt > 0) and (bodyPartMod < 0) then
          print(AntibodiesShared.indent(2)..tostring(bodyPartType)..":")
          print(AntibodiesShared.indent(3).."bloodLevel: "..tostring(AntibodiesShared.format_float(bloodDirt.blood)))
          print(AntibodiesShared.indent(3).."dirtLevel: "..tostring(AntibodiesShared.format_float(bloodDirt.dirt)))
          if bodyPart:bandaged() and not bodyPart:isBandageDirty() then
            print(AntibodiesShared.indent(3).."bandaged")
          end
          if bodyPart:getDeepWoundTime() > 0 then
            print(AntibodiesShared.indent(3).."deepwounded")
          end
          if bodyPart:getBiteTime() > 0 then
            print(AntibodiesShared.indent(3).."bitten")
          end
          if bodyPart:getCutTime() > 0 then
            print(AntibodiesShared.indent(3).."cut")
          end
          if bodyPart:getScratchTime() > 0 then
            print(AntibodiesShared.indent(3).."scratched")
          end
          if bodyPart:getBurnTime() > 0 then
            print(AntibodiesShared.indent(3).."burnt")
          end
          if bodyPart:isNeedBurnWash() then
            print(AntibodiesShared.indent(3).."burnt need wash")
          end
          if bodyPart:getStitchTime() > 0 then
            print(AntibodiesShared.indent(3).."stiched")
          end
          if bodyPart:haveBullet() then
            print(AntibodiesShared.indent(3).."lodged bullet")
          end
          if bodyPart:haveGlass() then
            print(AntibodiesShared.indent(3).."lodged glass")
          end
          if bodyPart:getBleedingTime() > 0 then
            print(AntibodiesShared.indent(3).."bleeding")
          end
        end
      end
    end
  end
end

local function getPlayerInfectionStage(player)
  local bodyDamage = player:getBodyDamage()
  local isInfected = bodyDamage:IsInfected()
  if isInfected then
    local save = player:getModData()
    local infectionLevel = bodyDamage:getInfectionLevel()
    if save.virusAntibodiesLevel > infectionLevel then
      if infectionLevel > 50 then
        return "Decline"
      end
      if infectionLevel < 50 then
        return "Convalescence"
      end
    end
    if infectionLevel < 25 then
      return "Incubation"
    end
    if infectionLevel > 25 and infectionLevel < 50 then
      return "Prodromal"
    end
    if infectionLevel > 50 and infectionLevel < 75 then
      return "Illness"
    end
    if infectionLevel > 75 then
      return "Terminal"
    end
  end
  return "None"
end

local function printPlayerDebug(player, last)
  local save = player:getModData()
  local bodyDamage = player:getBodyDamage()
  local infectionLevel = bodyDamage:getInfectionLevel()
  local infectionChange = getInfectionChangeEveryTenMinutes(player)
  local antibodiesChange = getAntibodiesGrowth(player, infectionChange)
  local infectionProgress = (infectionLevel / 100)

  print(AntibodiesShared.indent(1).."Player: "..player:getUsername())
  print(AntibodiesShared.indent(1).."Infection Stage: "..getPlayerInfectionStage(player))
  print(AntibodiesShared.indent(1).."Virus/Antibodies: "..AntibodiesShared.format_float(infectionLevel).." (+"..AntibodiesShared.format_float(infectionChange)..") / "..AntibodiesShared.format_float(save.virusAntibodiesLevel).." (+"..AntibodiesShared.format_float(antibodiesChange)..")")
  printWoundsEffect(player)
  printInfectionsEffect(player)
  printHygieneEffect(player)
  printMoodlesEffect(player)
  printTraitsEffect(player)
end

local function printDebug(players)
  print("( "..AntibodiesShared.modName..": "..AntibodiesShared.version.." )========================>")
  for key, player in ipairs(players) do
    printPlayerDebug(player)
    if key ~= #players then
      print("------------------------")
    end
  end
  print("<========================( "..AntibodiesShared.modName..": "..AntibodiesShared.version.." )")
end

-----------------------------------------------------
--MAIN-----------------------------------------------
-----------------------------------------------------

local function onEveryTenMinutes()
  ensureOptionsInitialization()
  local players = AntibodiesShared.getLocalPlayers()
  for key, player in ipairs(players) do
    ensurePlayerInitialization(player)
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
  if AntibodiesShared.currentOptions.debug["enabled"] then
    printDebug(players)
  end
end
Events.EveryTenMinutes.Add(onEveryTenMinutes)

local function onGameStart()
  AntibodiesShared.applyOptions(AntibodiesShared.getOptions())
end
Events.OnGameStart.Add(onGameStart)

local function onMainMenuEnter()
  AntibodiesShared.applyOptions(AntibodiesShared.getOptions())
end
Events.OnMainMenuEnter.Add(onMainMenuEnter)
