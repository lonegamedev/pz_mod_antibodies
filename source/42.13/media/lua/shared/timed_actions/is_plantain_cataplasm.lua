require("TimedActions/ISPlantainCataplasm")
local AntibodiesMedicalFile = require("antibodies_medical_file")
local AntibodiesEnum = require("antibodies_enum")
local AntibodiesUtils = require("antibodies_utils")

local function applyTreatment(patient, bodyPart, doctorLevel)
	local medicalFile = AntibodiesMedicalFile.of(patient)
	local bodyPart = medicalFile.body:getBodyPartByIndex(bodyPart:getType():index())
	bodyPart:setTreatmentSkill(AntibodiesEnum.BodyPart.Treatment.PLANTAIN, doctorLevel)
end

ISPlantainCataplasm_perform = ISPlantainCataplasm.perform
---@diagnostic disable-next-line: duplicate-set-field
function ISPlantainCataplasm:perform()
	ISPlantainCataplasm_perform(self)
	if AntibodiesUtils.isSinglePlayer() then
		applyTreatment(self.otherPlayer, self.bodyPart, self.doctorLevel)
	end
end

ISPlantainCataplasm_complete = ISPlantainCataplasm.complete
---@diagnostic disable-next-line: duplicate-set-field
function ISPlantainCataplasm:complete()
	ISPlantainCataplasm_complete(self)
	if isServer() then
		applyTreatment(self.otherPlayer, self.bodyPart, self.doctorLevel)
	end
end
