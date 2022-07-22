AntibodiesDebug = {}
AntibodiesDebug.__index = AntibodiesDebug

require "AntibodiesOptions"
require "AntibodiesUtils"
require "Antibodies"

local function getWounds(player)
  local save = player:getModData()
  local medicalFile = save.medicalFile
  local result = ""
  result = result..AntibodiesUtils.indent(1).."Wounds: "..AntibodiesUtils.format_float(medicalFile.effects.wounds).."\n"
  if Antibodies.currentOptions.debug.wounds then
    for part_key in pairs(medicalFile.status.wounds) do
      if medicalFile.status.wounds[part_key] > 0 then
        result = result..AntibodiesUtils.indent(2)..part_key..": "..tostring(medicalFile.status.wounds[part_key]).." ("..AntibodiesUtils.format_float(medicalFile.status.wounds[part_key] * Antibodies.currentOptions.wounds[part_key])..")\n"
      end
    end
  end
  return result
end

local function getInfections(player)
  local save = player:getModData()
  local medicalFile = save.medicalFile
  local result = AntibodiesUtils.indent(1).."Infections: "..AntibodiesUtils.format_float(medicalFile.effects.infections).."\n"
  if Antibodies.currentOptions.debug.infections then
    local infections = medicalFile.status.infections
    for infection_key in pairs(infections) do
      if infections[infection_key] > 0 then
        result = result..AntibodiesUtils.indent(2)..infection_key..": "..tostring(infections[infection_key]).." ("..AntibodiesUtils.format_float(infections[infection_key] * Antibodies.currentOptions.infections[infection_key])..")\n"
      end
    end
  end
  return result
end

local function getHygiene(player)
  local save = player:getModData()
  local medicalFile = save.medicalFile
  local result = AntibodiesUtils.indent(1).."Hygiene: "..AntibodiesUtils.format_float(medicalFile.effects.hygiene).."\n"
  if Antibodies.currentOptions.debug.hygiene then
    local parts = medicalFile.status.parts
    for part_key in pairs(parts) do
      local hygiene = parts[part_key].hygiene
      local wounds = parts[part_key].wounds
      if hygiene.mod ~= 0 and (hygiene.blood > 0 or hygiene.dirt > 0) then
        local effect = (-(hygiene.mod * hygiene.blood) * Antibodies.currentOptions.hygiene.bloodEffect) +
                       (-(hygiene.mod * hygiene.dirt) * Antibodies.currentOptions.hygiene.dirtEffect)
        result = result..AntibodiesUtils.indent(2)..tostring(part_key).." ("..AntibodiesUtils.format_float(effect).."):\n"
        result = result..AntibodiesUtils.indent(3).."blood: "..AntibodiesUtils.format_float(hygiene.blood).."\n"
        result = result..AntibodiesUtils.indent(3).."dirt: "..AntibodiesUtils.format_float(hygiene.dirt).."\n"
        result = result..AntibodiesUtils.indent(3).."mod: "..AntibodiesUtils.format_float(hygiene.mod).."\n"
        for wound_key in pairs(wounds) do
          if wounds[wound_key] then
            result = result..AntibodiesUtils.indent(4)..wound_key.." ("..Antibodies.currentOptions.hygiene["mod"..AntibodiesUtils.first_to_upper(wound_key)]..")\n"
          end
        end
      end
    end
  end
  return result
end

--[[
local function getMoodles(player)
  local save = player:getModData()
  local medicalFile = save.medicalFile
  local result = AntibodiesUtils.indent(1).."Moodles: "..AntibodiesUtils.format_float(medicalFile.effects.moodles).."\n"
  if Antibodies.currentOptions.debug.moodles then
    for moodle_key in pairs(medicalFile.status.moodles) do
      local level = medicalFile.status.moodles[moodle_key]
      if not(level == 0) then
        local effect = Antibodies.currentOptions.moodles[moodle_key] * level
        result = result..AntibodiesUtils.indent(2)..moodle_key.." "..level.." ("..AntibodiesUtils.format_float(effect)..")\n"
      end
    end
  end
  return result
end

local function getTraits(player)
  local save = player:getModData()
  local medicalFile = save.medicalFile
  local result = AntibodiesUtils.indent(1).."Traits: "..AntibodiesUtils.format_float(medicalFile.effects.traits).."\n"
  if Antibodies.currentOptions.debug.traits then
    local traits = medicalFile.status.traits
    for trait_key in pairs(traits) do
      if traits[trait_key] then
        result = result..AntibodiesUtils.indent(2)..trait_key.." ("..AntibodiesUtils.format_float(Antibodies.currentOptions.traits[trait_key])..")\n"
      end
    end
  end
  return result
end
]]

local function getSummary(player)
  local save = player:getModData()
  local medicalFile = save.medicalFile
  local result = ""
  result = result..AntibodiesUtils.indent(1).."Player: "..player:getUsername().."\n"
  result = result..AntibodiesUtils.indent(1).."Infection Stage: "..getText("UI_Antibodies_Stage_"..tostring(medicalFile.knoxInfectionStage)).."\n"
  result = result..AntibodiesUtils.indent(1).."Virus/Antibodies: "..AntibodiesUtils.format_float(medicalFile.knoxInfectionLevel).." (+"..AntibodiesUtils.format_float(medicalFile.knoxInfectionDelta)..") / "..AntibodiesUtils.format_float(medicalFile.knoxAntibodiesLevel).." (+"..AntibodiesUtils.format_float(medicalFile.knoxAntibodiesDelta)..")".."\n"
  if medicalFile.effects.knoxRecovery ~= 0 then
    result = result..AntibodiesUtils.indent(1).."Knox Recovery Effect: "..medicalFile.effects.knoxRecovery.." ("..tostring(medicalFile.knoxInfectionsSurvived).." infections)\n"
  end
  if medicalFile.effects.knoxMutation ~= 0 then
    result = result..AntibodiesUtils.indent(1).."Knox Mutation Effect: "..medicalFile.effects.knoxMutation.." ("..tostring(getGameTime():getDaysSurvived()).." days)\n"
  end
  return result
end

local function getPlayerDebug(player)
  local result = ""
  result = result..getSummary(player)
  result = result..getWounds(player)
  result = result..getInfections(player)
  result = result..getHygiene(player)
  --result = result..getMoodles(player)
  --result = result..getTraits(player)
  return result
end

local function getDebug(players)
  local result = "\n( "..Antibodies.info.modName..": "..Antibodies.info.version.." )========================>\n"
  for key, player in ipairs(players) do
    result = result..getPlayerDebug(player)
    if key ~= #players then
      result = result.."\n------------------------\n"
    end
  end
  result = result..("<========================( "..Antibodies.info.modName..": "..Antibodies.info.version.." )")
  return result
end

AntibodiesDebug.getDebug = getDebug