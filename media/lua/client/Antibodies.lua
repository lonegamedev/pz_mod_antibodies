Antibodies = {}
Antibodies.__index = Antibodies

require "AntibodiesOptions"
require "AntibodiesUtils"
require "AntibodiesDebug"

-----------------------------------------------------
--GLOBALS--------------------------------------------
-----------------------------------------------------

Antibodies.currentOptions = nil
Antibodies.currentCurves = nil

-----------------------------------------------------
--CONSTS---------------------------------------------
-----------------------------------------------------

Antibodies.info = {
  ["version"] = "1.60",
  ["optionsVersion"] = "1.60",
  ["author"] = "lonegamedev.com",
  ["modName"] = "Antibodies",
  ["modId"] = "lgd_antibodies"
}

Antibodies.InfectionStage = {
  ["None"] = 0,
  ["Incubation"] = 1,
  ["Prodromal"] = 2,
  ["Illness"] = 3,
  ["Terminal"] = 4,
  ["Decline"] = 5,
  ["Convalescence"] = 6
}

-----------------------------------------------------
--OPTIONS--------------------------------------------
-----------------------------------------------------

local function hasOptions()
  return Antibodies.currentOptions ~= nil
end

local function hasCurves()
  return Antibodies.currentCurves ~= nil
end

local function applyOptions(options)
  if (type(options) ~= "table") then
    Antibodies.currentOptions = nil
    return
  end
  Antibodies.currentOptions = AntibodiesUtils.deep_copy(options)
end

local function ensureOptionsInitialization(player)
  if not hasOptions() then
    applyOptions(AntibodiesOptions.getOptions())
  end
  if not hasCurves() then
    Antibodies.currentCurves = AntibodiesOptions.getCurves();
  end
end

-----------------------------------------------------
--CORE-----------------------------------------------
-----------------------------------------------------

local function cureKnoxVirus(player)
  local bodyDamage = player:getBodyDamage()
  for i = 0, bodyDamage:getBodyParts():size() - 1 do
    local bodyPart = bodyDamage:getBodyParts():get(i)
    bodyPart:SetInfected(false)
  end
  bodyDamage:setInfected(false)
  bodyDamage:setInfectionLevel(0.0)
  bodyDamage:setInfectionTime(-1.0)
  bodyDamage:setInfectionMortalityDuration(-1.0)
end

local function fixKnoxInstantDeath(player)
  local bodyDamage = player:getBodyDamage()
  bodyDamage:setInfectionTime(-1.0)
  bodyDamage:setInfectionMortalityDuration(-1.0)
end

local function getInfectionsPart(bodyPart)
  local result = {}
  for infection_key in pairs(AntibodiesOptions.defaultOptions.infections) do
    result[infection_key] = false
  end
  result.virus = false
  if bodyPart:isInfectedWound() then
    result.regular = true
  end
  if bodyPart:IsInfected() then
    if bodyPart:getBiteTime() > 0 then
      result.virusBite = true
    end
    if bodyPart:getCutTime() > 0 then
      result.virusCut = true
    end
    if bodyPart:getScratchTime() > 0 then
      result.virusScratch = true
    end
    if result.virusScratch or result.virusCut or result.virusBite then
      result.virus = true
    end
  end
  return result
end

