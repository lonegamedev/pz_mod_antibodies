require("TimedActions/ISGarlicCataplasm")
local AntibodiesMedicalFile = require("antibodies_medical_file")
local AntibodiesEnum = require("antibodies_enum")

ISGarlicCataplasm_perform = ISGarlicCataplasm.perform
---@diagnostic disable-next-line: duplicate-set-field
function ISGarlicCataplasm:perform()
	ISGarlicCataplasm_perform(self)
	local medicalFile = AntibodiesMedicalFile.of(self.otherPlayer)
	local bodyPart = medicalFile.body:getBodyPartByIndex(self.bodyPart:getType():index())
	bodyPart:setTreatmentSkill(AntibodiesEnum.BodyPart.Treatment.GARLIC, self.doctorLevel)
end
