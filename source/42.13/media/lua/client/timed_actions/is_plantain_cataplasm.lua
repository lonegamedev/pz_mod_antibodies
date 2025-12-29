require("TimedActions/ISPlantainCataplasm")
local AntibodiesMedicalFile = require("AntibodiesMedicalFile")
local AntibodiesEnum = require("AntibodiesEnum")

ISPlantainCataplasm_perform = ISPlantainCataplasm.perform
---@diagnostic disable-next-line: duplicate-set-field
function ISPlantainCataplasm:perform()
	ISPlantainCataplasm_perform(self)
	local medicalFile = AntibodiesMedicalFile.of(self.otherPlayer)
	local bodyPart = medicalFile.body:getBodyPartByIndex(self.bodyPart:getType():index())
	bodyPart:setTreatmentSkill(AntibodiesEnum.BodyPart.Treatment.PLANTAIN, self.doctorLevel)
end