local function getWoundsPart(bodyPart)
  local result = {}
  for wound_key in pairs(AntibodiesOptions.defaultOptions.wounds) do
    result[wound_key] = false
  end
  if bodyPart then
    if bodyPart:getDeepWoundTime() > 0 then
      result.deepWounded = true
    end
    if bodyPart:getBiteTime() > 0 then
      result.bitten = true
    end
    if bodyPart:getCutTime() > 0 then
      result.cut = true
    end
    if bodyPart:getScratchTime() > 0 then
      result.scratched = true
    end
    if bodyPart:getBurnTime() > 0 then
      result.burnt = true
    end
    if bodyPart:isNeedBurnWash() then
      result.needBurnWash = true
    end
    if bodyPart:getStitchTime() > 0 then
      result.stiched = true
    end
    if bodyPart:haveBullet() then
      result.haveBullet = true
    end
    if bodyPart:haveGlass() then
      result.haveGlass = true
    end
    if bodyPart:getBleedingTime() > 0 then
      result.bleeding = true
    end
    if bodyPart:getAlcoholLevel() > 0 then
      result.woundSterilized = true
    end
    if bodyPart:bandaged() and not bodyPart:isBandageDirty() then
      result.bandaged = true
      if AntibodiesUtils.isAlcoholBandage(bodyPart:getBandageType()) then
        result.bandageSterilized = true
      end
    end
  end
  return result
end

local function coversBodyPart(clothing, bloodBodyPart)
  if clothing == nil then
    return false
  end
  local parts = clothing:getCoveredParts()
  if parts ~= nil then
    for i=0, parts:size()-1 do
      if parts:get(i) == bloodBodyPart then
        return true
      end
    end
  end
  return false
end

local function getClothingHygiene(player, bodyPart)
  local bloodBodyPart = BloodBodyPartType.FromString(tostring(bodyPart:getType()))
  local result = {
    ["blood"] = 0,
    ["dirt"] = 0,
    ["pieces"] = 0
  }
  local wornItems = player:getWornItems()
  if wornItems then
    if wornItems:size() > 0 then
      for index=0, wornItems:size()-1 do
        local clothing = wornItems:getItemByIndex(index)
        if clothing ~=nil and clothing:IsClothing() then
          if coversBodyPart(clothing, bloodBodyPart) then
            local visualItem = clothing:getVisual()
            if visualItem ~=nil then
              result.blood = result.blood + visualItem:getBlood(bloodBodyPart)
              result.dirt = result.dirt + visualItem:getDirt(bloodBodyPart)
              result.pieces = result.pieces + 1
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

local function getHygienePart(player, bodyPart, wounds)
  local result = {
    ["blood"] = 0,
    ["dirt"] = 0,
    ["mod"] = 0,
    ["clothingPieces"] = 0,
    ["clothingBlood"] = 0,
    ["clothingDirt"] = 0,
    ["clothing"] = 0,
    ["bodyBlood"] = 0,
    ["bodyDirt"] = 0,
    ["body"] = 0
  }
  local bloodBodyPartType = BloodBodyPartType.FromString(bodyPart:getType():toString())
  local humanVisual = player:getHumanVisual()
  local clothing = getClothingHygiene(player, bodyPart)
  
  result.clothingPieces = clothing.pieces
  result.clothingBlood = clothing.blood
  result.clothingDirt = clothing.dirt
  result.bodyBlood = humanVisual:getBlood(bloodBodyPartType)
  result.bodyDirt = humanVisual:getDirt(bloodBodyPartType)

  result.clothing = math.min(1.0, result.clothingBlood + result.clothingDirt)
  result.body = math.min(1.0, result.bodyBlood + result.bodyDirt)

  result.blood = math.min(1.0, result.clothingBlood + result.bodyBlood)
  result.dirt = math.min(1.0, result.clothingDirt + result.clothingDirt)

  for wound_key in pairs(wounds) do
    if wounds[wound_key] then
      result.mod = result.mod + Antibodies.currentOptions.hygiene[wound_key]
    end
  end
  
  return result
end

