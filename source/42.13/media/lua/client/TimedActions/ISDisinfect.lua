require("TimedActions/ISDisinfect")
local AntibodiesMedicalFile = require("AntibodiesMedicalFile")
local AntibodiesEnum = require("AntibodiesEnum")

ISDisinfect_perform = ISDisinfect.perform
---@diagnostic disable-next-line: duplicate-set-field
function ISDisinfect:perform()
	ISDisinfect_perform(self)
	local medicalFile = AntibodiesMedicalFile.of(self.otherPlayer)
	local bodyPart = medicalFile.body:getBodyPartByIndex(self.bodyPart:getType():index())
	bodyPart:setTreatmentSkill(AntibodiesEnum.BodyPart.Treatment.STERILIZED_WOUND, self.doctorLevel)
end
