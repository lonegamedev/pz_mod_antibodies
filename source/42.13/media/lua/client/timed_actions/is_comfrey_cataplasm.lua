require("TimedActions/ISComfreyCataplasm")
local AntibodiesMedicalFile = require("AntibodiesMedicalFile")
local AntibodiesEnum = require("AntibodiesEnum")

ISComfreyCataplasm_perform = ISComfreyCataplasm.perform
---@diagnostic disable-next-line: duplicate-set-field
function ISComfreyCataplasm:perform()
	ISComfreyCataplasm_perform(self)
	local medicalFile = AntibodiesMedicalFile.of(self.otherPlayer)
	local bodyPart = medicalFile.body:getBodyPartByIndex(self.bodyPart:getType():index())
	bodyPart:setTreatmentSkill(AntibodiesEnum.BodyPart.Treatment.STERILIZED_WOUND, self.doctorLevel)
end