local function getRawConditions(player)
  local stats = player:getStats()
  local nutrition = player:getNutrition()
  local bodyDamage = player:getBodyDamage()
  return {
    ["thirst"] = stats:getThirst(),-- 0-1
    ["drunkness"] = stats:getDrunkenness(),-- 0-1
    ["hunger"] = stats:getHunger(),-- 0-1
    ["weight"] = nutrition:getWeight(),-- 35-130
    ["calories"] = nutrition:getCalories(),-- -2200-3700
    --["lipids"] = nutrition:getLipids(),
    --["proteins"] = nutrition:getProteins(),
    --["carbohydrates"] = nutrition:getCarbohydrates(),

    ["sickness"] = stats:getSickness(), -- 0-100
    ["foodSickness"] = bodyDamage:getFoodSicknessLevel(), -- 0-100

    ["fitness"] = player:getPerkLevel(Perks.Fitness), -- 1-10
    ["strength"] = player:getPerkLevel(Perks.Strength), -- 1-10
    ["fatigue"] = stats:getFatigue(), -- 0-1
    ["endurance"] = stats:getEndurance(),-- 0-1
    ["temperature"] = bodyDamage:getTemperature(),-- 20-40

    ["pain"] = stats:getPain(), -- 0-100
    ["stress"] = stats:getStress(), -- 0-1.5
    --["stressSmoker"] = stats:getStressFromCigarettes(),-- 0-0.5
    ["unhappiness"] = bodyDamage:getUnhappynessLevel(), -- 0-100
    ["boredom"] = stats:getBoredom(), -- 0-100
    ["panic"] = stats:getPanic(), -- 0-100

    ["sanity"] = stats:getSanity(), -- 0-100
    ["anger"] = stats:getAnger(), -- 0-100
    ["fear"] = stats:getFear() -- 0-100
  }
end

local function getComputedConditions(rawConditions)
  local result = {}
  for key in pairs(rawConditions) do
    if Antibodies.currentCurves[key] then
      result[key] = AntibodiesUtils.lagrange(
        Antibodies.currentCurves[key],
        rawConditions[key]
      )
    else
      result[key] = 0.0
    end
  end
  return result
end

local function getEffectConditions(computed)
  local result = {}
  for key in pairs(computed) do
    local curve = computed[key]
    local mod = Antibodies.currentOptions.condition[key]
    if mod then
      result[key] = (curve * mod)
    end
  end
  return result
end

local function getCondition(player)
  local raw = getRawConditions(player)
  local computed = getComputedConditions(raw)
  local effect = getEffectConditions(computed)
  return {
    ["raw"] = raw,
    ["computed"] = computed,
    ["effect"] = effect
  }
end

--[[
local function getMoodles(player)
  local result = {}
  local moodles = player:getMoodles()
  local count = moodles:getNumMoodles()
  for i = 0, count - 1 do
    local level = moodles:getMoodleLevel(i) 
    local key = tostring(moodles:getMoodleType(i))
    if(AntibodiesUtils.has_key(Antibodies.currentOptions.moodles, key)) then
      if Antibodies.currentOptions.moodles[key] ~= 0 then
        result[key] = level
      end
    end
  end
  return result
end

local function getTraits(player)
  local result = {}
  local traits = player:getTraits()
  for i=0,(traits:size()-1) do 
    local key = traits:get(i)
    if AntibodiesUtils.has_key(Antibodies.currentOptions.traits, key) then
      result[key] = Antibodies.currentOptions.traits[key]
    else  
      result[key] = 0.0
    end
  end
  return result
end
]]

local function getWounds(parts)
  local result = {}
  for wound_key in pairs(AntibodiesOptions.defaultOptions.wounds) do
    result[wound_key] = 0
  end
  for part_key, part in pairs(parts) do
    local wounds = part.wounds
    for result_key in pairs(result) do
      if wounds[result_key] == true then
        result[result_key] = result[result_key] + 1
      end
    end
  end
  return result
end

local function getInfections(parts)
  local result = {}
  for infection_key in pairs(AntibodiesOptions.defaultOptions.infections) do
    result[infection_key] = 0
  end
  result.virus = 0
  for part_key in pairs(parts) do
    local infections = parts[part_key].infections
    for infection_key in pairs(result) do
      if infections[infection_key] then
        result[infection_key] = result[infection_key] + 1
      end
    end
  end
  return result
end

