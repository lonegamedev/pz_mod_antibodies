-----------------------------------------------------
--CONST----------------------------------------------
-----------------------------------------------------

AntibodiesDiagnosis = {}

AntibodiesDiagnosis.FontTitle = "<SIZE:medium>"
AntibodiesDiagnosis.FontNormal = "<SIZE:small>"
AntibodiesDiagnosis.Indent0 = "<INDENT:0>"
AntibodiesDiagnosis.Indent1 = "<INDENT:8>"
AntibodiesDiagnosis.Indent2 = "<INDENT:16>"

AntibodiesDiagnosis.WHITE = "<RGB:1,1,1>"
AntibodiesDiagnosis.GREY1 = "<RGB:0.8,0.8,0.8>"
AntibodiesDiagnosis.RED1 = "<RGB:1,0,0>"
AntibodiesDiagnosis.GREEN1 = "<RGB:0.27,0.88,0.27>"
AntibodiesDiagnosis.YELLOW1 = "<RGB:0.99,0.99,0.34>"

AntibodiesDiagnosis.HygieneThreshold = 0.2

--AntibodiesDiagnosis.Cache = nil

AntibodiesDiagnosis.Translation = {
    ["Wounds"] = {
        ["deepWounded"] = "IGUI_health_DeepWound",
        ["bleeding"] = "IGUI_health_Bleeding",
        ["bitten"] = "IGUI_health_Bitten",
        ["cut"] = "IGUI_health_Cut",
        ["scratched"] = "IGUI_health_Scratch",
        ["burnt"] = "IGUI_health_Burned",
        ["needBurnWash"] = "IGUI_health_NeedCleaning",
        ["stiched"] = "IGUI_health_Stitched",
        ["haveBullet"] = "IGUI_health_LodgedBullet",
        ["haveGlass"] = "IGUI_health_LodgedGlassShards"
    }
}

AntibodiesDiagnosis.Condition = {
    ["General"] = {
        "fitness", "strength", "endurance", "fatigue",
        "weight", "calories", "thirst", "hunger", "drunkness",
        "temperature", "sickness", "foodSickness",
        "pain", "stress", "unhappiness", "boredom", "panic",
        "sanity", "anger", "fear"
    }
}

-----------------------------------------------------
--DIAGNOSIS------------------------------------------
-----------------------------------------------------

local formatChange = function(f)
    if f > 0 then
        return "+"..AntibodiesUtils.format_float(f)
    end
    return AntibodiesUtils.format_float(f)
end

local getTitleFormatted = function(title)
    return AntibodiesDiagnosis.Indent0..AntibodiesDiagnosis.FontTitle..title.."\n"..AntibodiesDiagnosis.FontNormal..AntibodiesDiagnosis.Indent1
end

local valueToColor = function(val)
    local color = AntibodiesDiagnosis.GREY1
    if val > 0 then
        color = AntibodiesDiagnosis.GREEN1
    else
        color = AntibodiesDiagnosis.RED1
    end
    return color
end

local createWoundsLevels = function(medicalFile, skill)
    local result = {}
    for bodyPartKey in pairs(medicalFile.status.parts) do
        local score = 0
        local wounds = medicalFile.status.parts[bodyPartKey].wounds
        for woundKey in pairs(wounds) do
            if wounds[woundKey] then
                score = score + Antibodies.currentOptions.wounds[woundKey]
            end
        end
        result[bodyPartKey] = score
    end
    return result
end

local createHygieneLevels = function(medicalFile, skill)
    local result = {}
    for bodyPartKey in pairs(medicalFile.status.parts) do
        result[bodyPartKey] = math.max(
            medicalFile.status.parts[bodyPartKey].hygiene.blood, 
            medicalFile.status.parts[bodyPartKey].hygiene.dirt
        )
    end
    return result
end

