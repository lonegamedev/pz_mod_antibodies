local AntibodiesTime = {}
AntibodiesTime.__index = AntibodiesTime

function AntibodiesTime:new()
	local instance = setmetatable({}, self)
	instance:reset()
	return instance
end

function AntibodiesTime:reset()
	local gameTime = GameTime:getInstance()
	self.lastTime = gameTime:getWorldAgeHours() * 60
	self.currentTime = self.lastTime
end

function AntibodiesTime:step()
	local gameTime = GameTime:getInstance()
	self.lastTime = self.currentTime
	self.currentTime = gameTime:getWorldAgeHours() * 60
end

function AntibodiesTime:getMinutesDelta()
	return math.max(0.0, self.currentTime - self.lastTime)
end

AntibodiesTime.current = nil
function AntibodiesTime.getInstance()
	if AntibodiesTime.current == nil then
		AntibodiesTime.current = AntibodiesTime:new()
	end
	return AntibodiesTime.current
end

return AntibodiesTime
