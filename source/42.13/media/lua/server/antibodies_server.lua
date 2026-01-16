require("timedActions.is_apply_bandage")
require("timedActions.is_comfrey_cataplasm")
require("timedActions.is_disinfect")
require("timedActions.is_garlic_cataplasm")
require("timedActions.is_plantain_cataplasm")

local AntibodiesEnum = require("antibodies_enum")
local AntibodiesMedicalFile = require("antibodies_medical_file")
local AntibodiesConfig = require("antibodies_config")
local AntibodiesUtils = require("antibodies_utils")
local AntibodiesNetwork = require("antibodies_network")
local AntibodiesTime = require("antibodies_time")

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
	return AntibodiesConfig.getCurrent() ~= nil and AntibodiesTime.getInstance() ~= nil
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
	if medicalFile then
		local data = { medicalFile = medicalFile }
		AntibodiesNetwork.sendServerCommand(ownerPlayer, AntibodiesEnum.Network.SHARE_MEDICAL_FILE, data)
		if nearbyPlayers then
			for _, targetPlayer in ipairs(nearbyPlayers) do
				AntibodiesNetwork.sendServerCommand(targetPlayer, AntibodiesEnum.Network.SHARE_MEDICAL_FILE, data)
			end
		end
	end
end

function AntibodiesServer.updatePlayers()
	local minutesElapsed = AntibodiesTime:getInstance():getMinutesDelta()
	if minutesElapsed > 0.0 then
		local players = AntibodiesUtils.getOnlinePlayers()
		local config = AntibodiesConfig.getCurrent()
		for _, player in ipairs(players) do
			local medicalFile = AntibodiesMedicalFile.of(player)
			medicalFile:update(player, minutesElapsed, config)
			AntibodiesServer.broadcastMedicalFile(player, medicalFile)
		end
	end
end

-----------------------------------------------------
--CALLBACKS------------------------------------------
-----------------------------------------------------

local function onServerStarted()
	AntibodiesTime.getInstance():reset()
end
Events.OnServerStarted.Add(onServerStarted)

local function onEveryOneMinute()
	if AntibodiesServer.ensureInitialization() then
		AntibodiesTime:getInstance():step()
		AntibodiesServer.computeOnlineUsernameSet()
		AntibodiesServer.computeNearbyPlayerMapping()
		AntibodiesServer.updatePlayers()
	end
end
Events.EveryOneMinute.Add(onEveryOneMinute)

-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------

return AntibodiesServer