local createInfectionsLevels = function(medicalFile, skill)
    local result = {}
    for bodyPartKey in pairs(medicalFile.status.parts) do
        local score = 0
        local infections = medicalFile.status.parts[bodyPartKey].infections
        for infectionKey in pairs(infections) do
            if infections[infectionKey] then
                score = score + Antibodies.currentOptions.infections[infectionKey]
            end
        end
        result[bodyPartKey] = score
    end
    return result
end

local formatCondition = function(medicalFile, skill, key)
    if medicalFile.status.condition.effect[key] ~= 0 then
        local val = medicalFile.status.condition.effect[key]
        local color = AntibodiesDiagnosis.GREY1
        if skill.general.effValues then 
            color = valueToColor(val)
        end
        return color..getText("UI_Antibodies_"..key).." ("..formatChange(val)..")"
    end
    return false
end

local createGeneralDiagnosis = function(medicalFile, skill)
    local result = getTitleFormatted("General")
    local sentences = {}
    local keys = AntibodiesDiagnosis.Condition.General
    if skill.general.relValues then
        keys = AntibodiesUtils.deep_copy(keys)
        table.sort(keys, function (k1, k2) 
            return medicalFile.status.condition.effect[k1] > medicalFile.status.condition.effect[k2]
        end)
    end
    for _,key in ipairs(keys) do
        local line = formatCondition(medicalFile, skill, key)
        if line then
            table.insert(sentences, line)
        end
    end
    if #sentences > 0 then
        return result..table.concat(sentences, " <LINE> ")
    else
        return result..getText("UI_Antibodies_Stable_Condition")
    end
end

local formatWound = function(skill, key, counts, effects)
    local count = counts[key]
    local effect = effects[key]
    if count < 1 then
        return false
    end
    local name = getText(AntibodiesDiagnosis.Translation.Wounds[key])
    return AntibodiesDiagnosis.RED1..name.." ("..effect..")"
end

local createWoundsDiagnosis = function(medicalFile, skill)
    local result = getTitleFormatted(getText("UI_Antibodies_Wounds"))
    local sentences = {}
    local effects = {}
    local order = {}
    for key in pairs(medicalFile.status.wounds) do
        effects[key] = medicalFile.status.wounds[key] * Antibodies.currentOptions.wounds[key]
        table.insert(order, key)
    end
    table.sort(order, function (k1, k2)
        return effects[k1] > effects[k2]
    end)
    for _,key in pairs(order) do
        local text = formatWound(
            skill, 
            key, 
            medicalFile.status.wounds,
            effects
        )
        if text then
            table.insert(sentences, text)
        end
    end
    if #sentences < 1 then
        table.insert(sentences, getText("UI_Antibodies_Wounds_None"))
    end
    return result..table.concat(sentences, " <LINE> ")
end

local createHygieneDiagnosis = function(medicalFile, skill)    
    local result = getTitleFormatted(getText("UI_Antibodies_Hygiene"))
    local sentences = {}

    --local amount = math.max(medicalFile.status.hygiene.blood, medicalFile.status.hygiene.dirt)
    --local level = AntibodiesUtils.computeStage(amount, 0, BodyPartType.MAX:index(), 4)
    --table.insert(sentences, getText("UI_Antibodies_Hygiene_Level_"..tostring(level)))

    local affected = 0
    for _, bodyPart in pairs(medicalFile.status.parts) do
        local amount = math.max(bodyPart.hygiene.blood, bodyPart.hygiene.dirt)
        if amount > AntibodiesDiagnosis.HygieneThreshold and bodyPart.hygiene.mod < 0 then
            affected = affected + 1
        end
    end
    if affected > 0 then
        table.insert(
            sentences, 
            AntibodiesDiagnosis.RED1..getText(
                "UI_Antibodies_Hygiene_WoundsAffected", 
                AntibodiesUtils.format_float(medicalFile.effects.hygiene)
            )
        )
    else
        table.insert(sentences, getText("UI_Antibodies_Hygiene_WoundsUnaffected"))
    end

    return result..table.concat(sentences, "\n")
end