local function getHygiene(parts)
  local result = {
    ["clothing"] = 0,
    ["body"] = 0,
    ["hasClothes"] = false
  }
  local totalClothing = 0
  local totalBody = 0
  for part_key, part in pairs(parts) do
    local hygiene = part.hygiene
    if hygiene.clothingPieces > 0 and hygiene.clothing > 0 then
      totalClothing = totalClothing + 1
      result.clothing = result.clothing + hygiene.clothing
    end
    if hygiene.body > 0 then
      totalBody = totalBody + 1
      result.body = result.body + hygiene.body
    end
  end
  if totalClothing > 1 then
    result.clothing = result.clothing / totalClothing
  end
  if totalBody > 1 then
    result.body = result.body / totalBody
  end
  result.hasClothes = totalClothing > 0
  return result
end

local function getStatus(player)
  local bodyDamage = player:getBodyDamage()
  local result = {
    ["parts"] = {}
  }
  for i = 0, bodyDamage:getBodyParts():size() - 1 do
    local bodyPart = bodyDamage:getBodyParts():get(i)
    local wounds = getWoundsPart(bodyPart)
    result.parts[bodyPart:getType():toString()] = {
      ["infections"] = getInfectionsPart(bodyPart),
      ["wounds"] = wounds,
      ["hygiene"] = getHygienePart(player, bodyPart, wounds)
    }
  end
  result.wounds = getWounds(result.parts)
  result.infections = getInfections(result.parts)
  result.hygiene = getHygiene(result.parts)
  --result.moodles = getMoodles(player)
  --result.traits = getTraits(player)
  result.condition = getCondition(player)
  return result
end

local function getKnoxInfectionStage(player)
  local bodyDamage = player:getBodyDamage()
  local isInfected = bodyDamage:IsInfected()
  if isInfected then
    local save = player:getModData()
    local infectionLevel = bodyDamage:getInfectionLevel()
    if AntibodiesUtils.is_table(save.medicalFile) then
      if save.medicalFile.knoxAntibodiesLevel > infectionLevel then
        if infectionLevel > 50 then
          return Antibodies.InfectionStage.Decline
        end
        if infectionLevel < 50 then
          return Antibodies.InfectionStage.Convalescence
        end
      end
    end
    if infectionLevel < 25 then
      return Antibodies.InfectionStage.Incubation
    end
    if infectionLevel > 25 and infectionLevel < 50 then
      return Antibodies.InfectionStage.Prodromal
    end
    if infectionLevel > 50 and infectionLevel < 75 then
      return Antibodies.InfectionStage.Illness
    end
    if infectionLevel > 75 then
      return Antibodies.InfectionStage.Terminal
    end
  end
  return Antibodies.InfectionStage.None
end

local function getKnoxInfectionDelta(player)
  local bodyDamage = player:getBodyDamage()
  local infectionDuration = bodyDamage:getInfectionMortalityDuration()
  if (infectionDuration > 0) then
    return (100 / infectionDuration) / 60 --every in-game minute
  end
  return 0
end

local function getKnoxInfectionLevel(player)
  return player:getBodyDamage():getInfectionLevel()
end

local function applyActivationCurve(antibodiesGrowth, infectionLevel)
  return AntibodiesUtils.lerp(
    0.0, 
    antibodiesGrowth, 
    AntibodiesUtils.clamp(
      math.sin(
        (infectionLevel / 100) * math.pi
      ), 
      0.0, 
      1.0
    )
  )
end

local function alignWithInfectionDelta(effectSum, infectionDelta)
  return math.max(
    0, 
    math.abs(infectionDelta) * effectSum
  )
end

local function getKnoxAntibodiesDelta(medicalFile)
  local effectSum = Antibodies.currentOptions.general.baseAntibodyGrowth
  for effect_key in pairs(medicalFile.effects) do
    effectSum = effectSum + medicalFile.effects[effect_key]
  end
  return applyActivationCurve(
    alignWithInfectionDelta(
      effectSum, 
      medicalFile.knoxInfectionDelta
    ),
    medicalFile.knoxInfectionLevel
  )
