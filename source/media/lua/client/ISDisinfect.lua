require("TimedActions/ISDisinfect")

ISDisinfect_perform = ISDisinfect.perform
function ISDisinfect:perform()
	ISDisinfect_perform(self)
	local customBodyParts = Antibodies.getCustomBodyParts(self.otherPlayer)
	customBodyParts[self.bodyPart:getType():toString()].sterilizedWound = self.doctorLevel
end
