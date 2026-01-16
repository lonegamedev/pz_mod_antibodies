require("TimedActions/ISComfreyCataplasm")
local AntibodiesMedicalFile = require("antibodies_medical_file")
local AntibodiesEnum = require("antibodies_enum")
local AntibodiesUtils = require("antibodies_utils")

local function applyTreatment(patient, bodyPart, doctorLevel)
	local medicalFile = AntibodiesMedicalFile.of(patient)
	local bodyPart = medicalFile.body:getBodyPartByIndex(bodyPart:getType():index())
	bodyPart:setTreatmentSkill(AntibodiesEnum.BodyPart.Treatment.COMFREY, doctorLevel)
end

ISComfreyCataplasm_perform = ISComfreyCataplasm.perform
---@diagnostic disable-next-line: duplicate-set-field
function ISComfreyCataplasm:perform()
	ISComfreyCataplasm_perform(self)
	if AntibodiesUtils.isSinglePlayer() then
		applyTreatment(self.otherPlayer, self.bodyPart, self.doctorLevel)
	end
end

local ISComfreyCataplasm_complete = ISComfreyCataplasm.complete
---@diagnostic disable-next-line: duplicate-set-field
function ISComfreyCataplasm:complete()
	ISComfreyCataplasm_complete(self)
	if isServer() then
		applyTreatment(self.otherPlayer, self.bodyPart, self.doctorLevel)
	end
end
