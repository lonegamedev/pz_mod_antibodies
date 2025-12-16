require("TimedActions/ISPlantainCataplasm")

ISPlantainCataplasm_perform = ISPlantainCataplasm.perform
function ISPlantainCataplasm:perform()
	ISPlantainCataplasm_perform(self)
	local customBodyParts = Antibodies.getCustomBodyParts(self.otherPlayer)
	customBodyParts[self.bodyPart:getType():toString()].plantain = self.doctorLevel
end
