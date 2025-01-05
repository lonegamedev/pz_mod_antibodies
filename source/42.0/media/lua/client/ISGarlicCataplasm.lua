require("TimedActions/ISGarlicCataplasm")

ISGarlicCataplasm_perform = ISGarlicCataplasm.perform
function ISGarlicCataplasm:perform()
	ISGarlicCataplasm_perform(self)
	local customBodyParts = Antibodies.getCustomBodyParts(self.otherPlayer)
	customBodyParts[self.bodyPart:getType():toString()].garlic = self.doctorLevel
end
