local Antibodies = {}
Antibodies.__index = Antibodies

local AntibodiesUtils = require("AntibodiesUtils")
local AntibodiesOptions = require("AntibodiesOptions")
local AntibodiesShared = require("AntibodiesShared")
local AntibodiesMedicalFile = require("AntibodiesMedicalFile")
local AntibodiesConfig = require("AntibodiesConfig")

local timeAccumlator = 0
local config = nil

local function ensureModInitialization(player)
	if config == nil then
		config = AntibodiesConfig.new()
	end
	if timeAccumlator == nil then
		timeAccumlator = 0
	end
end

local function updatePlayers()
	local players = AntibodiesUtils.getLocalPlayers()
	for _, player in ipairs(players) do
		local medicalFile = AntibodiesMedicalFile.of(player, true)
		medicalFile:update(player, config)
		player:getModData().antibodiesMedicalFile = medicalFile
	end
end

local function networkSync(player)
	if isClient() then
		Antibodies.timeAccumlator = Antibodies.timeAccumlator + getGameTime():getInvMultiplier()
		if Antibodies.timeAccumlator >= 1.0 then
			local players = AntibodiesUtils.getLocalPlayers()
			for key, player in ipairs(players) do
				local save = player:getModData()
				sendClientCommand(
					player,
					Antibodies.info.modId,
					AntibodiesShared.networkCommand.shareMedicalFile,
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
		if command == AntibodiesShared.networkCommand.shareMedicalFile then
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
	ensureModInitialization()
	updatePlayers()
	--networkSync()
end
Events.EveryOneMinute.Add(onEveryOneMinute)

return Antibodies
