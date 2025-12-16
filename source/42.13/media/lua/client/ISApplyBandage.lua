require("TimedActions/ISApplyBandage")

local ISApplyBandage_perform = ISApplyBandage.perform
function ISApplyBandage:perform()
	ISApplyBandage_perform(self)
	local customBodyParts = Antibodies.getCustomBodyParts(self.otherPlayer)
	customBodyParts[self.bodyPart:getType():toString()].bandaged = self.doctorLevel
	customBodyParts[self.bodyPart:getType():toString()].cleanBandage = self.doctorLevel
	customBodyParts[self.bodyPart:getType():toString()].sterilizedBandage = self.doctorLevel
end
