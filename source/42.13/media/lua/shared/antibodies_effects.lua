local AntibodiesEffects = {}
AntibodiesEffects.__index = AntibodiesEffects
AntibodiesEffects.__name = "AntibodiesEffects"

function AntibodiesEffects:new(minMagnitude)
	local instance = setmetatable({}, self)
	instance.minMagnitude = tonumber(minMagnitude) or 0.01
	instance:clear()
	return instance
end

function AntibodiesEffects:newFromEffects(...)
	local instance = AntibodiesEffects:new()
	local minMagnitude = 0.0
	for _, effects in ipairs({ ... }) do
		if effects.minMagnitude > minMagnitude then
			minMagnitude = effects.minMagnitude
		end
		for id, value in pairs(effects.values) do
			instance:set(id, value)
		end
	end
	instance.minMagnitude = minMagnitude
	instance._dirty = true
	instance:recalculate()
	return instance
end

function AntibodiesEffects.rehydrate(effects)
	if getmetatable(effects) ~= AntibodiesEffects then
		setmetatable(effects, AntibodiesEffects)
		return effects
	end
end

function AntibodiesEffects:clear()
	self.values = {}
	self._total = 0.0
	self._order = {}
	self._dirty = false
end

function AntibodiesEffects:get(id)
	return self.values[id] or 0
end

function AntibodiesEffects:set(id, value)
	value = tonumber(value) or 0
	if math.abs(value) >= self.minMagnitude then
		self.values[id] = value
	else
		self.values[id] = nil
	end
	self._dirty = true
end

function AntibodiesEffects:recalculate()
	if self._dirty then
		local total = 0
		local keys = {}
		for key, value in pairs(self.values) do
			total = total + value
			table.insert(keys, key)
		end
		table.sort(keys, function(a, b)
			return math.abs(self.values[a]) > math.abs(self.values[b])
		end)
		self._total = total
		self._order = keys
		self._dirty = false
	end
end

function AntibodiesEffects:getTotal()
	self:recalculate()
	return self._total
end

function AntibodiesEffects:getOrder()
	self:recalculate()
	return self._order
end

function AntibodiesEffects:toString()
	return self.__name .. self:__tostring()
end

function AntibodiesEffects:__tostring()
	self:recalculate()
	local parts = {}
	for _, id in ipairs(self._order) do
		local value = self.values[id]
		table.insert(parts, string.format("%s=%.2f", tostring(id), value))
	end
	return string.format("{ total=%.2f, values=[%s] }", self._total, table.concat(parts, ", "))
end

return AntibodiesEffects
