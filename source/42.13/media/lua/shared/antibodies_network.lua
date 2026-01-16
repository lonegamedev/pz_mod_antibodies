local Antibodies = require("antibodies")
local AntibodiesEnum = require("antibodies_enum")

local AntibodiesNetwork = {}
AntibodiesNetwork.__index = AntibodiesNetwork

function AntibodiesNetwork.sendClientCommand(player, command, data)
	sendClientCommand(player, Antibodies.info.modId, command, data)
end

function AntibodiesNetwork.sendServerCommand(player, command, data)
	sendServerCommand(player, Antibodies.info.modId, command, data)
end

function AntibodiesNetwork.isAntibodiesCommand(module, command)
	if module ~= Antibodies.info.modId then
		return false
	end
	return AntibodiesEnum.Network.hasValue(command)
end

return AntibodiesNetwork
