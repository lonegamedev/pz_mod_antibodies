local Antibodies = require("antibodies")
local AntibodiesEnum = require("antibodies_enum")
local AntibodiesMedicalFile = require("antibodies_medical_file")

AntibodiesServer = {}
AntibodiesServer.__index = AntibodiesServer
AntibodiesServer.__name = "AntibodiesServer"

AntibodiesServer.BROADCAST_RANGE = 8
AntibodiesServer.BROADCAST_RANGE_SQ = AntibodiesServer.BROADCAST_RANGE * AntibodiesServer.BROADCAST_RANGE

AntibodiesServer.onlinePlayersByName = {}
AntibodiesServer.nearbyPlayerMapping = {}

function AntibodiesServer.ensureInitialization()
	if not isServer() then
		return false
	end
	if AntibodiesServer.onlinePlayersByName == nil then
		AntibodiesServer.onlinePlayersByName = {}
	end
	if AntibodiesServer.nearbyPlayerMapping == nil then
		AntibodiesServer.nearbyPlayerMapping = {}
	end
	return true
end

function AntibodiesServer.validateIncoming(module, command, player, data)
	if module ~= Antibodies.info.modId then
		return false
	end
	if command == AntibodiesEnum.Network.SHARE_MEDICAL_FILE then
		if not data or not data.medicalFile then
			print("WARNING: Player", player:getUsername(), "sent invalid or empty medicalFile")
			return false
		end
		if player:getUsername() ~= data.medicalFile.userName then
			print("WARNING: Player", player:getUsername(), "tried to send medical file for", data.medicalFile.userName)
			return false
		end
		return command
	end
	return false
end

function AntibodiesServer.computeOnlineUsernameSet()
	AntibodiesServer.onlinePlayersByName = {}
	local players = getOnlinePlayers()
	if not players then
		return
	end
	for i = 0, players:size() - 1 do
		local player = players:get(i)
		if player then
			AntibodiesServer.onlinePlayersByName[player:getUsername()] = player
		end
	end
end

function AntibodiesServer.getDistance3DSq(playerA, playerB)
	if not playerA or not playerB then
		return math.huge
	end
	local dx = playerA:getX() - playerB:getX()
	local dy = playerA:getY() - playerB:getY()
	local dz = (playerA:getZ() - playerB:getZ())
	return dx * dx + dy * dy + dz * dz
end

function AntibodiesServer.computeNearbyPlayerMapping()
	AntibodiesServer.nearbyPlayerMapping = {}
	for _, player in pairs(AntibodiesServer.onlinePlayersByName) do
		AntibodiesServer.nearbyPlayerMapping[player] = {}
	end
	local playersList = {}
	for _, p in pairs(AntibodiesServer.onlinePlayersByName) do
		table.insert(playersList, p)
	end
	for i = 1, #playersList do
		local owner = playersList[i]
		for j = i + 1, #playersList do
			local target = playersList[j]
			if AntibodiesServer.getDistance3DSq(owner, target) < AntibodiesServer.BROADCAST_RANGE_SQ then
				table.insert(AntibodiesServer.nearbyPlayerMapping[owner], target)
				table.insert(AntibodiesServer.nearbyPlayerMapping[target], owner)
			end
		end
	end
end

function AntibodiesServer.broadcastMedicalFile(ownerPlayer, medicalFile)
	local nearbyPlayers = AntibodiesServer.nearbyPlayerMapping[ownerPlayer]
	if nearbyPlayers and medicalFile then
		for _, targetPlayer in ipairs(nearbyPlayers) do
			sendServerCommand(
				targetPlayer,
				Antibodies.info.modId,
				AntibodiesEnum.Network.SHARE_MEDICAL_FILE,
				{ medicalFile = medicalFile }
			)
		end
	end
end

-----------------------------------------------------
--CALLBACKS------------------------------------------
-----------------------------------------------------

local function onClientCommand(module, command, player, data)
	local op = AntibodiesServer.validateIncoming(module, command, player, data)
	if op == AntibodiesEnum.Network.SHARE_MEDICAL_FILE then
		local md = Antibodies.getNamespacedModData(player)
		md.medicalFile = data.medicalFile
		AntibodiesMedicalFile.rehydrate(md.medicalFile)
		md.medicalFile:applyToPlayer(player)
		AntibodiesServer.broadcastMedicalFile(player, data.medicalFile)
	end
end
Events.OnClientCommand.Add(onClientCommand)

local function onEveryOneMinute()
	if AntibodiesServer.ensureInitialization() then
		AntibodiesServer.computeOnlineUsernameSet()
		AntibodiesServer.computeNearbyPlayerMapping()
	end
end
Events.EveryOneMinute.Add(onEveryOneMinute)

-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
