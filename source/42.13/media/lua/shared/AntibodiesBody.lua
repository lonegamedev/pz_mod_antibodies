local AntibodiesEnum = require("AntibodiesEnum")
local AntibodiesBodyPart = require("AntibodiesBodyPart")

local AntibodiesBody = {}
AntibodiesBody.__index = AntibodiesBody

function AntibodiesBody.new(player)
	local instance = setmetatable({}, AntibodiesBody)

	local bodyDamage = player:getBodyDamage()
	instance.bodyParts = {}
	for i = 0, bodyDamage:getBodyParts():size() - 1 do
		local bodyPart = bodyDamage:getBodyParts():get(i)
		local id = AntibodiesEnum.BodyPart.fromIndex(bodyPart:getType():index())
		instance.bodyParts[id] = AntibodiesBodyPart.new(bodyPart)
	end

	instance:update(player, nil)

	return instance
end

function AntibodiesBody.rehydrate(body)
	if getmetatable(body) ~= AntibodiesBody then
		setmetatable(body, AntibodiesBody)
		for _, key in ipairs(AntibodiesEnum.BodyPart.list()) do
			AntibodiesBodyPart.rehydrate(body.bodyParts[key])
		end
		return body
	end
end

function AntibodiesBody:update(player, config)
	self.totalWoundEffect = 0
	self.totalTreatmentEffect = 0
	self.totalInfectionEffect = 0
	self.totalHygieneEffect = 0
	self.totalEffect = 0

	local bodyDamage = player:getBodyDamage()
	for _, key in ipairs(AntibodiesEnum.BodyPart.list()) do
		local index = AntibodiesEnum.BodyPart.toIndex(key)
		local bodyPart = bodyDamage:getBodyParts():get(index)
		self.bodyParts[key]:update(bodyPart, config)
		self.totalWoundEffect = self.totalWoundEffect + self.bodyParts[key].totalWoundEffect
		self.totalTreatmentEffect = self.totalTreatmentEffect + self.bodyParts[key].totalTreatmentEffect
		self.totalInfectionEffect = self.totalInfectionEffect + self.bodyParts[key].totalInfectionEffect
		self.totalHygieneEffect = self.totalHygieneEffect + self.bodyParts[key].totalHygieneEffect
	end

	self.totalEffect = self.totalWoundEffect
		+ self.totalTreatmentEffect
		+ self.totalInfectionEffect
		+ self.totalHygieneEffect

	return self
end

return AntibodiesBody
