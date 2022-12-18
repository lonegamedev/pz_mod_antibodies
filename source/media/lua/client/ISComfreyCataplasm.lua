require("TimedActions/ISComfreyCataplasm")

ISComfreyCataplasm_perform = ISComfreyCataplasm.perform
function ISComfreyCataplasm:perform()
	ISComfreyCataplasm_perform(self)
	local customBodyParts = Antibodies.getCustomBodyParts(self.otherPlayer)
	customBodyParts[self.bodyPart:getType():toString()].comfrey = self.doctorLevel
end