local createInfectionsDiagnosis = function(medicalFile, skill, options)
    local result = getTitleFormatted(getText("UI_Antibodies_Infections"))
    local sentences = {}

    if medicalFile.status.infections.regular > 0 then
        table.insert(sentences, AntibodiesDiagnosis.RED1..getText("UI_Antibodies_Infections_CommonInfections"))
    end

    if medicalFile.status.infections.virus > 0 then
        table.insert(sentences, AntibodiesDiagnosis.RED1..getText("UI_Antibodies_Infections_KnoxInfections"))
        table.insert(sentences, getText("UI_Antibodies_Infections_KnoxStage", "INFECTED"))
    end

    if #sentences < 1 then
        table.insert(sentences, getText("UI_Antibodies_Infections_NoSigns"))
    end

    return result..table.concat(sentences, "\n")
end

local createBodyPartsLevels = function(medicalFile, skill, options)
    return {
        ["wounds"] = createWoundsLevels(medicalFile, skill, options),
        ["hygiene"] = createHygieneLevels(medicalFile, skill, options),
        ["infections"] = createInfectionsLevels(medicalFile, skill, options)
    }
end

local computeDoctorSkill = function(medicalFile, doctor)
    local baseSkill = doctor:getPerkLevel(Perks.Doctor)
    return {
        ["general"] = {
            ["effValues"] = true,
            ["relValues"] = true,
            ["absValues"] = true,
        },
        ["wounds"] = {
            ["effValues"] = true,
            ["relValues"] = true,
            ["absValues"] = true
        },
        ["hygiene"] = {
            ["spotAffected"] = true,
            ["spotRelative"] = true,
            ["spotAbsolute"] = true
        },
        ["infections"] = {
            ["knoxFromBite"] = true,
            ["knoxFromStage"] = true,
            ["knoxKnowStage"] = true,
            ["knoxTimeLeft"] = true,
            ["knoxRelative"] = true,
            ["knoxAbsolute"] = true,
            ["knoxDelta"] = true
        }
    }
end

--[[

    UI_Antibodies_Stage_0 = "None",
    UI_Antibodies_Stage_1 = "Incubation",
    UI_Antibodies_Stage_2 = "Prodromal",
    UI_Antibodies_Stage_3 = "Illness",
    UI_Antibodies_Stage_4 = "Terminal",
    UI_Antibodies_Stage_5 = "Decline",
    UI_Antibodies_Stage_6 = "Convalescence",   

]]

--[[
local computeCache = function(options)
    if AntibodiesDiagnosis.Cache then
        return AntibodiesDiagnosis.Cache
    end
    local result = {
        ["moodles"] = {["min"] = 10000, ["max"] = -10000},
        ["wounds"] = {["min"] = 10000, ["max"] = -10000},
        ["hygiene"] = {["min"] = 10000, ["max"] = -10000},
        ["infections"] = {["min"] = 10000, ["max"] = -10000}
    }
    for group_key in pairs(result) do
        for key in pairs(options[group_key]) do
            local val = options[group_key][key]
            if result[group_key]["min"] > val then result[group_key]["min"] = val end
            if result[group_key]["max"] < val then result[group_key]["max"] = val end    
        end
    end
    result["moodles"].min = result["moodles"].min * 4.0
    result["moodles"].max = result["moodles"].max * 4.0
    return result
end
]]

AntibodiesDiagnosis.create = function(medicalFile, doctor)
    --AntibodiesDiagnosis.Cache = computeCache(options)
    --AntibodiesUtils.print_table(medicalFile.status.condition)
    local skill = computeDoctorSkill(medicalFile, doctor)
    return {
        ["timestamp"] = medicalFile.timestamp,
        ["general"] = createGeneralDiagnosis(medicalFile, skill),
        ["wounds"] = createWoundsDiagnosis(medicalFile, skill),
        ["hygiene"] = createHygieneDiagnosis(medicalFile, skill),
        ["infections"] = createInfectionsDiagnosis(medicalFile, skill),
        ["levels"] = createBodyPartsLevels(medicalFile, skill)
    }
end