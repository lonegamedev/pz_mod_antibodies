require("TimedActions/ISGarlicCataplasm")
local AntibodiesMedicalFile = require("antibodies_medical_file")
local AntibodiesEnum = require("antibodies_enum")
local AntibodiesUtils = require("antibodies_utils")

local function applyTreatment(patient, bodyPart, doctorLevel)
	local medicalFile = AntibodiesMedicalFile.of(patient)
	local bodyPart = medicalFile.body:getBodyPartByIndex(bodyPart:getType():index())
	bodyPart:setTreatmentSkill(AntibodiesEnum.BodyPart.Treatment.GARLIC, doctorLevel)
end

ISGarlicCataplasm_perform = ISGarlicCataplasm.perform
---@diagnostic disable-next-line: duplicate-set-field
function ISGarlicCataplasm:perform()
	ISGarlicCataplasm_perform(self)
	if AntibodiesUtils.isSinglePlayer() then
		applyTreatment(self.otherPlayer, self.bodyPart, self.doctorLevel)
	end
end

ISGarlicCataplasm_complete = ISGarlicCataplasm.complete
---@diagnostic disable-next-line: duplicate-set-field
function ISGarlicCataplasm:complete()
	ISGarlicCataplasm_complete(self)
	if isServer() then
		applyTreatment(self.otherPlayer, self.bodyPart, self.doctorLevel)
	end
end
