local Antibodies = require("antibodies")

AntibodiesServer = {}
AntibodiesServer.__index = AntibodiesServer
AntibodiesServer.__name = "AntibodiesServer"

AntibodiesServer.DISTANCE_Z_WEIGHT = 2
AntibodiesServer.BROADCAST_RANGE = 4
AntibodiesServer.BROADCAST_RANGE_SQ = AntibodiesServer.BROADCAST_RANGE * AntibodiesServer.BROADCAST_RANGE
AntibodiesServer.PRUNE_INTERVAL = 30

AntibodiesServer.pruneAccumulator = 0
AntibodiesServer.medicalFile = {}

function AntibodiesServer.ensureInitialization()
	if not isServer() then
		return false
	end
	if AntibodiesServer.medicalFile == nil then
		AntibodiesServer.medicalFile = {}
	end
	return true
end

function AntibodiesServer.validateIncoming(module, command, player, data)
	if module ~= Antibodies.info.modId then
		return false
	end
	if command == Antibodies.networkCommand.shareMedicalFile then
		if not data or not data.medicalFile then
			print("WARNING: Player", player:getUsername(), "sent invalid or empty medicalFile")
			return false
		end
		if player:getUsername() ~= data.medicalFile.userName then
			print("WARNING: Player", player:getUsername(), "tried to send medical file for", data.medicalFile.userName)
			return false
		end
		return Antibodies.networkCommand.shareMedicalFile
	end
	return false
end

function AntibodiesServer.storeMedicalFile(medicalFile)
	AntibodiesServer.medicalFile[medicalFile.userName] = medicalFile
end

function AntibodiesServer.getOnlineUsernameSet()
	local set = {}
	local players = getOnlinePlayers()
	if not players then
		return set
	end
	for i = 0, players:size() - 1 do
		local player = players:get(i)
		if player then
			set[player:getUsername()] = player
		end
	end
	return set
end

function AntibodiesServer.getDistance3DSq(playerA, playerB)
	if not playerA or not playerB then
		return math.huge
	end
	local dx = playerA:getX() - playerB:getX()
	local dy = playerA:getY() - playerB:getY()
	local dz = (playerA:getZ() - playerB:getZ()) * AntibodiesServer.DISTANCE_Z_WEIGHT
	return dx * dx + dy * dy + dz * dz
end

function AntibodiesServer.broadcastMedicalFiles()
	local onlinePlayersByName = AntibodiesServer.getOnlineUsernameSet()
	for userName, medicalFile in pairs(AntibodiesServer.medicalFile) do
		local ownerPlayer = onlinePlayersByName[userName]
		if ownerPlayer then
			for _, targetPlayer in pairs(onlinePlayersByName) do
				if targetPlayer ~= ownerPlayer then
					if
						AntibodiesServer.getDistance3DSq(ownerPlayer, targetPlayer)
						< AntibodiesServer.BROADCAST_RANGE_SQ
					then
						sendServerCommand(
							targetPlayer,
							Antibodies.info.modId,
							Antibodies.networkCommand.shareMedicalFile,
							{
								medicalFile = medicalFile,
							}
						)
					end
				end
			end
		end
	end
end

function AntibodiesServer.needsPruning()
	AntibodiesServer.pruneAccumulator = AntibodiesServer.pruneAccumulator + 1
	if AntibodiesServer.pruneAccumulator >= AntibodiesServer.PRUNE_INTERVAL then
		AntibodiesServer.pruneAccumulator = 0
		return true
	end
	return false
end

function AntibodiesServer.pruneOfflineMedicalFiles()
	local onlinePlayersByName = AntibodiesServer.getOnlineUsernameSet()
	for userName in pairs(AntibodiesServer.medicalFile) do
		if not onlinePlayersByName[userName] then
			AntibodiesServer.medicalFile[userName] = nil
		end
	end
end

-----------------------------------------------------
--CALLBACKS------------------------------------------
-----------------------------------------------------

local function onClientCommand(module, command, player, data)
	local op = AntibodiesServer.validateIncoming(module, command, player, data)
	if op == Antibodies.networkCommand.shareMedicalFile then
		AntibodiesServer.storeMedicalFile(data.medicalFile)
	end
end
Events.OnClientCommand.Add(onClientCommand)

local function onEveryOneMinute()
	if AntibodiesServer.ensureInitialization() then
		AntibodiesServer.broadcastMedicalFiles()
	end
	if AntibodiesServer.needsPruning() then
		AntibodiesServer.pruneOfflineMedicalFiles()
	end
end
Events.EveryOneMinute.Add(onEveryOneMinute)
