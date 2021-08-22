require "ISUI/ISUIElement"

local UXGameOption = ISBaseObject:derive("UXGameOption")

function UXGameOption:new(name, control, arg1, arg2)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.name = name
	o.control = control
	o.arg1 = arg1
	o.arg2 = arg2
	if control.isTextEntryBox then
        control.onTextChange = function()
            o.gameOptions:onChange(self)
        end
	end
	return o
end

function UXGameOption:toUI()
	print('ERROR: option "'..self.name..'" missing toUI()')
end

function UXGameOption:apply()
	print('ERROR: option "'..self.name..'" missing apply()')
end

return UXGameOption