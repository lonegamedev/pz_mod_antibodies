local AntibodiesEnum = require("antibodies_enum")
local AntibodiesBodyPart = require("antibodies_body_part")
local AntibodiesEffects = require("antibodies_effects")

local AntibodiesBody = {}
AntibodiesBody.__index = AntibodiesBody
AntibodiesBody.__name = "AntibodiesBody"

function AntibodiesBody:new(player)
	local instance = setmetatable({}, self)

	instance.bodyParts = {}
	instance.woundEffects = AntibodiesEffects:new()
	instance.treatmentEffects = AntibodiesEffects:new()
	instance.infectionEffects = AntibodiesEffects:new()
	instance.hygieneEffects = AntibodiesEffects:new()

	local bodyDamage = player:getBodyDamage()
	for i = 0, bodyDamage:getBodyParts():size() - 1 do
		local bodyPartNative = bodyDamage:getBodyParts():get(i)
		local bodyPart = AntibodiesBodyPart:new(bodyPartNative)
		instance.bodyParts[bodyPart.id] = bodyPart
	end

	instance:update(player, nil)

	return instance
end

function AntibodiesBody.rehydrate(body)
	if getmetatable(body) ~= AntibodiesBody then
		setmetatable(body, AntibodiesBody)
		for _, key in ipairs(AntibodiesEnum.BodyPart.list()) do
			AntibodiesBodyPart.rehydrate(body.bodyParts[key])
			AntibodiesEffects.rehydrate(body.woundEffects)
			AntibodiesEffects.rehydrate(body.treatmentEffects)
			AntibodiesEffects.rehydrate(body.infectionEffects)
			AntibodiesEffects.rehydrate(body.hygieneEffects)
		end
		return body
	end
end

function AntibodiesBody:update(player, config)
	self.woundEffects:clear()
	self.treatmentEffects:clear()
	self.infectionEffects:clear()
	self.hygieneEffects:clear()

	local bodyDamage = player:getBodyDamage()
	for _, key in ipairs(AntibodiesEnum.BodyPart.list()) do
		local index = AntibodiesEnum.BodyPart.toIndex(key)
		local bodyPartNative = bodyDamage:getBodyParts():get(index)
		local bodyPart = self.bodyParts[key]
		bodyPart:update(bodyPartNative, config)
		self.woundEffects:set(key, bodyPart.woundEffects:getTotal())
		self.treatmentEffects:set(key, bodyPart.treatmentEffects:getTotal())
		self.infectionEffects:set(key, bodyPart.infectionEffects:getTotal())
		self.hygieneEffects:set(key, bodyPart.hygieneEffects:getTotal())
	end

	return self
end

function AntibodiesBody:getBodyPartByIndex(index)
	local id = AntibodiesEnum.BodyPart.fromIndex(index)
	return self.bodyParts[id]
end

function AntibodiesBody:getTotalEffect()
	return self.woundEffects:getTotal()
		+ self.treatmentEffects:getTotal()
		+ self.infectionEffects:getTotal()
		+ self.hygieneEffects:getTotal()
end

function AntibodiesBody:toString()
	return self.__name .. self:__tostring()
end

function AntibodiesBody:__tostring()
	return (
		"{ "
		.. "woundEffects="
		.. tostring(self.woundEffects)
		.. " "
		.. "treatmentEffects="
		.. tostring(self.treatmentEffects)
		.. " "
		.. "infectionEffects="
		.. tostring(self.infectionEffects)
		.. " "
		.. "hygieneEffects="
		.. tostring(self.hygieneEffects)
		.. " }"
	)
end

return AntibodiesBody
