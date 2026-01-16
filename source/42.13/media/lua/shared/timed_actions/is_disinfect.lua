require("TimedActions/ISDisinfect")
local AntibodiesMedicalFile = require("antibodies_medical_file")
local AntibodiesEnum = require("antibodies_enum")
local AntibodiesUtils = require("antibodies_utils")

local function applyTreatment(patient, bodyPart, doctorLevel)
	local medicalFile = AntibodiesMedicalFile.of(patient)
	local bodyPart = medicalFile.body:getBodyPartByIndex(bodyPart:getType():index())
	bodyPart:setTreatmentSkill(AntibodiesEnum.BodyPart.Treatment.STERILIZED_WOUND, doctorLevel)
end

ISDisinfect_perform = ISDisinfect.perform
---@diagnostic disable-next-line: duplicate-set-field
function ISDisinfect:perform()
	ISDisinfect_perform(self)
	if AntibodiesUtils.isSinglePlayer() then
		applyTreatment(self.otherPlayer, self.bodyPart, self.doctorLevel)
	end
end

local ISDisinfect_complete = ISDisinfect.complete
---@diagnostic disable-next-line: duplicate-set-field
function ISDisinfect:complete()
	ISDisinfect_complete(self)
	if isServer() then
		applyTreatment(self.otherPlayer, self.bodyPart, self.doctorLevel)
	end
end