end

local function getKnoxRecoveryEffect(medicalFile)
  return AntibodiesUtils.clamp(
    medicalFile.knoxInfectionsSurvived * Antibodies.currentOptions.general.knoxInfectionsSurvivedEffect, 
    -Antibodies.currentOptions.general.knoxInfectionsSurvivedThreshold, 
    Antibodies.currentOptions.general.knoxInfectionsSurvivedThreshold
  )
end

local function getKnoxMutationEffect()
  return AntibodiesUtils.clamp(
    getGameTime():getDaysSurvived() * Antibodies.currentOptions.general.knoxMutationEffect,
    -Antibodies.currentOptions.general.knoxMutationThreshold,
    Antibodies.currentOptions.general.knoxMutationThreshold
  )
end

local function getWoundsEffect(medicalFile)
  local result = 0.0
  for part_key in pairs(medicalFile.status.wounds) do
    result = result + medicalFile.status.wounds[part_key] * Antibodies.currentOptions.wounds[part_key]
  end
  return result
end

local function getInfectionsEffect(medicalFile)
  local result = 0.0
  for part_key in pairs(medicalFile.status.infections) do
    result = result + medicalFile.status.infections[part_key] * Antibodies.currentOptions.infections[part_key]
  end
  return result
end

local function getHygieneEffect(medicalFile)
  local result = 0
  for part_key in pairs(medicalFile.status.parts) do
    local part_hygiene = medicalFile.status.parts[part_key].hygiene
    local part_effect = (-(part_hygiene.blood * part_hygiene.mod) * Antibodies.currentOptions.hygiene.bloodEffect) + 
                        (-(part_hygiene.dirt * part_hygiene.mod) * Antibodies.currentOptions.hygiene.dirtEffect)
    result = result + math.min(0.0, part_effect)
  end
  return result
end

--[[
local function getMoodlesEffect(medicalFile)
  local result = 0.0
  for moodle_key in pairs(medicalFile.status.moodles) do
    result = result + medicalFile.status.moodles[moodle_key] * Antibodies.currentOptions.moodles[moodle_key]
  end
  return result
end

local function getTraitsEffect(medicalFile)
  local result = 0.0
  for trait_key in pairs(medicalFile.status.traits) do
    result = result + medicalFile.status.traits[trait_key]
  end
  return result
end
]]

local function getConditionEffect(medicalFile)
  local total = 0.0  
  for key in pairs(medicalFile.status.condition.effect) do
    total = total + medicalFile.status.condition.effect[key]
  end
  return total
end

local function getEffects(medicalFile)
  local result = {}
  result["knoxRecovery"] = getKnoxRecoveryEffect(medicalFile)
  result["knoxMutation"] = getKnoxMutationEffect()
  result["wounds"] = getWoundsEffect(medicalFile)
  result["infections"] = getInfectionsEffect(medicalFile)
  result["hygiene"] = getHygieneEffect(medicalFile)
  --result["moodles"] = getMoodlesEffect(medicalFile)
  --result["traits"] = getTraitsEffect(medicalFile)
  result["condition"] = getConditionEffect(medicalFile)
  return result
end

local function createMedicalFile(player)
  local save = player:getModData()
  local result = {}
  result["status"] = getStatus(player)
  result["knoxInfectionLevel"] = getKnoxInfectionLevel(player)
  result["knoxInfectionDelta"] = getKnoxInfectionDelta(player)
  result["knoxAntibodiesLevel"] = 0
  result["knoxInfectionsSurvived"] = 0
  if AntibodiesUtils.is_table(save.medicalFile) then
    if AntibodiesUtils.is_number(save.medicalFile.knoxAntibodiesLevel) then
      result["knoxAntibodiesLevel"] = save.medicalFile.knoxAntibodiesLevel
    end
    if AntibodiesUtils.is_number(save.medicalFile.knoxInfectionsSurvived) then
      result["knoxInfectionsSurvived"] = save.medicalFile.knoxInfectionsSurvived
    end
  end
  result["knoxInfectionStage"] = getKnoxInfectionStage(player)
  result["effects"] = getEffects(result)
  result["knoxAntibodiesDelta"] = getKnoxAntibodiesDelta(result)
  result["timestamp"] = os.time()
  return result
