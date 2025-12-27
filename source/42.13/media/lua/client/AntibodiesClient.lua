local AntibodiesClient = {}
AntibodiesClient.__index = AntibodiesClient
AntibodiesClient.__name = "AntibodiesClient"

AntibodiesClient.timeAccumlator = 0

require("TimedActions.ISApplyBandage")
require("TimedActions.ISComfreyCataplasm")
require("TimedActions.ISDisinfect")
require("TimedActions.ISGarlicCataplasm")
require("TimedActions.ISPlantainCataplasm")

local Antibodies = require("Antibodies")
local AntibodiesUtils = require("AntibodiesUtils")
local AntibodiesMedicalFile = require("AntibodiesMedicalFile")
local AntibodiesConfig = require("AntibodiesConfig")

function AntibodiesClient.ensureInitialization(player)
	if AntibodiesConfig.current == nil then
		AntibodiesConfig.current = AntibodiesConfig.new()
	end
	if AntibodiesClient.timeAccumlator == nil then
		AntibodiesClient.timeAccumlator = 0
	end
end

function AntibodiesClient.updatePlayers()
	local players = AntibodiesUtils.getLocalPlayers()
	for _, player in ipairs(players) do
		local medicalFile = AntibodiesMedicalFile.of(player)
		medicalFile:update(player, AntibodiesConfig.current)
	end
end

function AntibodiesClient.networkSync(player)
	if isClient() then
		Antibodies.timeAccumlator = Antibodies.timeAccumlator + getGameTime():getInvMultiplier()
		if Antibodies.timeAccumlator >= 1.0 then
			local players = AntibodiesUtils.getLocalPlayers()
			for key, player in ipairs(players) do
				local save = player:getModData()
				sendClientCommand(
					player,
					Antibodies.info.modId,
					Antibodies.networkCommand.shareMedicalFile,
					{ playerOnlineId = player:getOnlineID(), medicalFile = save.medicalFile }
				)
			end
		end
		Antibodies.timeAccumlator = 0.0
	end
end

-----------------------------------------------------
--CALLBACKS------------------------------------------
-----------------------------------------------------

local function onGameStart()
	--applyOptions(nil)
end
Events.OnGameStart.Add(onGameStart)

local function onMainMenuEnter()
	--applyOptions(nil)
end
Events.OnMainMenuEnter.Add(onMainMenuEnter)

local function onServerCommand(module, command, arguments)
	if module == Antibodies.info.modId then
		if command == Antibodies.networkCommand.shareMedicalFile then
			local player = getPlayerByOnlineID(arguments.playerOnlineId)
			if player and not player:isLocalPlayer() then
				local modData = player:getModData()
				modData.medicalFile = arguments.medicalFile
			end
		end
	end
end
Events.OnServerCommand.Add(onServerCommand)

local function onEveryOneMinute()
	AntibodiesClient.ensureInitialization()
	AntibodiesClient.updatePlayers()
	--networkSync()
end
Events.EveryOneMinute.Add(onEveryOneMinute)

return AntibodiesClient
