require("TimedActions/ISApplyBandage")
local AntibodiesMedicalFile = require("antibodies_medical_file")
local AntibodiesEnum = require("antibodies_enum")
local AntibodiesUtils = require("antibodies_utils")

local function applyTreatment(patient, bodyPart, doctorLevel)
	local medicalFile = AntibodiesMedicalFile.of(patient)
	local bodyPart = medicalFile.body:getBodyPartByIndex(bodyPart:getType():index())
	bodyPart:setTreatmentSkill(AntibodiesEnum.BodyPart.Treatment.BANDAGED, doctorLevel)
	bodyPart:setTreatmentSkill(AntibodiesEnum.BodyPart.Treatment.CLEAN_BANDAGE, doctorLevel)
	bodyPart:setTreatmentSkill(AntibodiesEnum.BodyPart.Treatment.STERILIZED_BANDAGE, doctorLevel)
end

local ISApplyBandage_perform = ISApplyBandage.perform
---@diagnostic disable-next-line: duplicate-set-field
function ISApplyBandage:perform()
	ISApplyBandage_perform(self)
	if AntibodiesUtils.isSinglePlayer() then
		applyTreatment(self.otherPlayer, self.bodyPart, self.doctorLevel)
	end
end

local ISApplyBandage_complete = ISApplyBandage.complete
---@diagnostic disable-next-line: duplicate-set-field
function ISApplyBandage:complete()
	ISApplyBandage_complete(self)
	if isServer() then
		applyTreatment(self.otherPlayer, self.bodyPart, self.doctorLevel)
	end
end