end

local function migratePlayerData(save)
  --migrations 1.50 -> 1.60
  if AntibodiesUtils.is_number(save.virusAntibodiesLevel) then 
    save.medicalFile.knoxAntibodiesLevel = save.virusAntibodiesLevel
    save.virusAntibodiesLevel = nil
  end
  if AntibodiesUtils.is_number(save.virusInfectionsSurvived) then 
    save.medicalFile.knoxInfectionsSurvived = save.virusInfectionsSurvived
    save.virusInfectionsSurvived = nil
  end
end

local function ensurePlayerInitialization(player)
  local save = player:getModData()
  if not AntibodiesUtils.is_table(save.medicalFile) then
    save.medicalFile = createMedicalFile(player)
  end
  migratePlayerData(save)
end

local function consumeKnoxInfection(player, medicalFile)

  local difference = medicalFile.knoxAntibodiesLevel - medicalFile.knoxInfectionLevel

  if difference <= 0 then
    return false
  end

  local infectionDelta = getKnoxInfectionDelta(player)

  local bodyDamage = player:getBodyDamage()
  local infectionTime = bodyDamage:getInfectionTime()
  local infectionDuration = bodyDamage:getInfectionMortalityDuration()
  local healStep = (infectionDelta + difference)

  local newTime = infectionTime + ((healStep / 100) * infectionDuration) 
  local newInfection = AntibodiesUtils.clamp(bodyDamage:getInfectionLevel() - healStep, 0, 100)

  bodyDamage:setInfectionTime(newTime)
  bodyDamage:setInfectionLevel(newInfection)

  medicalFile.knoxAntibodiesLevel = AntibodiesUtils.clamp(
    medicalFile.knoxAntibodiesLevel - difference, 
    0, 
    100
  )

  if(newTime >= player:getHoursSurvived()) then
    return true --ready to cure
  end

  return false
end

local function updateKnoxAntibodies(player)
  ensurePlayerInitialization(player)
  local save = player:getModData()
  local medicalFile = createMedicalFile(player)
  if medicalFile.knoxInfectionStage == Antibodies.InfectionStage.None then
    cureKnoxVirus(player)
    medicalFile.knoxAntibodiesLevel = 0
  else
    medicalFile.knoxAntibodiesLevel = medicalFile.knoxAntibodiesLevel + medicalFile.knoxAntibodiesDelta
    if consumeKnoxInfection(player, medicalFile) then
      cureKnoxVirus(player)
      medicalFile.knoxAntibodiesLevel = 0
      medicalFile.knoxInfectionsSurvived = medicalFile.knoxInfectionsSurvived + 1
    end
  end
  save.medicalFile = medicalFile
end

-----------------------------------------------------
--CALLBACKS------------------------------------------
-----------------------------------------------------

local function onGameStart()
  applyOptions(nil)
end
Events.OnGameStart.Add(onGameStart)

local function onMainMenuEnter()
  applyOptions(nil)
end
Events.OnMainMenuEnter.Add(onMainMenuEnter)

local function onEveryOneMinute()
  ensureOptionsInitialization()
  local players = AntibodiesUtils.getLocalPlayers()
  for key, player in ipairs(players) do
    local save = player:getModData()
    updateKnoxAntibodies(player)
  end
end
Events.EveryOneMinute.Add(onEveryOneMinute)

local function onEveryTenMinutes()
  ensureOptionsInitialization()
  if Antibodies.currentOptions.debug.enabled then
    local players = AntibodiesUtils.getLocalPlayers()
    print(AntibodiesDebug.getDebug(players))
  end
end
Events.EveryTenMinutes.Add(onEveryTenMinutes)
