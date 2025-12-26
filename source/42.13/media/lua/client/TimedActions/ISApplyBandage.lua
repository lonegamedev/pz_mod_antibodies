require("TimedActions/ISApplyBandage")
local AntibodiesMedicalFile = require("AntibodiesMedicalFile")
local AntibodiesEnum = require("AntibodiesEnum")

local ISApplyBandage_perform = ISApplyBandage.perform
---@diagnostic disable-next-line: duplicate-set-field
function ISApplyBandage:perform()
	ISApplyBandage_perform(self)
	local medicalFile = AntibodiesMedicalFile.of(self.otherPlayer)
	local bodyPart = medicalFile.body:getBodyPartByIndex(self.bodyPart:getType():index())
	bodyPart:setTreatmentSkill(AntibodiesEnum.BodyPart.Treatment.BANDAGED, self.doctorLevel)
	bodyPart:setTreatmentSkill(AntibodiesEnum.BodyPart.Treatment.CLEAN_BANDAGE, self.doctorLevel)
	bodyPart:setTreatmentSkill(AntibodiesEnum.BodyPart.Treatment.STERILIZED_BANDAGE, self.doctorLevel)
end
